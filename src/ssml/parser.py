"""
SSML Parser - Analisador de Speech Synthesis Markup Language
Foco em português do Brasil (pt-BR)
"""
from typing import List, Dict, Any, Optional
from xml.etree import ElementTree as ET
import re
import logging

logger = logging.getLogger(__name__)


class SSMLParser:
    """Parser para SSML com foco em pt-BR"""
    
    # Mapeamento de velocidades textuais para valores numéricos
    RATE_MAP = {
        "x-slow": 0.5,
        "slow": 0.8,
        "medium": 1.0,
        "fast": 1.2,
        "x-fast": 1.5
    }
    
    def __init__(self):
        self.chunks = []
        self.current_language = "pt-BR"
        
    def parse(self, ssml_text: str) -> List[Dict[str, Any]]:
        """
        Parseia texto SSML e retorna lista de chunks processáveis
        
        Args:
            ssml_text: Texto com tags SSML
            
        Returns:
            Lista de chunks com metadados
        """
        self.chunks = []
        
        try:
            # Limpar e preparar SSML
            ssml_text = self._prepare_ssml(ssml_text)
            
            # Parsear XML
            root = ET.fromstring(ssml_text)
            
            # Processar elementos recursivamente
            self._process_element(root)
            
            return self.chunks
            
        except ET.ParseError as e:
            logger.error(f"Erro ao parsear SSML: {e}")
            # Fallback: retornar texto plano
            return [{
                "type": "text",
                "content": self._strip_tags(ssml_text),
                "metadata": {}
            }]
    
    def _prepare_ssml(self, text: str) -> str:
        """Prepara texto SSML para parsing"""
        # Se não tiver tag <speak>, adicionar
        if not text.strip().startswith("<speak"):
            text = f"<speak>{text}</speak>"
        
        # Garantir que tags self-closing estejam corretas
        text = re.sub(r'<break\s+time="([^"]+)"\s*/?>',
                     r'<break time="\1"/>', text)
        
        return text
    
    def _process_element(self, element: ET.Element, 
                        parent_metadata: Optional[Dict] = None):
        """Processa elemento XML recursivamente"""
        metadata = parent_metadata.copy() if parent_metadata else {}
        
        # Processar baseado no tipo de tag
        tag = element.tag.lower()
        
        if tag == "speak":
            # Tag raiz, processar texto inicial
            if element.text and element.text.strip():
                self._add_text_chunk(element.text.strip(), metadata)
            
            # Processar filhos
            for child in element:
                self._process_element(child, metadata)
            
            # Processar texto tail
            if element.tail and element.tail.strip():
                self._add_text_chunk(element.tail.strip(), metadata)
                
        elif tag == "break":
            # Pausa
            duration = element.get("time", "0.5s")
            self._add_break_chunk(duration)
            
            # Processar texto após a pausa (tail)
            if element.tail and element.tail.strip():
                self._add_text_chunk(element.tail.strip(), metadata)
            
        elif tag == "prosody":
            # Controle de prosódia
            new_metadata = metadata.copy()
            
            # Rate (velocidade)
            if "rate" in element.attrib:
                rate = element.get("rate")
                new_metadata["rate"] = rate
                new_metadata["speed"] = self._parse_rate(rate)
            
            # Pitch (tom)
            if "pitch" in element.attrib:
                pitch = element.get("pitch")
                new_metadata["pitch"] = self._parse_pitch(pitch)
            
            # Volume
            if "volume" in element.attrib:
                new_metadata["volume"] = element.get("volume")
            
            # Processar conteúdo
            if element.text and element.text.strip():
                self._add_text_chunk(element.text.strip(), new_metadata)
            
            for child in element:
                self._process_element(child, new_metadata)
                
            if element.tail and element.tail.strip():
                self._add_text_chunk(element.tail.strip(), metadata)
                
        elif tag == "phoneme":
            # Pronúncia fonética
            alphabet = element.get("alphabet", "ipa")
            ph = element.get("ph", "")
            original_text = element.text or ""
            
            new_metadata = metadata.copy()
            new_metadata["phoneme"] = {
                "alphabet": alphabet,
                "pronunciation": ph,
                "original": original_text
            }
            
            self._add_text_chunk(original_text, new_metadata)
            
            if element.tail and element.tail.strip():
                self._add_text_chunk(element.tail.strip(), metadata)
                
        elif tag == "emphasis":
            # Ênfase
            level = element.get("level", "moderate")
            new_metadata = metadata.copy()
            new_metadata["emphasis"] = level
            
            if element.text and element.text.strip():
                self._add_text_chunk(element.text.strip(), new_metadata)
            
            for child in element:
                self._process_element(child, new_metadata)
                
            if element.tail and element.tail.strip():
                self._add_text_chunk(element.tail.strip(), metadata)
                
        elif tag == "p" or tag == "s":
            # Parágrafo ou sentença
            if element.text and element.text.strip():
                self._add_text_chunk(element.text.strip(), metadata)
            
            for child in element:
                self._process_element(child, metadata)
                
            if element.tail and element.tail.strip():
                self._add_text_chunk(element.tail.strip(), metadata)
        
        else:
            # Tag desconhecida, processar como texto
            if element.text and element.text.strip():
                self._add_text_chunk(element.text.strip(), metadata)
            
            for child in element:
                self._process_element(child, metadata)
                
            if element.tail and element.tail.strip():
                self._add_text_chunk(element.tail.strip(), metadata)
    
    def _add_text_chunk(self, text: str, metadata: Dict):
        """Adiciona chunk de texto"""
        if text.strip():
            self.chunks.append({
                "type": "text",
                "content": text.strip(),
                "metadata": metadata.copy()
            })
    
    def _add_break_chunk(self, duration: str):
        """Adiciona chunk de pausa"""
        # Converter duração para segundos
        seconds = self._parse_duration(duration)
        
        self.chunks.append({
            "type": "break",
            "duration": seconds,
            "metadata": {}
        })
    
    def _parse_duration(self, duration: str) -> float:
        """Converte duração SSML para segundos"""
        duration = duration.lower().strip()
        
        # Formato: "1.5s" ou "500ms"
        if duration.endswith("ms"):
            return float(duration[:-2]) / 1000
        elif duration.endswith("s"):
            return float(duration[:-1])
        else:
            # Assumir segundos
            return float(duration)
    
    def _parse_rate(self, rate: str) -> float:
        """Converte rate SSML para valor numérico"""
        rate = rate.lower().strip()
        
        # Se for palavra-chave
        if rate in self.RATE_MAP:
            return self.RATE_MAP[rate]
        
        # Se for porcentagem: "80%"
        if rate.endswith("%"):
            return float(rate[:-1]) / 100
        
        # Se for número direto
        try:
            return float(rate)
        except ValueError:
            logger.warning(f"Rate inválido: {rate}, usando 1.0")
            return 1.0
    
    def _parse_pitch(self, pitch: str) -> int:
        """Converte pitch SSML para semitons"""
        pitch = pitch.strip()
        
        # Formato: "+3st", "-2st", "+3", "-2"
        pitch = pitch.replace("st", "").replace("semitones", "")
        
        try:
            return int(pitch)
        except ValueError:
            logger.warning(f"Pitch inválido: {pitch}, usando 0")
            return 0
    
    def _strip_tags(self, text: str) -> str:
        """Remove todas as tags XML do texto"""
        return re.sub(r'<[^>]+>', '', text)
    
    def get_plain_text(self) -> str:
        """Retorna apenas o texto sem tags"""
        texts = [chunk["content"] for chunk in self.chunks 
                if chunk["type"] == "text"]
        return " ".join(texts)
    
    def get_total_duration(self) -> float:
        """Calcula duração total das pausas"""
        return sum(chunk["duration"] for chunk in self.chunks 
                  if chunk["type"] == "break")


# Exemplo de uso
if __name__ == "__main__":
    parser = SSMLParser()
    
    ssml = """
    <speak>
        Olá! Bem-vindo ao audiolivro.
        <break time="2s"/>
        <prosody rate="slow" pitch="-2">
            Este é um exemplo em português.
        </prosody>
        <break time="1s"/>
        <phoneme alphabet="ipa" ph="ʒoˈɐ̃w">João</phoneme> chegou.
    </speak>
    """
    
    chunks = parser.parse(ssml)
    
    print("Chunks processados:")
    for i, chunk in enumerate(chunks, 1):
        print(f"{i}. {chunk}")

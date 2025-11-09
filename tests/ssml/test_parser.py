"""
Testes para SSML Parser
"""
import sys
from pathlib import Path

# Adicionar src ao path
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "src"))

from ssml.parser import SSMLParser


def test_parse_simple_text():
    """Teste de texto simples"""
    parser = SSMLParser()
    chunks = parser.parse("<speak>Olá mundo</speak>")
    
    assert len(chunks) == 1
    assert chunks[0]["type"] == "text"
    assert chunks[0]["content"] == "Olá mundo"


def test_parse_with_break():
    """Teste com pausas"""
    parser = SSMLParser()
    ssml = """
    <speak>
        Olá
        <break time="1.5s"/>
        mundo
    </speak>
    """
    chunks = parser.parse(ssml)
    
    assert len(chunks) == 3
    assert chunks[0]["type"] == "text"
    assert chunks[1]["type"] == "break"
    assert chunks[1]["duration"] == 1.5
    assert chunks[2]["type"] == "text"


def test_parse_prosody():
    """Teste com prosody"""
    parser = SSMLParser()
    ssml = """
    <speak>
        <prosody rate="slow" pitch="-2">
            Texto devagar
        </prosody>
    </speak>
    """
    chunks = parser.parse(ssml)
    
    assert len(chunks) == 1
    assert chunks[0]["metadata"]["speed"] == 0.8
    assert chunks[0]["metadata"]["pitch"] == -2


def test_parse_phoneme():
    """Teste com phoneme"""
    parser = SSMLParser()
    ssml = """
    <speak>
        <phoneme alphabet="ipa" ph="ʒoˈɐ̃w">João</phoneme>
    </speak>
    """
    chunks = parser.parse(ssml)
    
    assert len(chunks) == 1
    assert "phoneme" in chunks[0]["metadata"]
    assert chunks[0]["metadata"]["phoneme"]["pronunciation"] == "ʒoˈɐ̃w"


def test_parse_complex():
    """Teste complexo com múltiplas tags"""
    parser = SSMLParser()
    ssml = """
    <speak>
        Capítulo 1: O Início.
        <break time="2s"/>
        <prosody rate="0.9">
            Era uma vez
        </prosody>
        <break time="1s"/>
        um menino chamado <phoneme alphabet="ipa" ph="ˈpedɾu">Pedro</phoneme>.
    </speak>
    """
    chunks = parser.parse(ssml)
    
    assert len(chunks) > 3
    breaks = [c for c in chunks if c["type"] == "break"]
    assert len(breaks) == 2


if __name__ == "__main__":
    print("Executando testes...")
    
    test_parse_simple_text()
    print("✅ test_parse_simple_text")
    
    test_parse_with_break()
    print("✅ test_parse_with_break")
    
    test_parse_prosody()
    print("✅ test_parse_prosody")
    
    test_parse_phoneme()
    print("✅ test_parse_phoneme")
    
    test_parse_complex()
    print("✅ test_parse_complex")
    
    print("\n🎉 Todos os testes passaram!")

# ADR-002: Suporte SSML para Text-to-Speech

**Status**: ✅ Aceito  
**Data Decisão**: 2025-11-09  
**Decisores**: DarkChannel Team  
**Tags**: `tts`, `ssml`, `audiobook`, `enhancement`

---

## Contexto e Problema

Atualmente, o DarkChannel Stack utiliza Kokoro TTS e OpenVoice para geração de áudio, mas não oferece controle granular sobre aspectos da síntese de fala como:

- **Pausas controladas** entre frases ou capítulos
- **Pronúncia específica** de nomes de personagens, termos técnicos ou palavras em outros idiomas
- **Controle emocional** em diálogos e narrativas
- **Velocidade variável** para diferentes contextos (narração vs. diálogo)
- **Ênfase** em palavras-chave

Para produção de audiolivros de alta qualidade, esses controles são essenciais. SSML (Speech Synthesis Markup Language) é o padrão W3C para esse tipo de controle.

### 🇧🇷 Foco Inicial: Português do Brasil

**Decisão Estratégica**: O projeto terá foco inicial em **Português do Brasil (pt-BR)**, o que impacta diretamente as escolhas técnicas:

- ✅ **OpenVoice V2** suporta pt-BR nativamente
- ❌ **OpenVoice V1** (com emoções) é limitado a inglês
- 🎯 **Prioridade**: Qualidade em português > Controle emocional

**Implicação**: Controle de emoção via tags SSML será **adiado para Fase 2** (quando houver suporte multilíngue ou datasets pt-BR de qualidade).

### ✅ Infraestrutura Atual

**Confirmado**: O projeto **JÁ está usando OpenVoice V2**:
- 📦 Configurado em `Dockerfile.openvoice`
- 🗂️ Diretório `checkpoints_v2` criado
- 🌐 Download de `myshell-ai/OpenVoiceV2` configurado
- 🇧🇷 Suporte a pt-BR confirmado em `/languages`

**Conclusão**: Não precisamos migrar ou alterar a infraestrutura. Apenas implementar o middleware SSML.

### Limitações Atuais

1. **Kokoro TTS**: API simples que aceita apenas texto plano
2. **OpenVoice**: Foco em clonagem de voz, sem suporte nativo a SSML
3. **N8N Workflows**: Processamento básico sem interpretação de marcações

### Requisitos do Usuário

- Criar audiolivros com pausas dramáticas
- Controlar pronúncia de nomes próprios
- Adicionar emoção e entonação em diálogos
- Manter compatibilidade com workflows existentes

---

## Decisão

Implementaremos um **middleware SSML** que:

1. **Intercepta** requisições de TTS antes de enviá-las aos serviços
2. **Parseia** tags SSML do texto de entrada
3. **Transforma** as instruções SSML em:
   - Parâmetros nativos dos serviços (quando suportado)
   - Pré-processamento de texto
   - Pós-processamento de áudio
4. **Mantém compatibilidade** com texto plano (sem SSML)

### Arquitetura Proposta

```
┌─────────────────┐
│   N8N Workflow  │
│   (Input Text)  │
└────────┬────────┘
         │
         │ Text with SSML tags
         ▼
┌─────────────────────────┐
│   SSML Parser Service   │
│  (Python FastAPI)       │
│                         │
│  - Parse SSML tags      │
│  - Extract metadata     │
│  - Clean text           │
│  - Generate instructions│
└────────┬────────────────┘
         │
         │ Processed chunks + metadata
         ▼
┌─────────────────────────┐
│   TTS Orchestrator      │
│                         │
│  - Route to services    │
│  - Apply parameters     │
│  - Manage chunks        │
└────────┬────────────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌─────────┐ ┌──────────┐
│ Kokoro  │ │OpenVoice │
│  TTS    │ │          │
└────┬────┘ └────┬─────┘
     │           │
     └─────┬─────┘
           │ Audio chunks
           ▼
┌─────────────────────────┐
│  Audio Post-Processor   │
│                         │
│  - Apply pauses         │
│  - Adjust speed         │
│  - Merge chunks         │
│  - Apply effects        │
└────────┬────────────────┘
         │
         │ Final audio
         ▼
┌─────────────────┐
│   Output File   │
│   (.wav/.mp3)   │
└─────────────────┘
```

---

## Tags SSML Suportadas

### Fase 1 (MVP) - Foco em pt-BR

| Tag | Descrição | Implementação | Prioridade |
|-----|-----------|---------------|------------|
| `<break time="Xs"/>` | Pausas de duração específica | Inserir silêncio no áudio | 🔴 Alta |
| `<prosody rate="">` | Velocidade da fala | Parâmetro `speed` OpenVoice V2 | 🔴 Alta |
| `<prosody pitch="">` | Tom da voz | Parâmetro `pitch` OpenVoice V2 | 🟡 Média |
| `<phoneme>` | Pronúncia fonética (pt-BR) | Dicionário IPA/substituição | 🟡 Média |
| `<emphasis>` | Ênfase em palavras | Marcação para pós-processamento | 🟢 Baixa |

### Fase 2 (Futuro) - Expansão

| Tag | Descrição | Implementação | Bloqueador |
|-----|-----------|---------------|------------|
| `<emotion>` | Controle emocional | OpenVoice V1 + V2 híbrido | Dataset pt-BR emocional |
| `<prosody volume="">` | Volume | Normalização de áudio | - |
| `<voice>` | Troca de voz | Múltiplos modelos/speakers | - |
| `<audio>` | Inserir áudio externo | Merge de arquivos | - |
| `<say-as>` | Números/datas em pt-BR | Pré-processamento | - |
| `<lang>` | Suporte multilíngue | Detecção de idioma | - |

---

## Aproveitamento de Capacidades Nativas

### OpenVoice - Parâmetros Nativos

O OpenVoice oferece controles que podemos mapear diretamente do SSML:

| SSML | OpenVoice V2 | Range | Notas |
|------|--------------|-------|-------|
| `<prosody rate="slow">` | `speed: 0.8` | 0.5 - 2.0 | ✅ Suportado |
| `<prosody rate="fast">` | `speed: 1.2` | 0.5 - 2.0 | ✅ Suportado |
| `<prosody pitch="-3">` | `pitch: -3` | -12 a +12 | ✅ Suportado |
| `<prosody pitch="+3">` | `pitch: +3` | -12 a +12 | ✅ Suportado |
| `<emotion type="sad">` | ❌ Não direto | - | Apenas V1 (inglês) |

**Vantagens**: 
- ✅ Não precisamos processar áudio para velocidade/pitch!
- ✅ Qualidade superior com parâmetros nativos

**Limitações**:
- ❌ OpenVoice V2 não tem controle direto de emoção
- 🟡 Emoções disponíveis apenas em V1 (inglês apenas)
- 🟡 Workflow híbrido V1→V2 possível mas complexo
- 🇧🇷 **Para pt-BR**: V2 é a única opção viável (V1 não suporta português)

### Kokoro TTS - Limitações

Kokoro TTS **NÃO oferece** controles nativos:
- ❌ Sem parâmetro de velocidade
- ❌ Sem parâmetro de pitch
- ❌ Sem controle de emoção

**Solução**: Pós-processamento de áudio para Kokoro

### Estratégia Híbrida

```python
if service == "openvoice":
    # Usar parâmetros nativos
    params = {
        "speed": ssml_speed,
        "pitch": ssml_pitch
    }
elif service == "kokoro":
    # Pós-processar áudio
    audio = apply_speed(audio, ssml_speed)
    audio = apply_pitch(audio, ssml_pitch)
```

---

## Implementação Técnica

### 1. SSML Parser Service

**Tecnologia**: Python + FastAPI + BeautifulSoup/lxml  
**Responsabilidades**:
- Validar SSML XML
- Extrair tags e atributos
- Gerar instruções de processamento
- Limpar texto para TTS

**Exemplo de Entrada (pt-BR)**:
```xml
<speak>
  Capítulo 1: O Início.
  <break time="2s"/>
  "Olá", disse <emphasis>Maria</emphasis>.
  <break time="1s"/>
  Ela estava <prosody rate="slow" pitch="-2">muito cansada</prosody>.
  <break time="0.5s"/>
  <phoneme alphabet="ipa" ph="ʒoˈɐ̃w">João</phoneme> chegou correndo.
</speak>
```

**Exemplo de Saída**:
```json
{
  "chunks": [
    {
      "text": "Capítulo 1: O Início.",
      "metadata": {}
    },
    {
      "type": "pause",
      "duration": 2.0
    },
    {
      "text": "Olá, disse Maria.",
      "metadata": {
        "emphasis": ["Maria"]
      }
    },
    {
      "type": "pause",
      "duration": 1.0
    },
    {
      "text": "Ela estava muito cansada.",
      "metadata": {
        "rate": "slow",
        "speed": 0.8
      }
    }
  ]
}
```

### 2. TTS Orchestrator

**Responsabilidades**:
- Processar chunks sequencialmente
- Aplicar parâmetros aos serviços TTS
- Gerenciar cache de áudio
- Coordenar múltiplos serviços

### 3. Audio Post-Processor

**Tecnologia**: Python + pydub/ffmpeg  
**Responsabilidades**:
- Inserir pausas (silêncio)
- Ajustar velocidade (time stretching)
- Normalizar volume
- Concatenar chunks
- Exportar formato final

---

## Estrutura de Arquivos

```
src/
├── ssml/
│   ├── __init__.py
│   ├── parser.py           # Parser SSML
│   ├── validator.py        # Validação XML
│   ├── processor.py        # Processador de instruções
│   └── dictionaries.py     # Dicionários de pronúncia
├── tts/
│   ├── __init__.py
│   ├── orchestrator.py     # Orquestrador TTS
│   ├── kokoro_client.py    # Cliente Kokoro
│   └── openvoice_client.py # Cliente OpenVoice
├── audio/
│   ├── __init__.py
│   ├── post_processor.py   # Pós-processamento
│   ├── effects.py          # Efeitos de áudio
│   └── merger.py           # Merge de chunks
└── ssml_server.py          # FastAPI server

tests/
├── test_ssml_parser.py
├── test_orchestrator.py
└── test_audio_processor.py

docs/
├── SSML_GUIDE.md           # Guia de uso SSML
└── SSML_API.md             # Documentação da API
```

---

## API REST

### Endpoint Principal

**POST** `/api/v1/tts/ssml`

**Request**:
```json
{
  "text": "<speak>Texto com <break time='1s'/> SSML</speak>",
  "voice": "af_sarah",
  "service": "kokoro",
  "output_format": "wav",
  "pronunciation_dict": "custom_dict.pls"
}
```

**Response**:
```json
{
  "audio_url": "http://localhost:8888/outputs/audio_123.wav",
  "duration": 15.3,
  "chunks_processed": 5,
  "metadata": {
    "pauses": 2,
    "emphasis_count": 3,
    "total_characters": 150
  }
}
```

### Endpoints Auxiliares

- **POST** `/api/v1/ssml/validate` - Validar SSML
- **POST** `/api/v1/ssml/preview` - Preview de processamento
- **GET** `/api/v1/dictionaries` - Listar dicionários
- **POST** `/api/v1/dictionaries` - Upload de dicionário

---

## Integração com N8N

### Workflow Atualizado

```
┌──────────────┐
│ HTTP Request │ → Input: Texto com SSML
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ SSML Service │ → POST /api/v1/tts/ssml
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Wait for     │ → Aguardar processamento
│ Completion   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Download     │ → Baixar áudio final
│ Audio        │
└──────────────┘
```

---

## Dicionários de Pronúncia

### Formato Suportado

**.pls (Pronunciation Lexicon Specification)**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<lexicon version="1.0"
      xmlns="http://www.w3.org/2005/01/pronunciation-lexicon"
      alphabet="ipa" xml:lang="pt-BR">
  <lexeme>
    <grapheme>DarkChannel</grapheme>
    <phoneme>daɾk ʃænəl</phoneme>
  </lexeme>
  <lexeme>
    <grapheme>N8N</grapheme>
    <alias>en oito en</alias>
  </lexeme>
</lexicon>
```

### Localização

- Dicionários armazenados em: `src/ssml/dictionaries/`
- Suporte a múltiplos idiomas
- Cache em memória para performance

---

## Considerações de Performance

### Otimizações

1. **Cache de Chunks**: Reutilizar áudio de textos repetidos
2. **Processamento Paralelo**: Chunks independentes em paralelo
3. **Streaming**: Retornar chunks conforme processados
4. **Pré-processamento**: Validar SSML antes de TTS

### Métricas Esperadas

- **Latência adicional**: +200-500ms (parsing + pós-processamento)
- **Throughput**: 100 requisições/minuto
- **Cache hit rate**: 30-40% em audiolivros

---

## Alternativas Consideradas

### 1. Usar Serviço SSML de Terceiros (ElevenLabs, Google TTS)

**Prós**:
- Suporte nativo completo
- Menor desenvolvimento

**Contras**:
- Custo elevado
- Dependência externa
- Menos controle

**Decisão**: Rejeitado - Queremos controle total e custos menores

### 2. Implementar SSML Direto nos Serviços TTS

**Prós**:
- Integração mais profunda

**Contras**:
- Modificar código de terceiros
- Difícil manutenção
- Kokoro/OpenVoice não suportam nativamente

**Decisão**: Rejeitado - Middleware é mais flexível

### 3. ❌ Apenas Pré-processamento de Texto (Sem Pós-processamento)

**Prós**:
- Simples de implementar
- Menos dependências

**Contras**:
- Controle limitado de pausas
- Sem inserção precisa de silêncio
- Depende totalmente das capacidades do TTS

**Decisão**: Rejeitado - Precisamos de pausas precisas via pós-processamento

**Nota**: Velocidade e pitch SERÃO mapeados para parâmetros nativos do OpenVoice!

---

## Riscos e Mitigações

| Risco | Impacto | Probabilidade | Mitigação |
|-------|---------|---------------|-----------|
| SSML inválido quebra processamento | Alto | Média | Validação rigorosa + fallback para texto plano |
| Latência aumentada | Médio | Alta | Cache agressivo + processamento paralelo |
| Incompatibilidade entre serviços | Médio | Baixa | Abstração de features por serviço |
| Complexidade de manutenção | Médio | Média | Testes automatizados + documentação |

---

## Cronograma de Implementação

### Sprint 1 (1 semana)
- [ ] Setup do projeto SSML service
- [ ] Parser básico de SSML
- [ ] Suporte a `<break>` e `<prosody rate>`
- [ ] Testes unitários

### Sprint 2 (1 semana)
- [ ] Integração com Kokoro TTS
- [ ] Audio post-processor
- [ ] API REST básica
- [ ] Testes de integração

### Sprint 3 (1 semana)
- [ ] Suporte a `<phoneme>` e dicionários
- [ ] Integração com OpenVoice
- [ ] Cache de chunks
- [ ] Documentação

### Sprint 4 (1 semana)
- [ ] Workflows N8N atualizados
- [ ] Testes end-to-end
- [ ] Otimizações de performance
- [ ] Deploy e monitoramento

---

## Métricas de Sucesso

- ✅ Suportar 80% das tags SSML comuns
- ✅ Latência adicional < 500ms
- ✅ 95% de compatibilidade com texto plano
- ✅ Reduzir tempo de produção de audiolivros em 40%
- ✅ Satisfação do usuário > 4.5/5

---

## Referências

- [W3C SSML Specification](https://www.w3.org/TR/speech-synthesis11/)
- [ElevenLabs SSML Documentation](https://elevenlabs.io/docs/best-practices/prompting/controls)
- [Google Cloud TTS SSML](https://cloud.google.com/text-to-speech/docs/ssml)
- [Amazon Polly SSML](https://docs.aws.amazon.com/polly/latest/dg/supportedtags.html)

---

## Aprovação

- [x] ✅ Arquiteto de Software - Aprovado em 2025-11-09
- [x] ✅ Tech Lead - Aprovado em 2025-11-09
- [x] ✅ Product Owner - Aprovado em 2025-11-09
- [x] ✅ Equipe de Desenvolvimento - Aprovado em 2025-11-09

**Decisão Final**: ✅ **APROVADO PARA IMPLEMENTAÇÃO**

---

## Histórico de Decisões

| Data | Status | Observações |
|------|--------|-------------|
| 2025-11-09 | Proposto | ADR criado e submetido para aprovação |
| 2025-11-09 | **Aceito** | Aprovado unanimemente - Iniciar implementação |

---

**Última Atualização**: 2025-11-09  
**Próxima Revisão**: Após Sprint 1  
**Início da Implementação**: 2025-11-09

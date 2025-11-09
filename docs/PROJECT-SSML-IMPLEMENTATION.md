# 🎯 Projeto: Implementação de Suporte SSML

**Projeto**: DarkChannel SSML Support  
**Versão**: 1.0  
**Data Início**: 2025-11-09  
**Duração Estimada**: 4 semanas  
**Status**: 🚀 Em Desenvolvimento  
**Foco**: 🇧🇷 Português do Brasil (pt-BR)

---

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Objetivos](#objetivos)
3. [Escopo](#escopo)
4. [Arquitetura](#arquitetura)
5. [Componentes](#componentes)
6. [Cronograma](#cronograma)
7. [Recursos Necessários](#recursos-necessários)
8. [Riscos](#riscos)

---

## 🎯 Visão Geral

Implementar suporte completo a SSML (Speech Synthesis Markup Language) no DarkChannel Stack para permitir controle granular sobre a geração de áudio em audiolivros e narrações **em Português do Brasil**.

### Problema Atual

- Sem controle de pausas precisas
- Pronúncia incorreta de nomes próprios brasileiros
- Impossível controlar velocidade e tom
- Velocidade fixa de narração

### Solução Proposta

Middleware SSML que processa tags antes do TTS e aproveita capacidades nativas do OpenVoice V2.

### ✅ Infraestrutura Confirmada

**OpenVoice V2 já está configurado**:
- ✅ Suporte nativo a pt-BR
- ✅ Parâmetros `speed` e `pitch` disponíveis
- ✅ Configurado em `Dockerfile.openvoice`
- ✅ Não requer migração ou mudanças estruturais

---

## 🎯 Objetivos

### Objetivos Principais

1. ✅ Suportar tags SSML essenciais (`<break>`, `<phoneme>`, `<prosody>`)
2. ✅ Integração transparente com Kokoro TTS e OpenVoice
3. ✅ API REST para processamento SSML
4. ✅ Workflows N8N atualizados

### Objetivos Secundários

1. Cache de chunks de áudio
2. Dicionários de pronúncia customizáveis
3. Documentação completa
4. Testes automatizados (>80% cobertura)

### Métricas de Sucesso

- Latência adicional < 500ms
- Suporte a 80% das tags SSML comuns
- Redução de 40% no tempo de produção de audiolivros
- Zero breaking changes em workflows existentes

---

## 📦 Escopo

### Incluído (In Scope)

✅ Parser SSML completo  
✅ Suporte a tags: `<break>`, `<phoneme>`, `<prosody>`, `<emphasis>`  
✅ Integração com Kokoro TTS  
✅ Integração com OpenVoice  
✅ API REST  
✅ Pós-processamento de áudio  
✅ Dicionários de pronúncia (.pls)  
✅ Workflows N8N  
✅ Documentação  
✅ Testes unitários e integração  

### Excluído (Out of Scope)

❌ Tags avançadas (`<audio>`, `<voice>`, `<say-as>`) - Fase 2  
❌ Interface gráfica para edição SSML  
❌ Suporte a outros serviços TTS (Google, AWS)  
❌ Streaming em tempo real  
❌ Análise de sentimento automática  

---

## 🏗️ Arquitetura

### Diagrama de Componentes

```
┌─────────────────────────────────────────────────────────┐
│                    N8N Workflows                        │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ HTTP POST
                     ▼
┌─────────────────────────────────────────────────────────┐
│              SSML Service (Port 8888)                   │
│  ┌─────────────────────────────────────────────────┐   │
│  │  FastAPI Application                            │   │
│  │  ┌──────────────┐  ┌──────────────┐            │   │
│  │  │ SSML Parser  │  │  Validator   │            │   │
│  │  └──────┬───────┘  └──────┬───────┘            │   │
│  │         │                  │                     │   │
│  │         └────────┬─────────┘                     │   │
│  │                  ▼                               │   │
│  │         ┌─────────────────┐                     │   │
│  │         │  TTS Orchestrator│                     │   │
│  │         └────────┬─────────┘                     │   │
│  └──────────────────┼─────────────────────────────┘   │
└───────────────────┼─────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
        ▼                         ▼
┌──────────────┐          ┌──────────────┐
│ Kokoro TTS   │          │  OpenVoice   │
│ Port 8880    │          │  Port 8000   │
└──────┬───────┘          └──────┬───────┘
        │                         │
        └────────────┬────────────┘
                     │ Audio chunks
                     ▼
        ┌─────────────────────────┐
        │  Audio Post-Processor   │
        │  - Insert pauses        │
        │  - Adjust speed         │
        │  - Merge chunks         │
        └────────┬────────────────┘
                 │
                 ▼
        ┌─────────────────┐
        │  Output Audio   │
        │  (.wav/.mp3)    │
        └─────────────────┘
```

---

## 🧩 Componentes

### 1. SSML Parser (`src/ssml/parser.py`)

**Responsabilidades**:
- Parsear XML SSML
- Extrair tags e atributos
- Validar estrutura
- Gerar chunks processáveis

**Tecnologias**: Python, lxml, BeautifulSoup

**Exemplo de Uso**:
```python
from ssml.parser import SSMLParser

parser = SSMLParser()
result = parser.parse("""
<speak>
  Olá <break time="1s"/> mundo!
</speak>
""")

# Output:
# [
#   {"type": "text", "content": "Olá"},
#   {"type": "break", "duration": 1.0},
#   {"type": "text", "content": "mundo!"}
# ]
```

### 2. TTS Orchestrator (`src/tts/orchestrator.py`)

**Responsabilidades**:
- Processar chunks sequencialmente
- Rotear para serviço apropriado
- Aplicar parâmetros (speed, voice)
- Gerenciar cache

**Exemplo**:
```python
from tts.orchestrator import TTSOrchestrator

orchestrator = TTSOrchestrator()
audio_chunks = await orchestrator.process_chunks(
    chunks=parsed_chunks,
    service="kokoro",
    voice="af_sarah"
)
```

### 3. Audio Post-Processor (`src/audio/post_processor.py`)

**Responsabilidades**:
- Inserir pausas (silêncio)
- Ajustar velocidade (time stretching)
- Normalizar volume
- Concatenar chunks

**Tecnologias**: pydub, ffmpeg

**Exemplo**:
```python
from audio.post_processor import AudioPostProcessor

processor = AudioPostProcessor()
final_audio = processor.merge_chunks(
    audio_chunks,
    pauses=[1.0, 0.5],
    output_format="wav"
)
```

### 4. FastAPI Server (`src/ssml_server.py`)

**Endpoints**:

```python
POST /api/v1/tts/ssml
POST /api/v1/ssml/validate
POST /api/v1/ssml/preview
GET  /api/v1/dictionaries
POST /api/v1/dictionaries
GET  /api/v1/health
```

---

## 📅 Cronograma Detalhado

### Sprint 1: Fundação (Semana 1)

**Objetivo**: Setup e parser básico

| Dia | Tarefa | Responsável | Horas |
|-----|--------|-------------|-------|
| 1 | Setup projeto Python + FastAPI | Dev | 4h |
| 1 | Estrutura de pastas e dependências | Dev | 2h |
| 2 | Implementar SSML Parser básico | Dev | 6h |
| 3 | Suporte a tag `<break>` | Dev | 4h |
| 3 | Testes unitários parser | Dev | 2h |
| 4 | Suporte a tag `<prosody rate>` | Dev | 4h |
| 4 | Validador SSML | Dev | 2h |
| 5 | Integração com lxml | Dev | 3h |
| 5 | Code review e ajustes | Dev | 3h |

**Entregáveis**:
- ✅ Parser SSML funcional
- ✅ Suporte a `<break>` e `<prosody>`
- ✅ Testes unitários (>70% cobertura)

### Sprint 2: Integração TTS (Semana 2)

| Dia | Tarefa | Responsável | Horas |
|-----|--------|-------------|-------|
| 1 | Implementar TTS Orchestrator | Dev | 6h |
| 2 | Cliente Kokoro TTS | Dev | 4h |
| 2 | Cliente OpenVoice | Dev | 4h |
| 3 | Audio Post-Processor básico | Dev | 6h |
| 4 | Inserção de pausas (silêncio) | Dev | 4h |
| 4 | Ajuste de velocidade | Dev | 4h |
| 5 | Testes de integração | Dev | 6h |

**Entregáveis**:
- ✅ Integração com Kokoro e OpenVoice
- ✅ Pós-processamento de áudio
- ✅ Pipeline end-to-end funcional

### Sprint 3: Features Avançadas (Semana 3)

| Dia | Tarefa | Responsável | Horas |
|-----|--------|-------------|-------|
| 1 | Suporte a `<phoneme>` | Dev | 6h |
| 2 | Parser de dicionários .pls | Dev | 6h |
| 3 | Sistema de cache de chunks | Dev | 4h |
| 3 | Suporte a `<emphasis>` | Dev | 4h |
| 4 | API REST completa | Dev | 6h |
| 5 | Documentação da API | Dev | 4h |
| 5 | Testes de performance | Dev | 4h |

**Entregáveis**:
- ✅ Suporte a pronúncia customizada
- ✅ API REST documentada
- ✅ Sistema de cache

### Sprint 4: Finalização (Semana 4)

| Dia | Tarefa | Responsável | Horas |
|-----|--------|-------------|-------|
| 1 | Workflows N8N atualizados | Dev | 4h |
| 1 | Dockerfile para SSML service | Dev | 2h |
| 2 | docker-compose.yml atualizado | Dev | 2h |
| 2 | Testes end-to-end | Dev | 4h |
| 3 | Documentação de usuário | Dev | 4h |
| 3 | Guia SSML | Dev | 2h |
| 4 | Otimizações de performance | Dev | 4h |
| 4 | Code review final | Dev | 2h |
| 5 | Deploy e validação | Dev | 4h |
| 5 | Apresentação para stakeholders | PM | 2h |

**Entregáveis**:
- ✅ Sistema completo em produção
- ✅ Documentação completa
- ✅ Workflows prontos para uso

---

## 💻 Stack Tecnológico

### Backend

- **Python 3.10+**
- **FastAPI** - Framework web
- **lxml** - Parser XML
- **BeautifulSoup4** - Manipulação HTML/XML
- **pydub** - Processamento de áudio
- **ffmpeg** - Conversão e efeitos de áudio
- **aiohttp** - Cliente HTTP assíncrono
- **redis** (opcional) - Cache distribuído

### Testes

- **pytest** - Framework de testes
- **pytest-asyncio** - Testes assíncronos
- **pytest-cov** - Cobertura de código
- **httpx** - Cliente HTTP para testes

### DevOps

- **Docker** - Containerização
- **docker-compose** - Orquestração local
- **GitHub Actions** (futuro) - CI/CD

---

## 📚 Recursos Necessários

### Humanos

- 1 Desenvolvedor Python Senior (40h/semana)
- 1 DevOps (8h/semana)
- 1 QA/Tester (16h/semana)
- 1 Tech Writer (8h/semana)

### Infraestrutura

- Servidor de desenvolvimento (já existe)
- Docker containers
- Storage para cache (~10GB)

### Ferramentas

- VS Code / PyCharm
- Postman / Insomnia (testes API)
- Audacity (validação de áudio)

---

## ⚠️ Riscos e Mitigações

| # | Risco | Impacto | Prob. | Mitigação |
|---|-------|---------|-------|-----------|
| 1 | SSML mal-formado quebra sistema | Alto | Média | Validação rigorosa + fallback |
| 2 | Performance degradada | Médio | Alta | Cache + processamento paralelo |
| 3 | Incompatibilidade entre TTS | Médio | Baixa | Abstração de features |
| 4 | Atraso no cronograma | Alto | Média | Buffer de 20% no tempo |
| 5 | Bugs em produção | Alto | Baixa | Testes extensivos + staging |

---

## ✅ Critérios de Aceitação

### Funcionalidade

- [ ] Parser processa SSML válido sem erros
- [ ] Suporte a tags: `<break>`, `<phoneme>`, `<prosody>`, `<emphasis>`
- [ ] Integração funcional com Kokoro e OpenVoice
- [ ] Pausas inseridas com precisão de ±100ms
- [ ] Velocidade ajustável de 0.7x a 1.2x
- [ ] Dicionários .pls carregados corretamente

### Performance

- [ ] Latência adicional < 500ms
- [ ] Throughput > 50 req/min
- [ ] Cache hit rate > 30%
- [ ] Uso de memória < 512MB

### Qualidade

- [ ] Cobertura de testes > 80%
- [ ] Zero erros críticos em produção
- [ ] Documentação completa
- [ ] Code review aprovado

---

## 📖 Documentação a Produzir

1. **SSML_GUIDE.md** - Guia de uso para usuários
2. **SSML_API.md** - Documentação da API REST
3. **DEVELOPMENT.md** - Guia para desenvolvedores
4. **CHANGELOG.md** - Histórico de mudanças
5. **README.md** (atualizado) - Overview do projeto

---

## 🚀 Plano de Deploy

### Fase 1: Desenvolvimento Local
- Docker Compose local
- Testes manuais

### Fase 2: Staging
- Deploy em ambiente de teste
- Validação com usuários beta

### Fase 3: Produção
- Deploy gradual (canary)
- Monitoramento intensivo
- Rollback plan pronto

---

## 📊 KPIs e Monitoramento

### Métricas Técnicas

- Tempo médio de processamento
- Taxa de erro
- Cache hit rate
- Uso de CPU/memória

### Métricas de Negócio

- Tempo de produção de audiolivros
- Satisfação do usuário
- Número de audiolivros produzidos
- Taxa de adoção da feature

---

## 🎓 Treinamento

### Para Desenvolvedores

- Workshop sobre SSML (2h)
- Code walkthrough (1h)
- Pair programming sessions

### Para Usuários

- Tutorial em vídeo
- Documentação com exemplos
- FAQ

---

**Aprovado por**: _____________  
**Data**: _____________

---

**Próximos Passos**:
1. Aprovar este documento
2. Alocar recursos
3. Iniciar Sprint 1

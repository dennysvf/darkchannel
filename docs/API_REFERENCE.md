# 📖 API Reference - DarkChannel Stack

Manual completo de APIs com todos os endpoints, parâmetros e exemplos práticos.

---

# 🎤 Kokoro TTS API

Base URL: `http://localhost:8880` (ou `http://kokoro-tts:8880` dentro do Docker)

## 🌍 Suporte a Idiomas

Kokoro TTS possui **suporte nativo para Português do Brasil** e outros idiomas:

| Código | Idioma | Qualidade | Status |
|--------|--------|-----------|--------|
| `pt` / `pt-br` | **Português (Brasil)** | ⭐⭐⭐⭐⭐ | ✅ Nativo |
| `en` | English | ⭐⭐⭐⭐⭐ | ✅ Nativo |
| `es` | Español | ⭐⭐⭐⭐ | ✅ Suportado |
| `fr` | Français | ⭐⭐⭐⭐ | ✅ Suportado |
| `de` | Deutsch | ⭐⭐⭐⭐ | ✅ Suportado |
| `it` | Italiano | ⭐⭐⭐⭐ | ✅ Suportado |
| `ja` | 日本語 | ⭐⭐⭐⭐ | ✅ Suportado |
| `zh` | 中文 | ⭐⭐⭐⭐ | ✅ Suportado |

**Recomendação:** Para português do Brasil, use `lang_code: "pt"` ou deixe em branco para detecção automática.

---

## 1. Síntese de Voz (OpenAI Compatible)

### Endpoint
```
POST /v1/audio/speech
```

### Headers
```
Content-Type: application/json
```

### Parâmetros

| Parâmetro | Tipo | Obrigatório | Valores Possíveis | Padrão | Descrição |
|-----------|------|-------------|-------------------|--------|-----------|
| `model` | string | Sim | `kokoro`, `tts-1`, `tts-1-hd` | - | Modelo de TTS a usar |
| `input` | string | Sim | Qualquer texto | - | Texto para sintetizar (máx 5000 caracteres) |
| `voice` | string | Não | Ver tabela abaixo | `af` | Voz a usar para síntese |
| `speed` | number | Não | `0.25` - `4.0` | `1.0` | Velocidade da fala |
| `response_format` | string | Não | `mp3`, `opus`, `flac`, `wav`, `pcm` | `mp3` | Formato do áudio de saída |
| `stream` | boolean | Não | `true`, `false` | `true` | Streaming em tempo real |
| `lang_code` | string | Não | `pt`, `en`, `es`, `fr`, `de`, `it`, `ja`, `zh` | Auto | Código do idioma |

### Vozes Disponíveis

**Todas as vozes funcionam perfeitamente em Português do Brasil!** 🇧🇷

#### Vozes Femininas Americanas (AF)
| Código | Nome | Características | Melhor Para | PT-BR |
|--------|------|-----------------|-------------|-------|
| `af` | Base Feminina | Neutra, clara | Uso geral | ✅ |
| `af_sarah` | Sarah | Profissional, articulada | Apresentações, tutoriais | ✅ ⭐ |
| `af_nicole` | Nicole | Suave, amigável | Audiolivros, narrativas | ✅ |
| `af_sky` | Sky | Jovem, energética | Conteúdo dinâmico, anúncios | ✅ |
| `af_bella` | Bella | Calorosa, expressiva | Histórias, podcasts | ✅ |

#### Vozes Masculinas Americanas (AM)
| Código | Nome | Características | Melhor Para | PT-BR |
|--------|------|-----------------|-------------|-------|
| `am` | Base Masculina | Neutra, grave | Uso geral | ✅ |
| `am_adam` | Adam | Profunda, autoritária | Documentários, notícias | ✅ ⭐ |
| `am_michael` | Michael | Enérgica, dinâmica | Esportes, ação | ✅ |
| `am_eric` | Eric | Calma, confiável | Meditação, relaxamento | ✅ |

#### Vozes Britânicas (BF/BM)
| Código | Nome | Características | Melhor Para | PT-BR |
|--------|------|-----------------|-------------|-------|
| `bf` | Base Feminina UK | Sotaque britânico | Conteúdo formal UK | ✅ |
| `bf_emma` | Emma | Elegante, refinada | Literatura clássica | ✅ |
| `bm` | Base Masculina UK | Sotaque britânico | Documentários BBC-style | ✅ |
| `bm_george` | George | Distinto, formal | Conteúdo acadêmico | ✅ |

**⭐ = Recomendado para Português do Brasil**

### Formatos de Áudio

| Formato | Extensão | Qualidade | Tamanho | Uso Recomendado |
|---------|----------|-----------|---------|-----------------|
| `wav` | .wav | Máxima (sem perda) | Grande | Produção, edição |
| `flac` | .flac | Alta (sem perda) | Médio | Arquivamento |
| `mp3` | .mp3 | Boa (com perda) | Pequeno | Web, streaming |
| `opus` | .opus | Ótima (com perda) | Muito pequeno | Streaming, VoIP |
| `pcm` | .pcm | Raw (sem header) | Grande | Processamento |

### Velocidades Recomendadas

| Valor | Descrição | Uso |
|-------|-----------|-----|
| `0.25` | Muito lento | Aprendizado de idiomas |
| `0.5` | Lento | Didático, explicações |
| `0.75` | Um pouco lento | Audiolivros técnicos |
| `1.0` | **Normal** | Uso geral (padrão) |
| `1.25` | Um pouco rápido | Podcasts |
| `1.5` | Rápido | Revisão rápida |
| `2.0` | Muito rápido | Consumo acelerado |
| `4.0` | Máximo | Casos especiais |

### Exemplo 1: Básico (Português)

**Request:**
```bash
curl -X POST http://localhost:8880/v1/audio/speech \
  -H "Content-Type: application/json" \
  -d '{
    "model": "kokoro",
    "input": "Olá! Bem-vindo ao DarkChannel Stack. Este é um sistema completo de automação com síntese de voz.",
    "voice": "af_sarah",
    "speed": 1.0,
    "response_format": "wav"
  }' \
  --output audio.wav
```

**Python:**
```python
import requests

url = "http://localhost:8880/v1/audio/speech"
payload = {
    "model": "kokoro",
    "input": "Olá! Bem-vindo ao DarkChannel Stack.",
    "voice": "af_sarah",
    "speed": 1.0,
    "response_format": "wav"
}

response = requests.post(url, json=payload)
with open("audio.wav", "wb") as f:
    f.write(response.content)

print("✅ Áudio gerado com sucesso!")
```

**N8N (HTTP Request Node):**
```json
{
  "method": "POST",
  "url": "http://kokoro-tts:8880/v1/audio/speech",
  "sendBody": true,
  "contentType": "json",
  "bodyParameters": {
    "parameters": [
      {"name": "model", "value": "kokoro"},
      {"name": "input", "value": "={{ $json.text }}"},
      {"name": "voice", "value": "af_sarah"},
      {"name": "speed", "value": "1.0"},
      {"name": "response_format", "value": "wav"}
    ]
  },
  "options": {
    "response": {
      "response": {
        "responseFormat": "file"
      }
    }
  }
}
```

### Exemplo 2: Com Idioma Específico

**Request:**
```json
{
  "model": "kokoro",
  "input": "Hello! This is a test in English.",
  "voice": "af_sarah",
  "speed": 1.0,
  "response_format": "mp3",
  "lang_code": "en"
}
```

### Exemplo 3: Streaming

**Request:**
```json
{
  "model": "kokoro",
  "input": "Este é um texto longo que será transmitido em tempo real conforme é gerado.",
  "voice": "am_adam",
  "speed": 1.0,
  "stream": true,
  "response_format": "mp3"
}
```

### Exemplo 4: Audiolivro (Velocidade Ajustada)

**Request:**
```json
{
  "model": "kokoro",
  "input": "Capítulo 1: Era uma vez, em um reino distante...",
  "voice": "af_nicole",
  "speed": 0.9,
  "response_format": "wav"
}
```

### Exemplo 5: Notícias (Voz Autoritária)

**Request:**
```json
{
  "model": "kokoro",
  "input": "Últimas notícias: O mercado apresentou alta de 2% hoje.",
  "voice": "am_adam",
  "speed": 1.1,
  "response_format": "mp3"
}
```

---

## 2. Síntese com Timestamps

### Endpoint
```
POST /v1/audio/speech/captioned
```

### Parâmetros Adicionais

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `return_timestamps` | boolean | Retorna timestamps de palavras (padrão: `true`) |

### Exemplo

**Request:**
```json
{
  "model": "kokoro",
  "input": "Olá mundo! Como você está?",
  "voice": "af_sarah",
  "return_timestamps": true
}
```

**Response:**
```json
{
  "audio": "<binary_data>",
  "timestamps": [
    {"word": "Olá", "start": 0.0, "end": 0.5},
    {"word": "mundo", "start": 0.5, "end": 1.0},
    {"word": "Como", "start": 1.2, "end": 1.5},
    {"word": "você", "start": 1.5, "end": 1.8},
    {"word": "está", "start": 1.8, "end": 2.2}
  ]
}
```

---

## 3. Health Check

### Endpoint
```
GET /health
```

### Response
```json
{
  "status": "healthy",
  "service": "Kokoro TTS",
  "version": "0.2.2"
}
```

---

# 🔄 Kokoro Wrapper API (MinIO Integration)

Base URL: `http://localhost:8881` (ou `http://kokoro-wrapper:8881` dentro do Docker)

**Wrapper Flask que adiciona integração MinIO ao Kokoro TTS**

---

## 1. Síntese com Upload para MinIO

### Endpoint
```
POST /tts-to-s3
```

### Headers
```
Content-Type: application/json
```

### Parâmetros

| Parâmetro | Tipo | Obrigatório | Valores Possíveis | Padrão | Descrição |
|-----------|------|-------------|-------------------|--------|-----------||
| `text` | string | Sim | Qualquer texto | - | Texto para sintetizar |
| `job_id` | string | Sim | UUID v4 | - | ID único do job |
| `chunk_index` | integer | Sim | 0-999 | - | Índice do chunk |
| `lang` | string | Não | `pt-br`, `en`, `es`, etc | `pt-br` | Idioma |
| `voice` | string | Não | Ver tabela de vozes | `af_sarah` | Voz a usar |
| `speed` | number | Não | `0.25` - `4.0` | `1.0` | Velocidade |

### Response

```json
{
  "success": true,
  "s3_key": "job-id/chunks/chunk-000.wav",
  "bucket": "darkchannel-jobs",
  "s3_url": "s3://darkchannel-jobs/job-id/chunks/chunk-000.wav",
  "download_url": "http://localhost:9000/darkchannel-jobs/...",
  "download_expires_in": 3600,
  "job_id": "job-id",
  "chunk_index": 0
}
```

### Exemplo 1: Português do Brasil

**Request:**
```bash
curl -X POST http://localhost:8881/tts-to-s3 \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Olá! Bem-vindo ao sistema de síntese de voz com armazenamento em nuvem.",
    "job_id": "550e8400-e29b-41d4-a716-446655440000",
    "chunk_index": 0,
    "lang": "pt-br",
    "voice": "af_sarah",
    "speed": 1.0
  }'
```

**Python:**
```python
import requests
import uuid

url = "http://localhost:8881/tts-to-s3"
payload = {
    "text": "Olá! Bem-vindo ao sistema.",
    "job_id": str(uuid.uuid4()),
    "chunk_index": 0,
    "lang": "pt-br",
    "voice": "af_sarah",
    "speed": 1.0
}

response = requests.post(url, json=payload)
result = response.json()

print(f"✅ Upload concluído!")
print(f"📦 S3 Key: {result['s3_key']}")
print(f"🔗 Download: {result['download_url']}")
print(f"⏰ Expira em: {result['download_expires_in']}s")
```

**PowerShell:**
```powershell
$jobId = [guid]::NewGuid().ToString()
$body = @{
    text = "Olá! Bem-vindo ao sistema."
    job_id = $jobId
    chunk_index = 0
    lang = "pt-br"
    voice = "af_sarah"
    speed = 1.0
} | ConvertTo-Json

$response = Invoke-RestMethod `
    -Uri "http://localhost:8881/tts-to-s3" `
    -Method POST `
    -Body $body `
    -ContentType "application/json"

Write-Host "✅ Upload concluído!"
Write-Host "🔗 Download: $($response.download_url)"
```

### Exemplo 2: Voz Masculina Autoritária

```json
{
  "text": "Últimas notícias do mercado financeiro.",
  "job_id": "550e8400-e29b-41d4-a716-446655440001",
  "chunk_index": 0,
  "lang": "pt-br",
  "voice": "am_adam",
  "speed": 1.1
}
```

---

## 2. Gerar URL de Download

### Endpoint
```
GET /download-url/<job_id>/<chunk_index>
```

### Parâmetros

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------||
| `job_id` | string | ID do job |
| `chunk_index` | integer | Índice do chunk |

### Response

```json
{
  "download_url": "http://localhost:9000/darkchannel-jobs/...",
  "expires_in": 3600,
  "job_id": "job-id",
  "chunk_index": 0,
  "s3_key": "job-id/chunks/chunk-000.wav"
}
```

### Exemplo

```bash
curl http://localhost:8881/download-url/550e8400-e29b-41d4-a716-446655440000/0
```

**Python:**
```python
import requests

job_id = "550e8400-e29b-41d4-a716-446655440000"
chunk_index = 0

url = f"http://localhost:8881/download-url/{job_id}/{chunk_index}"
response = requests.get(url)
result = response.json()

print(f"🔗 Download URL: {result['download_url']}")
print(f"⏰ Expira em: {result['expires_in']}s")
```

---

## 3. Health Check

### Endpoint
```
GET /health
```

### Response
```json
{
  "status": "healthy",
  "kokoro_status": "connected",
  "minio_status": "connected"
}
```

---

# 🎙️ OpenVoice API

Base URL: `http://localhost:8000` (ou `http://openvoice:8000` dentro do Docker)

---

## 1. Health Check

### Endpoint
```
GET /health
```

### Response
```json
{
  "status": "healthy",
  "service": "OpenVoice API",
  "version": "1.0.0"
}
```

### Exemplo
```bash
curl http://localhost:8000/health
```

---

## 2. Status Detalhado

### Endpoint
```
GET /status
```

### Response
```json
{
  "status": "ready",
  "model": {
    "loaded": true,
    "checkpoints": {
      "v1_converter": false,
      "v2_converter": true
    },
    "ready_for_inference": true
  },
  "directories": {
    "inputs": true,
    "outputs": true,
    "references": true
  }
}
```

### Exemplo
```bash
curl http://localhost:8000/status
```

---

## 3. Listar Idiomas Suportados

### Endpoint
```
GET /languages
```

### Response
```json
{
  "supported_languages": [
    {
      "code": "pt-br",
      "name": "Português (Brasil)",
      "native": "Português do Brasil"
    },
    {
      "code": "en",
      "name": "English",
      "native": "English"
    },
    {
      "code": "es",
      "name": "Spanish",
      "native": "Español"
    },
    {
      "code": "fr",
      "name": "French",
      "native": "Français"
    },
    {
      "code": "zh",
      "name": "Chinese",
      "native": "中文"
    },
    {
      "code": "ja",
      "name": "Japanese",
      "native": "日本語"
    },
    {
      "code": "ko",
      "name": "Korean",
      "native": "한국어"
    }
  ]
}
```

### Idiomas Detalhados

| Código | Nome | Nome Nativo | Motor | Qualidade |
|--------|------|-------------|-------|-----------||
| `pt-br` | Português (Brasil) | Português do Brasil | gTTS | ⭐⭐⭐ |
| `en` | English | English | gTTS | ⭐⭐⭐ |
| `es` | Spanish | Español | gTTS | ⭐⭐⭐ |
| `fr` | French | Français | gTTS | ⭐⭐⭐ |
| `zh` | Chinese | 中文 | gTTS | ⭐⭐⭐ |
| `ja` | Japanese | 日本語 | gTTS | ⭐⭐⭐ |
| `ko` | Korean | 한국어 | gTTS | ⭐⭐⭐ |

**Nota:** OpenVoice atualmente usa gTTS (Google TTS) para síntese base. Futuramente será implementada clonagem de voz com OpenVoice V2.

---

## 4. Síntese com Upload para MinIO

### Endpoint
```
POST /synthesize-to-s3
```

### Headers
```
Content-Type: application/json
```

### Parâmetros

| Parâmetro | Tipo | Obrigatório | Valores Possíveis | Padrão | Descrição |
|-----------|------|-------------|-------------------|--------|-----------||
| `text` | string | Sim | Qualquer texto | - | Texto para sintetizar |
| `job_id` | string | Sim | UUID v4 | - | ID único do job |
| `chunk_index` | integer | Sim | 0-999 | - | Índice do chunk |
| `language` | string | Não | `pt-BR`, `en`, `es`, etc | `pt-BR` | Idioma |
| `speed` | number | Não | `0.5` - `2.0` | `1.0` | Velocidade |

### Response

```json
{
  "success": true,
  "s3_key": "job-id/chunks/chunk-000.wav",
  "bucket": "darkchannel-jobs",
  "s3_url": "s3://darkchannel-jobs/job-id/chunks/chunk-000.wav",
  "download_url": "http://localhost:9000/darkchannel-jobs/...",
  "download_expires_in": 3600,
  "job_id": "job-id",
  "chunk_index": 0
}
```

### Exemplo: Português do Brasil

**Request:**
```bash
curl -X POST http://localhost:8000/synthesize-to-s3 \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Olá! Este é um teste de síntese com armazenamento em nuvem.",
    "job_id": "550e8400-e29b-41d4-a716-446655440000",
    "chunk_index": 0,
    "language": "pt-BR",
    "speed": 1.0
  }'
```

**Python:**
```python
import requests
import uuid

url = "http://localhost:8000/synthesize-to-s3"
payload = {
    "text": "Olá! Este é um teste.",
    "job_id": str(uuid.uuid4()),
    "chunk_index": 0,
    "language": "pt-BR",
    "speed": 1.0
}

response = requests.post(url, json=payload)
result = response.json()

print(f"✅ Upload concluído!")
print(f"🔗 Download: {result['download_url']}")
```

---

## 5. Clonar Voz

### Endpoint
```
POST /clone
```

### Content-Type
```
multipart/form-data
```

### Parâmetros

| Parâmetro | Tipo | Obrigatório | Valores Possíveis | Padrão | Descrição |
|-----------|------|-------------|-------------------|--------|-----------|
| `reference_audio` | file | Sim | .wav, .mp3, .flac | - | Áudio de referência (15-30s recomendado) |
| `text` | string | Sim | Qualquer texto | - | Texto para sintetizar com voz clonada |
| `language` | string | Não | `pt-br`, `en`, `es`, `fr`, `zh`, `ja`, `ko` | `pt-br` | Idioma do texto |
| `speed` | number | Não | `0.5` - `2.0` | `1.0` | Velocidade da fala |

### Requisitos do Áudio de Referência

| Aspecto | Recomendação | Mínimo | Máximo |
|---------|--------------|--------|--------|
| **Duração** | 15-30 segundos | 5 segundos | 60 segundos |
| **Formato** | WAV (16-bit, 22050Hz) | MP3 | FLAC |
| **Qualidade** | Limpo, sem ruído | Aceitável | Estúdio |
| **Conteúdo** | Fala natural, variada | Monotônico | Expressivo |
| **Ambiente** | Silencioso | Pouco ruído | Estúdio |

### Exemplo 1: Básico (cURL)

```bash
curl -X POST http://localhost:8000/clone \
  -F "reference_audio=@reference_voice.wav" \
  -F "text=Olá! Esta é minha voz clonada falando em português." \
  -F "language=pt-br" \
  -F "speed=1.0"
```

### Exemplo 2: Python

```python
import requests

url = "http://localhost:8000/clone"

# Preparar arquivos e dados
files = {
    'reference_audio': open('reference_voice.wav', 'rb')
}
data = {
    'text': 'Olá! Esta é minha voz clonada falando em português.',
    'language': 'pt-br',
    'speed': 1.0
}

# Fazer request
response = requests.post(url, files=files, data=data)

# Verificar resposta
if response.status_code == 200:
    result = response.json()
    print(f"✅ Sucesso: {result['message']}")
    print(f"📁 Arquivo: {result['output_audio']}")
    print(f"🔗 Download: {result['download_url']}")
else:
    print(f"❌ Erro: {response.json()}")
```

### Exemplo 3: N8N (HTTP Request Node)

```json
{
  "method": "POST",
  "url": "http://openvoice:8000/clone",
  "sendBody": true,
  "contentType": "multipart-form-data",
  "bodyParameters": {
    "parameters": [
      {
        "name": "text",
        "value": "={{ $json.text }}"
      },
      {
        "name": "language",
        "value": "pt-br"
      },
      {
        "name": "speed",
        "value": "1.0"
      }
    ]
  },
  "options": {
    "bodyParameter": {
      "file": {
        "reference_audio": "={{ $binary.data }}"
      }
    }
  }
}
```

### Response

```json
{
  "success": true,
  "message": "Clonagem de voz processada",
  "request_id": "a1b2c3d4",
  "text": "Olá! Esta é minha voz clonada...",
  "language": "pt-br",
  "speed": 1.0,
  "reference_audio": "ref_a1b2c3d4_20251108_220000.wav",
  "output_audio": "output_a1b2c3d4_20251108_220000.wav",
  "download_url": "/download/output_a1b2c3d4_20251108_220000.wav"
}
```

---

## 6. Download de Áudio

### Endpoint
```
GET /download/<filename>
```

### Parâmetros

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `filename` | string | Nome do arquivo gerado |

### Exemplo

```bash
curl http://localhost:8000/download/output_a1b2c3d4_20251108_220000.wav \
  --output meu_audio.wav
```

**Python:**
```python
import requests

filename = "output_a1b2c3d4_20251108_220000.wav"
url = f"http://localhost:8000/download/{filename}"

response = requests.get(url)
with open("meu_audio.wav", "wb") as f:
    f.write(response.content)

print("✅ Download concluído!")
```

---

## 7. Listar Áudios Gerados

### Endpoint
```
GET /list-outputs
```

### Response
```json
{
  "total": 3,
  "files": [
    {
      "filename": "output_a1b2c3d4_20251108_220000.wav",
      "size": 1048576,
      "size_mb": 1.0,
      "download_url": "/download/output_a1b2c3d4_20251108_220000.wav"
    },
    {
      "filename": "output_e5f6g7h8_20251108_221500.wav",
      "size": 2097152,
      "size_mb": 2.0,
      "download_url": "/download/output_e5f6g7h8_20251108_221500.wav"
    }
  ]
}
```

### Exemplo

```bash
curl http://localhost:8000/list-outputs
```

---

# 🔄 Pipeline Completo: Kokoro + OpenVoice

## Fluxo de Trabalho

```
1. Texto Original
   ↓
2. Kokoro TTS (Gerar Áudio Base)
   ↓
3. OpenVoice (Clonar Voz)
   ↓
4. Áudio Final com Voz Clonada
```

## Exemplo Completo (Python)

```python
import requests

# Passo 1: Gerar áudio base com Kokoro TTS
print("🎤 Gerando áudio base com Kokoro TTS...")
kokoro_url = "http://localhost:8880/v1/audio/speech"
kokoro_payload = {
    "model": "kokoro",
    "input": "Este é um teste de clonagem de voz completo.",
    "voice": "af_sarah",
    "speed": 1.0,
    "response_format": "wav"
}

kokoro_response = requests.post(kokoro_url, json=kokoro_payload)
with open("base_audio.wav", "wb") as f:
    f.write(kokoro_response.content)
print("✅ Áudio base gerado!")

# Passo 2: Clonar voz com OpenVoice
print("🎙️ Clonando voz com OpenVoice...")
openvoice_url = "http://localhost:8000/clone"

files = {
    'reference_audio': open('minha_voz_referencia.wav', 'rb')
}
data = {
    'text': 'Este é um teste de clonagem de voz completo.',
    'language': 'pt-br',
    'speed': 1.0
}

openvoice_response = requests.post(openvoice_url, files=files, data=data)
result = openvoice_response.json()

# Passo 3: Baixar áudio final
print("📥 Baixando áudio final...")
download_url = f"http://localhost:8000{result['download_url']}"
final_audio = requests.get(download_url)

with open("audio_final_clonado.wav", "wb") as f:
    f.write(final_audio.content)

print("🎉 Pipeline completo! Áudio com voz clonada gerado com sucesso!")
```

---

# 🐛 Códigos de Erro

## Kokoro TTS

| Código | Erro | Causa | Solução |
|--------|------|-------|---------|
| 400 | Bad Request | Parâmetros inválidos | Verificar formato dos parâmetros |
| 404 | Not Found | Endpoint incorreto | Usar `/v1/audio/speech` |
| 422 | Validation Error | Valores fora do range | Ajustar speed (0.25-4.0) |
| 500 | Internal Error | Erro no servidor | Verificar logs do container |

## OpenVoice

| Código | Erro | Causa | Solução |
|--------|------|-------|---------|
| 400 | No reference audio | Áudio não enviado | Incluir arquivo no request |
| 400 | No text provided | Texto não enviado | Incluir parâmetro `text` |
| 404 | File not found | Arquivo não existe | Verificar nome do arquivo |
| 503 | Model not loaded | Modelos não carregados | Verificar `/status` |

---

# 💡 Dicas e Boas Práticas

## Kokoro TTS

1. **Qualidade**: Use `wav` para melhor qualidade, `mp3` para produção
2. **Velocidade**: Mantenha entre 0.8-1.2 para naturalidade
3. **Pontuação**: Use pontos e vírgulas para pausas naturais
4. **Tamanho**: Divida textos longos em chunks de ~500 palavras

## OpenVoice

1. **Áudio de Referência**: 15-30 segundos, limpo, sem ruído
2. **Qualidade**: Grave em ambiente silencioso
3. **Variação**: Use fala natural com entonação variada
4. **Formato**: Prefira WAV 16-bit 22050Hz

## Pipeline Completo

1. **Teste Incremental**: Teste Kokoro primeiro, depois OpenVoice
2. **Cache**: Reutilize áudios base quando possível
3. **Batch**: Processe múltiplos capítulos em paralelo
4. **Monitoramento**: Verifique logs para identificar problemas

---

---

# 📊 Comparação de Serviços

## Português do Brasil - Qual usar?

| Aspecto | Kokoro (Wrapper) | OpenVoice | Recomendação |
|---------|------------------|-----------|--------------||
| **Qualidade de Voz** | ⭐⭐⭐⭐⭐ Excelente | ⭐⭐⭐ Boa | **Kokoro** |
| **Vozes Disponíveis** | 7 vozes nativas | 1 voz (gTTS) | **Kokoro** |
| **Naturalidade** | Muito natural | Sintética | **Kokoro** |
| **Velocidade** | Rápido | Rápido | Empate |
| **MinIO Integration** | ✅ Sim | ✅ Sim | Empate |
| **Clonagem de Voz** | ❌ Não | 🔄 Em desenvolvimento | **OpenVoice** (futuro) |
| **Produção** | ✅ Pronto | ⚠️ Limitado | **Kokoro** |

### Recomendação Final

**Para Português do Brasil:**
- ✅ **Use Kokoro Wrapper** para produção
- ⭐ **Voz recomendada:** `af_sarah` (feminina) ou `am_adam` (masculina)
- 🎯 **Qualidade:** Excelente para todos os casos de uso

**OpenVoice:**
- 🔄 Em desenvolvimento para clonagem de voz
- ⚠️ Atualmente limitado (usa gTTS)
- 🚀 Futuro: Clonagem de voz personalizada

---

**Criado para DarkChannel Stack** 🎯  
**Versão**: 2.0.0  
**Última Atualização**: 09/11/2025

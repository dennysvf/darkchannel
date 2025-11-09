# 🎤 Kokoro TTS API Documentation

API REST para síntese de voz com Kokoro TTS (compatível com OpenAI).

---

## 🌐 Base URL

```
http://localhost:8880
```

Dentro da rede Docker:
```
http://kokoro-tts:8880
```

---

## 📋 Endpoints Principais

### 1. Síntese de Voz (OpenAI Compatible)

**Endpoint**: `POST /v1/audio/speech`

**Content-Type**: `application/json`

**Body**:
```json
{
  "model": "kokoro",
  "input": "Texto para sintetizar",
  "voice": "af_sarah",
  "speed": 1.0,
  "response_format": "wav"
}
```

**Parâmetros**:

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `model` | string | Sim | Modelo a usar: `kokoro`, `tts-1`, `tts-1-hd` |
| `input` | string | Sim | Texto para sintetizar |
| `voice` | string | Não | Voz a usar (padrão: `af`) |
| `speed` | number | Não | Velocidade (0.25 - 4.0, padrão: 1.0) |
| `response_format` | string | Não | Formato: `mp3`, `opus`, `flac`, `wav`, `pcm` (padrão: `mp3`) |
| `stream` | boolean | Não | Streaming (padrão: `true`) |
| `lang_code` | string | Não | Código do idioma (ex: `pt`, `en`, `es`) |

**Exemplo (cURL)**:
```bash
curl -X POST http://localhost:8880/v1/audio/speech \
  -H "Content-Type: application/json" \
  -d '{
    "model": "kokoro",
    "input": "Olá! Este é um teste do Kokoro TTS.",
    "voice": "af_sarah",
    "speed": 1.0,
    "response_format": "wav"
  }' \
  --output output.wav
```

**Exemplo (Python)**:
```python
import requests

url = "http://localhost:8880/v1/audio/speech"
data = {
    "model": "kokoro",
    "input": "Olá! Este é um teste do Kokoro TTS.",
    "voice": "af_sarah",
    "speed": 1.0,
    "response_format": "wav"
}

response = requests.post(url, json=data)

with open("output.wav", "wb") as f:
    f.write(response.content)
```

**Exemplo (N8N)**:
```json
{
  "method": "POST",
  "url": "http://kokoro-tts:8880/v1/audio/speech",
  "sendBody": true,
  "contentType": "json",
  "specifyBody": "json",
  "jsonBody": "={\n  \"model\": \"kokoro\",\n  \"input\": \"{{ $json.text }}\",\n  \"voice\": \"af_sarah\",\n  \"speed\": 1.0,\n  \"response_format\": \"wav\"\n}",
  "options": {
    "response": {
      "response": {
        "responseFormat": "file"
      }
    }
  }
}
```

---

### 2. Síntese com Timestamps

**Endpoint**: `POST /v1/audio/speech/captioned`

**Body**:
```json
{
  "model": "kokoro",
  "input": "Texto para sintetizar",
  "voice": "af_sarah",
  "speed": 1.0,
  "response_format": "wav",
  "return_timestamps": true
}
```

**Resposta**: Retorna áudio com timestamps de palavras

---

### 3. Health Check

**Endpoint**: `GET /health`

**Resposta**:
```json
{
  "status": "healthy"
}
```

---

### 4. Documentação Interativa

**Swagger UI**: http://localhost:8880/docs

**OpenAPI JSON**: http://localhost:8880/openapi.json

---

## 🎙️ Vozes Disponíveis

### Vozes Femininas (AF)

| Código | Nome | Características |
|--------|------|-----------------|
| `af` | Base Feminina | Voz feminina padrão |
| `af_sarah` | Sarah | Clara e profissional |
| `af_nicole` | Nicole | Suave e amigável |
| `af_sky` | Sky | Jovem e energética |

### Vozes Masculinas (AM)

| Código | Nome | Características |
|--------|------|-----------------|
| `am` | Base Masculina | Voz masculina padrão |
| `am_adam` | Adam | Profunda e autoritária |
| `am_michael` | Michael | Enérgica e dinâmica |

### Vozes Britânicas (BF/BM)

| Código | Nome | Características |
|--------|------|-----------------|
| `bf` | Base Feminina UK | Sotaque britânico feminino |
| `bm` | Base Masculina UK | Sotaque britânico masculino |

---

## ⚙️ Parâmetros Avançados

### Velocidade (Speed)

- `0.25` - Muito lento
- `0.5` - Lento
- `0.75` - Um pouco lento
- `1.0` - Normal (padrão)
- `1.25` - Um pouco rápido
- `1.5` - Rápido
- `2.0` - Muito rápido
- `4.0` - Máximo

### Formatos de Resposta

| Formato | Descrição | Uso |
|---------|-----------|-----|
| `mp3` | MPEG Audio Layer 3 | Padrão, boa compressão |
| `wav` | Waveform Audio | Sem perda, melhor qualidade |
| `opus` | Opus Codec | Ótima compressão, streaming |
| `flac` | Free Lossless Audio | Sem perda, comprimido |
| `pcm` | Raw PCM | Dados brutos, 16-bit |

### Opções de Normalização

```json
{
  "normalization_options": {
    "normalize": true,
    "unit_normalization": false,
    "url_normalization": true,
    "email_normalization": true,
    "optional_pluralization_normalization": true
  }
}
```

---

## 🌍 Suporte a Idiomas

Kokoro suporta múltiplos idiomas através do parâmetro `lang_code`:

| Código | Idioma | Exemplo |
|--------|--------|---------|
| `pt` | Português | "Olá, como vai?" |
| `en` | English | "Hello, how are you?" |
| `es` | Español | "Hola, ¿cómo estás?" |
| `fr` | Français | "Bonjour, comment allez-vous?" |
| `de` | Deutsch | "Hallo, wie geht es dir?" |
| `it` | Italiano | "Ciao, come stai?" |
| `ja` | 日本語 | "こんにちは、元気ですか？" |
| `zh` | 中文 | "你好，你好吗？" |

---

## 🔄 Streaming

Para streaming de áudio em tempo real:

```json
{
  "model": "kokoro",
  "input": "Texto longo para streaming...",
  "voice": "af_sarah",
  "stream": true
}
```

O áudio será retornado em chunks conforme é gerado.

---

## 🐛 Troubleshooting

### Erro 404: Not Found

**Causa**: Endpoint incorreto

**Solução**: Use `/v1/audio/speech` ao invés de `/synthesize`

### Áudio com qualidade ruim

**Causa**: Formato ou velocidade inadequados

**Solução**:
- Use `response_format: "wav"` para melhor qualidade
- Ajuste `speed` para 1.0
- Verifique se o texto está bem formatado

### Voz não encontrada

**Causa**: Código de voz inválido

**Solução**: Use uma das vozes listadas acima (ex: `af_sarah`, `am_adam`)

### Timeout

**Causa**: Texto muito longo

**Solução**: Divida o texto em chunks menores (< 500 palavras por request)

---

## 💡 Dicas de Uso

1. **Qualidade vs Tamanho**: Use WAV para qualidade máxima, MP3 para economia de espaço

2. **Velocidade Natural**: Mantenha speed entre 0.8 e 1.2 para melhor naturalidade

3. **Pontuação**: Use pontuação adequada para pausas naturais

4. **Streaming**: Ative streaming para textos longos e feedback rápido

5. **Normalização**: Deixe normalização ativada para melhor pronúncia de URLs, emails, etc

---

## 📊 Limites e Performance

- **Tamanho máximo de texto**: ~5000 caracteres por request
- **Tempo de processamento**: ~1-3 segundos para 100 palavras (CPU)
- **Formato recomendado**: WAV para qualidade, MP3 para produção
- **Concurrent requests**: Suporta múltiplas requisições simultâneas

---

## 🔗 Integração com N8N

Veja os workflows prontos em: [workflows/](../workflows/)

- `workflow-kokoro-tts.json` - Teste simples
- `workflow-openvoice-clone.json` - Pipeline completo
- `workflow-audiobook-complete.json` - Geração de audiolivro

---

## 📚 Recursos Adicionais

- **Documentação Oficial**: http://localhost:8880/docs
- **OpenAPI Spec**: http://localhost:8880/openapi.json
- **GitHub**: https://github.com/remsky/kokoro-fastapi

---

**Desenvolvido para DarkChannel Stack** 🎯

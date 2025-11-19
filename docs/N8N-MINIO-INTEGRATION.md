# 🔄 N8N + MinIO Integration Guide

## 📋 Visão Geral

Guia completo para usar N8N com MinIO no DarkChannel Stack para processamento de TTS e armazenamento de áudio.

---

## ✅ Status da Integração

### **Já Configurado:**
- ✅ Variáveis de ambiente MinIO no N8N
- ✅ Kokoro Wrapper com endpoint `/tts-to-s3`
- ✅ OpenVoice com endpoint `/synthesize-to-s3`
- ✅ SSML Service com suporte a chunks
- ✅ MinIO rodando e acessível

### **Workflows Prontos:**
- ✅ `TTS-with-MinIO-Example.json` - Exemplo básico
- ✅ `SSML-Complete-Pipeline.json` - Pipeline completo

---

## 🔧 Variáveis de Ambiente Disponíveis

O N8N já tem acesso às seguintes variáveis:

```bash
MINIO_ENDPOINT=http://minio:9000
MINIO_ACCESS_KEY=darkchannel-app
MINIO_SECRET_KEY=darkchannel-secret-key-123
MINIO_BUCKET_JOBS=darkchannel-jobs
MINIO_BUCKET_OUTPUT=darkchannel-output
MINIO_BUCKET_REFS=darkchannel-refs
MINIO_BUCKET_TEMP=darkchannel-temp
```

**Usar em workflows:**
```javascript
const minioEndpoint = $env.MINIO_ENDPOINT;
const accessKey = $env.MINIO_ACCESS_KEY;
const bucket = $env.MINIO_BUCKET_JOBS;
```

---

## 🚀 Workflow 1: TTS Simples com MinIO

### Fluxo:
```
Webhook → Preparar Job → Kokoro TTS → MinIO → Resposta
```

### Como Importar:

1. Abra N8N: http://localhost:5678
2. Clique em **"Import from File"**
3. Selecione: `workflows/TTS-with-MinIO-Example.json`
4. Ative o workflow

### Como Testar:

```powershell
$body = @{
    text = "Olá! Este é um teste de síntese de voz com armazenamento em MinIO."
    voice = "af_sarah"
    lang = "pt-br"
} | ConvertTo-Json

$response = Invoke-RestMethod `
    -Uri "http://localhost:5678/webhook/tts-minio-webhook" `
    -Method POST `
    -Body $body `
    -ContentType "application/json"

Write-Host "✅ Áudio gerado!"
Write-Host "📦 S3 Key: $($response.s3_key)"
Write-Host "🔗 Download: $($response.download_url)"
```

### Resposta Esperada:

```json
{
  "success": true,
  "job_id": "550e8400-e29b-41d4-a716-446655440000",
  "chunk_index": 0,
  "s3_key": "550e8400-e29b-41d4-a716-446655440000/chunks/chunk-000.wav",
  "bucket": "darkchannel-jobs",
  "s3_url": "s3://darkchannel-jobs/550e8400-e29b-41d4-a716-446655440000/chunks/chunk-000.wav",
  "download_url": "http://localhost:9000/darkchannel-jobs/...",
  "download_expires_in": 3600,
  "message": "Áudio gerado e armazenado no MinIO com sucesso!"
}
```

---

## 🎯 Workflow 2: Pipeline SSML Completo

### Fluxo:
```
Webhook → Preparar SSML → Processar SSML → Dividir Chunks → 
→ Gerar Áudio (para cada chunk) → Agregar Resultados → Resposta
```

### Como Importar:

1. Abra N8N: http://localhost:5678
2. Import: `workflows/SSML-Complete-Pipeline.json`
3. Ative o workflow

### Como Testar:

```powershell
$ssml = @"
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="pt-BR">
  <voice name="af_sarah">
    <prosody rate="1.0">
      Olá! Bem-vindo ao sistema de síntese de voz.
    </prosody>
  </voice>
  <break time="500ms"/>
  <voice name="am_adam">
    <prosody rate="0.9">
      Este é um exemplo de múltiplas vozes.
    </prosody>
  </voice>
</speak>
"@

$body = @{
    ssml = $ssml
    voice_cloning_enabled = $false
} | ConvertTo-Json

$response = Invoke-RestMethod `
    -Uri "http://localhost:5678/webhook/ssml-pipeline-webhook" `
    -Method POST `
    -Body $body `
    -ContentType "application/json"

Write-Host "✅ Pipeline concluído!"
Write-Host "📊 Total de chunks: $($response.total_chunks)"
foreach ($chunk in $response.chunks) {
    Write-Host "  - Chunk $($chunk.chunk_index): $($chunk.s3_key)"
}
```

---

## 📝 Nodes Customizados

### Node 1: Preparar Job

```javascript
// Gerar Job ID único e preparar dados
const jobId = $input.item.json.job_id || require('crypto').randomUUID();
const text = $input.item.json.text || 'Texto padrão';
const voice = $input.item.json.voice || 'af_sarah';
const lang = $input.item.json.lang || 'pt-br';

return {
  json: {
    job_id: jobId,
    text: text,
    voice: voice,
    lang: lang,
    chunk_index: 0,
    timestamp: new Date().toISOString()
  }
};
```

### Node 2: Chamar Kokoro com MinIO

```javascript
// HTTP Request Node
{
  "url": "http://kokoro-wrapper:8881/tts-to-s3",
  "method": "POST",
  "sendBody": true,
  "contentType": "json",
  "jsonBody": {
    "text": "{{ $json.text }}",
    "job_id": "{{ $json.job_id }}",
    "chunk_index": "{{ $json.chunk_index }}",
    "lang": "{{ $json.lang }}",
    "voice": "{{ $json.voice }}",
    "speed": 1.0
  }
}
```

### Node 3: Processar Resposta

```javascript
// Extrair informações do MinIO
const response = $input.item.json;

return {
  json: {
    success: response.success,
    job_id: response.job_id,
    s3_key: response.s3_key,
    bucket: response.bucket,
    download_url: response.download_url,
    download_expires_in: response.download_expires_in
  }
};
```

---

## 🎨 Workflow 3: Audiobook com Capítulos

### Criar Novo Workflow:

```json
{
  "name": "Audiobook Generator",
  "nodes": [
    {
      "name": "Webhook - Receber Capítulos",
      "type": "n8n-nodes-base.webhook"
    },
    {
      "name": "Loop - Para Cada Capítulo",
      "type": "n8n-nodes-base.splitInBatches"
    },
    {
      "name": "Processar SSML do Capítulo",
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "url": "http://ssml-service:8002/process-ssml"
      }
    },
    {
      "name": "Gerar Áudio - Kokoro",
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "url": "http://kokoro-wrapper:8881/tts-to-s3"
      }
    },
    {
      "name": "Salvar Metadados no PostgreSQL",
      "type": "n8n-nodes-base.postgres"
    },
    {
      "name": "Notificar Conclusão",
      "type": "n8n-nodes-base.httpRequest"
    }
  ]
}
```

### Payload de Teste:

```json
{
  "audiobook_id": "book-001",
  "title": "Meu Audiobook",
  "chapters": [
    {
      "chapter_number": 1,
      "title": "Capítulo 1",
      "ssml": "<speak>...</speak>",
      "voice": "af_nicole"
    },
    {
      "chapter_number": 2,
      "title": "Capítulo 2",
      "ssml": "<speak>...</speak>",
      "voice": "af_nicole"
    }
  ]
}
```

---

## 🔐 Acessar MinIO Diretamente do N8N

### Opção 1: Via HTTP Request (Recomendado)

Usar os endpoints wrapper que já fazem upload:
- `http://kokoro-wrapper:8881/tts-to-s3`
- `http://openvoice:8000/synthesize-to-s3`

### Opção 2: SDK AWS S3 (Avançado)

```javascript
// Function Node
const AWS = require('aws-sdk');

const s3 = new AWS.S3({
  endpoint: process.env.MINIO_ENDPOINT,
  accessKeyId: process.env.MINIO_ACCESS_KEY,
  secretAccessKey: process.env.MINIO_SECRET_KEY,
  s3ForcePathStyle: true,
  signatureVersion: 'v4'
});

// Upload file
const params = {
  Bucket: process.env.MINIO_BUCKET_JOBS,
  Key: 'my-file.wav',
  Body: $binary.data,
  ContentType: 'audio/wav'
};

const result = await s3.upload(params).promise();

return {
  json: {
    location: result.Location,
    key: result.Key,
    bucket: result.Bucket
  }
};
```

---

## 📊 Monitoramento e Logs

### Ver Logs do N8N:

```powershell
docker logs n8n -f --tail 50
```

### Ver Execuções no N8N:

1. Abra: http://localhost:5678
2. Menu: **Executions**
3. Veja histórico completo

### Verificar Arquivos no MinIO:

```powershell
# Via MinIO Console
# http://localhost:9001
# Login: darkchannel-app / darkchannel-secret-key-123

# Ou via CLI
docker exec minio mc ls local/darkchannel-jobs
```

---

## 🎯 Casos de Uso

### 1. **Geração de Audiobook**
- Input: Capítulos em SSML
- Process: N8N divide e processa
- Output: Áudios no MinIO organizados por capítulo

### 2. **Podcast Automatizado**
- Input: Script com múltiplas vozes
- Process: SSML com diferentes speakers
- Output: Episódio completo no MinIO

### 3. **Narração de Notícias**
- Input: Feed RSS
- Process: Converter para SSML + TTS
- Output: Áudio diário no MinIO

### 4. **E-learning**
- Input: Conteúdo educacional
- Process: Múltiplas vozes para diálogos
- Output: Aulas em áudio no MinIO

---

## 🔧 Troubleshooting

### Erro: "Cannot connect to MinIO"

```javascript
// Verificar variáveis de ambiente
console.log('MinIO Endpoint:', process.env.MINIO_ENDPOINT);
console.log('Access Key:', process.env.MINIO_ACCESS_KEY ? 'SET' : 'NOT SET');
```

### Erro: "Bucket not found"

```bash
# Criar bucket manualmente
docker exec minio mc mb local/darkchannel-jobs
```

### Erro: "Presigned URL expired"

- URLs expiram em 1 hora por padrão
- Gere nova URL quando necessário
- Use endpoint `/download-url` para renovar

---

## 📚 Próximos Passos

1. ✅ Importar workflows de exemplo
2. ✅ Testar com dados reais
3. ✅ Criar workflows customizados
4. ✅ Integrar com sistemas externos
5. ✅ Monitorar e otimizar

---

**Criado para DarkChannel Stack** 🎯  
**Versão**: 1.0.0  
**Data**: 09/11/2025

# N8N + MinIO Integration Guide

**Data**: 2025-11-09  
**Status**: 📝 Documentação

---

## 🎯 Objetivo

Integrar N8N com MinIO para armazenar arquivos de áudio gerados pelos workflows.

---

## 🔐 Configurar Credencial S3 no N8N

### Passo 1: Acessar N8N
```
http://localhost:5678
```

### Passo 2: Criar Credencial S3

1. Ir em **Settings** → **Credentials**
2. Clicar em **Add Credential**
3. Buscar por **AWS S3**
4. Preencher:

```
Name: MinIO DarkChannel
Access Key ID: uovuCgq4VX9gIyFvua5K
Secret Access Key: ulhQu3Sw8cfXLakMfCLFyeIbQjJbQ7WlvrmOJtnE

Custom Endpoints:
  ✅ Use Custom Endpoints
  S3 Endpoint: http://minio:9000
  
Force Path Style: ✅ Enabled
Region: us-east-1
```

5. **Test** → **Save**

---

## 📦 Buckets Disponíveis

```
darkchannel-jobs     # Jobs em processamento
darkchannel-output   # Audiolivros finalizados
darkchannel-refs     # Vozes de referência
darkchannel-temp     # Temporários (auto-delete 24h)
```

---

## 🔄 Workflow Example: Upload de Áudio

### Node 1: Webhook
```json
{
  "method": "POST",
  "path": "audiobook",
  "responseMode": "onReceived"
}
```

### Node 2: Generate Job ID (Code)
```javascript
const { v4: uuidv4 } = require('uuid');

const jobId = uuidv4();
const chapterTitle = $json.chapter_title || 'Untitled';

return {
  job_id: jobId,
  chapter_title: chapterTitle,
  input_text: $json.text,
  created_at: new Date().toISOString()
};
```

### Node 3: Create Job Metadata (AWS S3)
```
Operation: Upload
Bucket: darkchannel-jobs
File Name: {{$json.job_id}}/metadata.json
Binary Data: false
File Content: 
{
  "job_id": "{{$json.job_id}}",
  "status": "pending",
  "created_at": "{{$json.created_at}}",
  "chapter_title": "{{$json.chapter_title}}",
  "input_text": "{{$json.input_text}}"
}
```

### Node 4: SSML Parser (HTTP Request)
```
Method: POST
URL: http://ssml:8888/api/v1/ssml/parse
Body:
{
  "text": "{{$json.input_text}}"
}
```

### Node 5: Loop Through Chunks (Split In Batches)
```
Batch Size: 1
```

### Node 6: TTS Synthesis (HTTP Request)
```
Method: POST
URL: http://openvoice:8000/synthesize
Body:
{
  "text": "{{$json.text}}",
  "language": "pt-BR",
  "speed": 1.0,
  "pitch": 0
}
```

### Node 7: Upload Chunk to MinIO (AWS S3)
```
Operation: Upload
Bucket: darkchannel-jobs
File Name: {{$('Generate Job ID').item.json.job_id}}/chunks/chunk-{{$json.index}}.wav
Binary Property: data
```

### Node 8: Merge Chunks (Code)
```javascript
// Após todos os chunks
const jobId = $('Generate Job ID').item.json.job_id;
const chunks = $input.all();

// Aqui você faria o merge dos chunks
// Por enquanto, retornar lista de chunks

return {
  job_id: jobId,
  total_chunks: chunks.length,
  chunks: chunks.map(c => c.json.s3_key)
};
```

### Node 9: Upload Final Audio (AWS S3)
```
Operation: Upload
Bucket: darkchannel-jobs
File Name: {{$json.job_id}}/final/audiobook.mp3
Binary Property: merged_audio
```

### Node 10: Generate Download URL (Code)
```javascript
const AWS = require('aws-sdk');

const s3 = new AWS.S3({
  endpoint: process.env.MINIO_ENDPOINT,
  accessKeyId: process.env.MINIO_ACCESS_KEY,
  secretAccessKey: process.env.MINIO_SECRET_KEY,
  s3ForcePathStyle: true,
  signatureVersion: 'v4'
});

const jobId = $json.job_id;
const key = `${jobId}/final/audiobook.mp3`;

const url = s3.getSignedUrl('getObject', {
  Bucket: 'darkchannel-jobs',
  Key: key,
  Expires: 3600 // 1 hora
});

return {
  job_id: jobId,
  download_url: url,
  expires_in: 3600
};
```

---

## 🧪 Testar Workflow

### Via PowerShell
```powershell
$body = @{
    chapter_title = "Capítulo 1: O Início"
    text = "Era uma vez, em um reino distante..."
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5678/webhook/audiobook" `
    -Method POST `
    -Body $body `
    -ContentType "application/json"
```

### Via curl
```bash
curl -X POST http://localhost:5678/webhook/audiobook \
  -H "Content-Type: application/json" \
  -d '{
    "chapter_title": "Capítulo 1: O Início",
    "text": "Era uma vez, em um reino distante..."
  }'
```

---

## 📊 Estrutura de Arquivos no MinIO

```
darkchannel-jobs/
└── {job-uuid}/
    ├── metadata.json
    ├── chunks/
    │   ├── chunk-000.wav
    │   ├── chunk-001.wav
    │   └── chunk-002.wav
    └── final/
        └── audiobook.mp3
```

---

## 🔍 Verificar Arquivos

### Via UI
```
http://localhost:9001
Login: uovuCgq4VX9gIyFvua5K / ulhQu3Sw8cfXLakMfCLFyeIbQjJbQ7WlvrmOJtnE
```

### Via Python
```python
from src.minio import MinIOClient

client = MinIOClient()
files = client.list_objects('darkchannel-jobs', 'job-uuid/')
print(files)
```

---

## 🎯 Próximos Passos

1. ✅ Credencial S3 configurada
2. ⏳ Criar workflow completo
3. ⏳ Testar end-to-end
4. ⏳ Integrar com OpenVoice
5. ⏳ Implementar merge de chunks

---

**Status**: 📝 Pronto para implementação  
**Responsável**: Equipe DarkChannel

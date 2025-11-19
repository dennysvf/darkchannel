# ✅ OpenVoice + MinIO Integration

**Data**: 2025-11-09  
**Status**: 🔨 Em implementação

---

## 🎯 Objetivo

Integrar OpenVoice com MinIO para salvar áudios sintetizados direto no object storage, retornando apenas S3 keys para o N8N.

---

## 📝 O Que Foi Implementado

### 1. **Novo Endpoint**: `/synthesize-to-s3`

**Funcionalidade**:
- Recebe texto + job_id + chunk_index
- Sintetiza áudio (dummy por enquanto)
- Upload automático para MinIO
- Retorna S3 key em vez de arquivo

**Request**:
```json
POST /synthesize-to-s3
Content-Type: application/json

{
  "text": "Este é um teste de síntese com MinIO.",
  "job_id": "uuid-do-job",
  "chunk_index": 0,
  "language": "pt-BR",
  "speed": 1.0,
  "pitch": 0
}
```

**Response**:
```json
{
  "success": true,
  "s3_key": "uuid-do-job/chunks/chunk-000.wav",
  "bucket": "darkchannel-jobs",
  "s3_url": "s3://darkchannel-jobs/uuid-do-job/chunks/chunk-000.wav",
  "chunk_index": 0,
  "job_id": "uuid-do-job"
}
```

### 2. **Modificações no Código**

**`src/openvoice-server.py`**:
- Adicionado import de boto3/MinIO client
- Função `get_minio_client()` para lazy loading
- Endpoint `/synthesize-to-s3` completo
- Geração de áudio dummy (1s silêncio)
- Upload automático para MinIO
- Metadados incluídos (job_id, chunk_index, text, language)

**`Dockerfile.openvoice`**:
- Adicionado `boto3==1.34.0` e `botocore==1.34.0`
- Copiado módulo `src/minio` para `/app/minio`

---

## 🔄 Fluxo de Dados

```
1. N8N envia request → OpenVoice /synthesize-to-s3
   {text, job_id, chunk_index}

2. OpenVoice sintetiza áudio
   → Gera arquivo WAV temporário

3. OpenVoice upload para MinIO
   → s3://darkchannel-jobs/{job_id}/chunks/chunk-{n}.wav

4. OpenVoice retorna S3 key
   → N8N recebe apenas a referência

5. N8N coleta todas as S3 keys
   → Passa para próxima etapa (merge)
```

---

## 📦 Estrutura no MinIO

```
darkchannel-jobs/
└── {job-uuid}/
    ├── chunks/
    │   ├── chunk-000.wav  ← OpenVoice
    │   ├── chunk-001.wav  ← OpenVoice
    │   └── chunk-002.wav  ← OpenVoice
    └── final/
        └── audiobook.mp3  ← Merge final
```

---

## 🧪 Como Testar

### 1. Verificar Status
```powershell
Invoke-RestMethod -Uri "http://localhost:8000/health"
```

### 2. Testar Síntese com MinIO
```powershell
.\test-synthesize-to-s3.ps1
```

### 3. Verificar no MinIO UI
```
URL: http://localhost:9001
User: uovuCgq4VX9gIyFvua5K
Pass: ulhQu3Sw8cfXLakMfCLFyeIbQjJbQ7WlvrmOJtnE

Bucket: darkchannel-jobs
Path: {job-id}/chunks/
```

### 4. Listar Objetos via Python
```python
from minio import MinIOClient

client = MinIOClient()
files = client.list_objects('darkchannel-jobs', 'job-uuid/')
print(files)
```

---

## ✅ Benefícios

1. **N8N Leve**: Não manipula arquivos grandes, apenas S3 keys
2. **Escalável**: Arquivos no object storage distribuído
3. **Rastreável**: Todas as URLs registradas no workflow
4. **Desacoplado**: OpenVoice não precisa servir arquivos
5. **Persistente**: Arquivos não se perdem entre restarts

---

## 🎯 Próximos Passos

### Fase 3A: Kokoro Integration
- [ ] Adicionar endpoint `/tts-to-s3` no Kokoro
- [ ] Similar ao OpenVoice
- [ ] Testar

### Fase 3B: N8N Workflow
- [ ] Criar workflow completo usando MinIO
- [ ] SSML parse → OpenVoice /synthesize-to-s3
- [ ] Coletar S3 keys
- [ ] Merge chunks do MinIO
- [ ] Upload final

### Fase 3C: Síntese Real
- [ ] Substituir áudio dummy por síntese real
- [ ] Integrar com OpenVoice TTS
- [ ] Testes de qualidade

---

## 📊 Status Atual

```
✅ Endpoint /synthesize-to-s3 criado
✅ MinIO client integrado
✅ Dockerfile atualizado
🔨 Build em andamento
⏳ Teste pendente
```

---

**Responsável**: Equipe DarkChannel  
**Última Atualização**: 2025-11-09 08:32

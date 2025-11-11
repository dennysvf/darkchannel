# 🔗 Integração MinIO com Serviços

**Versão**: 1.0.0  
**Data**: 2025-11-09  
**Status**: Planejamento

---

## 🎯 Objetivo

Documentar como cada serviço do DarkChannel Stack se integrará com o MinIO usando variáveis de ambiente para desacoplamento completo.

---

## 📋 Variáveis de Ambiente Compartilhadas

Todos os serviços terão acesso a estas variáveis:

```env
# MinIO Connection
MINIO_ENDPOINT=http://minio:9000
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=miniopass123

# MinIO Buckets
MINIO_BUCKET_JOBS=darkchannel-jobs
MINIO_BUCKET_OUTPUT=darkchannel-output
MINIO_BUCKET_REFS=darkchannel-refs
MINIO_BUCKET_TEMP=darkchannel-temp
```

---

## 🔧 Integração por Serviço

### 1. **N8N Workflow**

#### Docker Compose
```yaml
n8n:
  environment:
    MINIO_ENDPOINT: ${MINIO_ENDPOINT}
    MINIO_ROOT_USER: ${MINIO_ROOT_USER}
    MINIO_ROOT_PASSWORD: ${MINIO_ROOT_PASSWORD}
    MINIO_BUCKET_JOBS: ${MINIO_BUCKET_JOBS}
    MINIO_BUCKET_OUTPUT: ${MINIO_BUCKET_OUTPUT}
    MINIO_BUCKET_REFS: ${MINIO_BUCKET_REFS}
    MINIO_BUCKET_TEMP: ${MINIO_BUCKET_TEMP}
```

#### Uso no Workflow
```javascript
// Node: Configure S3 Client
const s3Config = {
  endpoint: $env.MINIO_ENDPOINT,
  accessKeyId: $env.MINIO_ROOT_USER,
  secretAccessKey: $env.MINIO_ROOT_PASSWORD,
  s3ForcePathStyle: true,  // Importante para MinIO
  signatureVersion: 'v4'
};

// Node: Upload to MinIO
const bucket = $env.MINIO_BUCKET_JOBS;
const key = `${jobId}/chunks/chunk-${index}.wav`;
```

#### Credenciais N8N
```
Nome: MinIO S3
Tipo: AWS S3
Configuração:
  - Endpoint: {{$env.MINIO_ENDPOINT}}
  - Access Key: {{$env.MINIO_ROOT_USER}}
  - Secret Key: {{$env.MINIO_ROOT_PASSWORD}}
  - Force Path Style: true
```

---

### 2. **OpenVoice TTS**

#### Docker Compose
```yaml
openvoice:
  environment:
    MINIO_ENDPOINT: ${MINIO_ENDPOINT}
    MINIO_ROOT_USER: ${MINIO_ROOT_USER}
    MINIO_ROOT_PASSWORD: ${MINIO_ROOT_PASSWORD}
    MINIO_BUCKET_JOBS: ${MINIO_BUCKET_JOBS}
    MINIO_BUCKET_REFS: ${MINIO_BUCKET_REFS}
```

#### Código Python (openvoice-server.py)
```python
import os
import boto3
from botocore.client import Config

# Configurar cliente S3
s3_client = boto3.client(
    's3',
    endpoint_url=os.getenv('MINIO_ENDPOINT'),
    aws_access_key_id=os.getenv('MINIO_ROOT_USER'),
    aws_secret_access_key=os.getenv('MINIO_ROOT_PASSWORD'),
    config=Config(signature_version='s3v4'),
    region_name='us-east-1'
)

@app.route('/synthesize', methods=['POST'])
def synthesize():
    # ... gerar áudio ...
    
    # Upload para MinIO
    bucket = os.getenv('MINIO_BUCKET_JOBS')
    key = f"{job_id}/chunks/chunk-{index}.wav"
    
    s3_client.upload_file(
        audio_path,
        bucket,
        key,
        ExtraArgs={'ContentType': 'audio/wav'}
    )
    
    return jsonify({
        'success': True,
        's3_url': f"s3://{bucket}/{key}"
    })
```

#### Novo Endpoint: `/synthesize-to-s3`
```python
@app.route('/synthesize-to-s3', methods=['POST'])
def synthesize_to_s3():
    """
    Sintetiza áudio e salva direto no MinIO
    
    Body:
    {
      "text": "...",
      "job_id": "uuid-123",
      "chunk_index": 1,
      "language": "pt-BR",
      "speed": 1.0,
      "pitch": 0
    }
    
    Returns:
    {
      "success": true,
      "s3_url": "s3://darkchannel-jobs/uuid-123/chunks/chunk-001.wav",
      "size_bytes": 102400,
      "duration_seconds": 5.2
    }
    """
    pass
```

---

### 3. **Kokoro TTS**

#### Docker Compose
```yaml
kokoro-tts:
  environment:
    MINIO_ENDPOINT: ${MINIO_ENDPOINT}
    MINIO_ROOT_USER: ${MINIO_ROOT_USER}
    MINIO_ROOT_PASSWORD: ${MINIO_ROOT_PASSWORD}
    MINIO_BUCKET_JOBS: ${MINIO_BUCKET_JOBS}
```

#### Uso (se Kokoro for Python)
```python
# Similar ao OpenVoice
import os
import boto3

s3_client = boto3.client(
    's3',
    endpoint_url=os.getenv('MINIO_ENDPOINT'),
    aws_access_key_id=os.getenv('MINIO_ROOT_USER'),
    aws_secret_access_key=os.getenv('MINIO_ROOT_PASSWORD')
)

# Upload após TTS
s3_client.upload_file(
    audio_file,
    os.getenv('MINIO_BUCKET_JOBS'),
    f"{job_id}/chunks/chunk-{index}.wav"
)
```

---

### 4. **SSML Service**

#### Docker Compose
```yaml
ssml:
  environment:
    MINIO_ENDPOINT: ${MINIO_ENDPOINT}
    MINIO_ROOT_USER: ${MINIO_ROOT_USER}
    MINIO_ROOT_PASSWORD: ${MINIO_ROOT_PASSWORD}
    MINIO_BUCKET_TEMP: ${MINIO_BUCKET_TEMP}
```

#### Uso Futuro (Cache)
```python
# src/ssml_server.py
import os
import boto3
import hashlib

s3_client = boto3.client(
    's3',
    endpoint_url=os.getenv('MINIO_ENDPOINT'),
    aws_access_key_id=os.getenv('MINIO_ROOT_USER'),
    aws_secret_access_key=os.getenv('MINIO_ROOT_PASSWORD')
)

@app.route('/api/v1/ssml/parse', methods=['POST'])
def parse_ssml():
    ssml_text = request.json.get('text')
    
    # Gerar hash para cache
    cache_key = hashlib.md5(ssml_text.encode()).hexdigest()
    bucket = os.getenv('MINIO_BUCKET_TEMP')
    key = f"ssml-cache/{cache_key}.json"
    
    # Tentar buscar do cache
    try:
        response = s3_client.get_object(Bucket=bucket, Key=key)
        cached_result = json.loads(response['Body'].read())
        logger.info(f"Cache hit: {cache_key}")
        return jsonify(cached_result)
    except:
        pass
    
    # Parse SSML
    parser = SSMLParser()
    chunks = parser.parse(ssml_text)
    result = {
        'success': True,
        'chunks': chunks,
        # ...
    }
    
    # Salvar no cache
    s3_client.put_object(
        Bucket=bucket,
        Key=key,
        Body=json.dumps(result),
        ContentType='application/json'
    )
    
    return jsonify(result)
```

---

## 🔄 Fluxo Completo com MinIO

```
1. N8N Webhook
   ↓ (gera job_id)
   
2. N8N cria namespace
   → PUT s3://darkchannel-jobs/{job_id}/metadata.json
   
3. SSML Parser
   → [Opcional] GET cache de s3://darkchannel-temp/
   
4. Para cada chunk:
   ├─ OpenVoice/Kokoro gera áudio
   └─ POST /synthesize-to-s3
      → PUT s3://darkchannel-jobs/{job_id}/chunks/chunk-{n}.wav
   
5. N8N merge chunks
   ├─ GET todos chunks de s3://darkchannel-jobs/{job_id}/chunks/
   ├─ Merge local
   └─ PUT s3://darkchannel-jobs/{job_id}/final/audiobook.mp3
   
6. N8N copia para output
   → COPY s3://darkchannel-jobs/{job_id}/final/audiobook.mp3
      TO s3://darkchannel-output/{date}/{name}.mp3
   
7. N8N gera URL pré-assinada
   → GET presigned URL (válida por 1 hora)
   
8. Retorna ao cliente
   {
     "success": true,
     "download_url": "https://minio:9000/...",
     "expires_in": 3600
   }
```

---

## 📝 Checklist de Implementação

### Fase 1: Configuração
- [ ] Adicionar variáveis ao docker-compose de cada serviço
- [ ] Testar acesso ao MinIO de cada container
- [ ] Validar credenciais

### Fase 2: N8N
- [ ] Configurar credencial S3 no N8N
- [ ] Atualizar workflow para usar MinIO
- [ ] Testar upload/download

### Fase 3: OpenVoice
- [ ] Adicionar boto3 ao requirements
- [ ] Implementar `/synthesize-to-s3`
- [ ] Testar upload de áudio

### Fase 4: Kokoro
- [ ] Similar ao OpenVoice
- [ ] Testar integração

### Fase 5: SSML (Opcional)
- [ ] Implementar cache no MinIO
- [ ] Testar performance

---

## 🧪 Testes

### Teste 1: Conectividade
```bash
# De dentro de cada container
docker exec n8n curl http://minio:9000/minio/health/live
docker exec openvoice curl http://minio:9000/minio/health/live
docker exec kokoro-tts-cpu curl http://minio:9000/minio/health/live
docker exec ssml-service curl http://minio:9000/minio/health/live
```

### Teste 2: Upload via Python
```python
# Executar em cada serviço
import os
import boto3

s3 = boto3.client(
    's3',
    endpoint_url=os.getenv('MINIO_ENDPOINT'),
    aws_access_key_id=os.getenv('MINIO_ROOT_USER'),
    aws_secret_access_key=os.getenv('MINIO_ROOT_PASSWORD')
)

# Testar upload
s3.put_object(
    Bucket='darkchannel-temp',
    Key='test.txt',
    Body=b'Hello MinIO!'
)

print("Upload OK!")
```

---

## 🔒 Segurança

### Boas Práticas
1. **Nunca hardcode credenciais** - sempre usar variáveis de ambiente
2. **Não commitar .env** - adicionar ao .gitignore
3. **Usar secrets em produção** - Docker secrets ou Kubernetes secrets
4. **Rotacionar credenciais** - periodicamente
5. **Princípio do menor privilégio** - cada serviço só acessa buckets necessários

### Exemplo de Políticas Granulares (Futuro)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:PutObject", "s3:GetObject"],
      "Resource": ["arn:aws:s3:::darkchannel-jobs/*"]
    }
  ]
}
```

---

## 📚 Referências

- [Boto3 Documentation](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html)
- [MinIO Python SDK](https://min.io/docs/minio/linux/developers/python/minio-py.html)
- [N8N S3 Node](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.awss3/)
- [Docker Environment Variables](https://docs.docker.com/compose/environment-variables/)

---

**Status**: 🟡 Planejamento  
**Próximo**: Implementar variáveis no docker-compose

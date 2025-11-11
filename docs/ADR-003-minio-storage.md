# ADR-003: Integração MinIO para Armazenamento de Objetos

**Status**: 🟡 Proposto  
**Data**: 2025-11-09  
**Decisores**: Equipe DarkChannel  
**Contexto**: Necessidade de armazenamento escalável para múltiplos jobs simultâneos

---

## 📋 Contexto e Problema

### Situação Atual
O DarkChannel processa audiolivros através de workflows N8N que:
- Geram múltiplos arquivos de áudio (chunks)
- Processam jobs simultaneamente
- Precisam armazenar resultados temporários e finais
- Requerem isolamento entre jobs

### Problema
**Filesystem simples não é adequado para múltiplos jobs simultâneos**:
- ❌ Conflitos de nome de arquivo
- ❌ Race conditions
- ❌ Difícil rastreamento (qual arquivo pertence a qual job?)
- ❌ Limpeza manual de arquivos temporários
- ❌ Não escala para produção

### Requisitos
1. **Isolamento**: Cada job deve ter seu próprio namespace
2. **Concorrência**: Múltiplos jobs simultâneos sem conflitos
3. **Rastreabilidade**: Fácil identificar arquivos por job
4. **Limpeza**: Remoção automática de arquivos temporários
5. **Escalabilidade**: Preparado para crescimento
6. **Segurança**: Credenciais específicas por serviço
7. **Desacoplamento**: Configuração via variáveis de ambiente

---

## 🎯 Decisão

**Adotar MinIO como solução de armazenamento de objetos** para todos os arquivos de áudio gerados pelo sistema.

### Versão Escolhida
**`minio/minio:RELEASE.2025-04-22T22-12-26Z`**

**Justificativa da Versão**:
- ✅ UI administrativa completa (removida em versões posteriores)
- ✅ Gestão de buckets, usuários e políticas via web
- ✅ Estável e testada
- ✅ Suficiente para nosso caso de uso
- ⚠️ Versões após maio/2025 removeram UI administrativa

**Fonte**: Pesquisa sobre limitações da UI em versões recentes do MinIO Community Edition.

---

## 🔐 Modelo de Segurança

### Credenciais Separadas

**Root User** (Administração):
```env
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=miniopass123
```
- 🔐 Acesso administrativo total
- ✅ Criar buckets, usuários, políticas
- ⚠️ Usar APENAS para administração via UI/CLI
- 🚫 **NÃO usar nas aplicações**

**Service Account** (Aplicações):
```env
MINIO_ACCESS_KEY=darkchannel-app
MINIO_SECRET_KEY=darkchannel-secret-key-123
```
- 🔑 Chave específica para aplicações
- ✅ Acesso limitado (apenas buckets necessários)
- ✅ Pode ser revogada sem afetar admin
- ✅ **Usar em N8N, OpenVoice, Kokoro, SSML**
- 🔒 Princípio do menor privilégio

### Política de Acesso

O Service Account terá acesso apenas aos buckets necessários:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::darkchannel-jobs/*",
        "arn:aws:s3:::darkchannel-output/*",
        "arn:aws:s3:::darkchannel-refs/*",
        "arn:aws:s3:::darkchannel-temp/*",
        "arn:aws:s3:::darkchannel-jobs",
        "arn:aws:s3:::darkchannel-output",
        "arn:aws:s3:::darkchannel-refs",
        "arn:aws:s3:::darkchannel-temp"
      ]
    }
  ]
}
```

---

## 🏗️ Arquitetura

### Estrutura de Buckets

```
MinIO
├── darkchannel-jobs/          # Jobs em processamento
│   ├── {job-uuid}/
│   │   ├── metadata.json
│   │   ├── chunks/
│   │   │   ├── chunk-001.wav
│   │   │   ├── chunk-002.wav
│   │   │   └── ...
│   │   └── final/
│   │       └── audiobook.mp3
│   └── ...
│
├── darkchannel-output/        # Audiolivros finalizados
│   ├── {date}/
│   │   ├── {chapter-name}.mp3
│   │   └── ...
│   └── ...
│
├── darkchannel-refs/          # Vozes de referência
│   ├── narrator-voice.wav
│   ├── character-1.wav
│   └── ...
│
└── darkchannel-temp/          # Arquivos temporários
    └── ...                    # Auto-delete após 24h
```

### Fluxo de Dados

```
N8N Workflow
    ↓
1. Gera Job ID único (UUID)
    ↓
2. Cria namespace: s3://darkchannel-jobs/{job-id}/
    ↓
3. SSML Parser → chunks
    ↓
4. Para cada chunk:
    ├→ TTS (OpenVoice/Kokoro)
    ├→ Upload: s3://darkchannel-jobs/{job-id}/chunks/chunk-{n}.wav
    └→ Atualiza metadata.json
    ↓
5. Merge chunks
    ↓
6. Upload final: s3://darkchannel-jobs/{job-id}/final/audiobook.mp3
    ↓
7. Copia para: s3://darkchannel-output/{date}/{name}.mp3
    ↓
8. Retorna URL pré-assinada para download
    ↓
9. [Opcional] Move job para arquivo ou deleta após X dias
```

---

## 🔧 Implementação Técnica

### Variáveis de Ambiente

```env
# MinIO Docker Configuration
MINIO_IMAGE=minio/minio:RELEASE.2025-04-22T22-12-26Z
MINIO_MC_IMAGE=minio/mc:latest
MINIO_CONTAINER_NAME=minio

# MinIO Ports
MINIO_API_PORT=9000
MINIO_CONSOLE_PORT=9001

# MinIO Root Credentials (Admin apenas)
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=miniopass123

# MinIO Service Account (Para aplicações)
MINIO_ACCESS_KEY=darkchannel-app
MINIO_SECRET_KEY=darkchannel-secret-key-123

# MinIO Endpoints
MINIO_ENDPOINT=http://minio:9000
MINIO_ENDPOINT_EXTERNAL=http://localhost:9000
MINIO_BROWSER_REDIRECT_URL=http://localhost:9001

# MinIO Buckets
MINIO_BUCKET_JOBS=darkchannel-jobs
MINIO_BUCKET_OUTPUT=darkchannel-output
MINIO_BUCKET_REFS=darkchannel-refs
MINIO_BUCKET_TEMP=darkchannel-temp

# MinIO Policies
MINIO_TEMP_EXPIRY_DAYS=1
```

### Docker Compose - MinIO Server

```yaml
services:
  minio:
    image: ${MINIO_IMAGE:-minio/minio:RELEASE.2025-04-22T22-12-26Z}
    container_name: ${MINIO_CONTAINER_NAME:-minio}
    ports:
      - "${MINIO_API_PORT:-9000}:9000"
      - "${MINIO_CONSOLE_PORT:-9001}:9001"
    environment:
      MINIO_ROOT_USER: ${MINIO_ROOT_USER:-admin}
      MINIO_ROOT_PASSWORD: ${MINIO_ROOT_PASSWORD:-miniopass123}
      MINIO_BROWSER_REDIRECT_URL: ${MINIO_BROWSER_REDIRECT_URL:-http://localhost:9001}
    volumes:
      - minio_data:/data
    command: server /data --console-address ":9001"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - darkchannel-network
    restart: unless-stopped

volumes:
  minio_data:
    driver: local
```

### Docker Compose - MinIO Setup

```yaml
  minio-setup:
    image: ${MINIO_MC_IMAGE:-minio/mc:latest}
    depends_on:
      minio:
        condition: service_healthy
    environment:
      MINIO_ENDPOINT: ${MINIO_ENDPOINT:-http://minio:9000}
      MINIO_ROOT_USER: ${MINIO_ROOT_USER:-admin}
      MINIO_ROOT_PASSWORD: ${MINIO_ROOT_PASSWORD:-miniopass123}
      MINIO_ACCESS_KEY: ${MINIO_ACCESS_KEY:-darkchannel-app}
      MINIO_SECRET_KEY: ${MINIO_SECRET_KEY:-darkchannel-secret-key-123}
      MINIO_BUCKET_JOBS: ${MINIO_BUCKET_JOBS:-darkchannel-jobs}
      MINIO_BUCKET_OUTPUT: ${MINIO_BUCKET_OUTPUT:-darkchannel-output}
      MINIO_BUCKET_REFS: ${MINIO_BUCKET_REFS:-darkchannel-refs}
      MINIO_BUCKET_TEMP: ${MINIO_BUCKET_TEMP:-darkchannel-temp}
      MINIO_TEMP_EXPIRY_DAYS: ${MINIO_TEMP_EXPIRY_DAYS:-1}
    entrypoint: >
      /bin/sh -c "
      echo '🔧 Configurando MinIO...';
      sleep 5;
      
      echo '📝 Criando alias com root user...';
      mc alias set myminio $$MINIO_ENDPOINT $$MINIO_ROOT_USER $$MINIO_ROOT_PASSWORD;
      
      echo '📦 Criando buckets...';
      mc mb myminio/$$MINIO_BUCKET_JOBS --ignore-existing;
      mc mb myminio/$$MINIO_BUCKET_OUTPUT --ignore-existing;
      mc mb myminio/$$MINIO_BUCKET_REFS --ignore-existing;
      mc mb myminio/$$MINIO_BUCKET_TEMP --ignore-existing;
      
      echo '⏰ Configurando lifecycle policy (auto-delete temp)...';
      mc ilm add myminio/$$MINIO_BUCKET_TEMP --expiry-days $$MINIO_TEMP_EXPIRY_DAYS;
      
      echo '👤 Criando service account para aplicações...';
      mc admin user add myminio $$MINIO_ACCESS_KEY $$MINIO_SECRET_KEY;
      
      echo '🔐 Criando política de acesso...';
      cat > /tmp/darkchannel-policy.json <<EOF
{
  \"Version\": \"2012-10-17\",
  \"Statement\": [
    {
      \"Effect\": \"Allow\",
      \"Action\": [
        \"s3:GetObject\",
        \"s3:PutObject\",
        \"s3:DeleteObject\",
        \"s3:ListBucket\"
      ],
      \"Resource\": [
        \"arn:aws:s3:::$$MINIO_BUCKET_JOBS/*\",
        \"arn:aws:s3:::$$MINIO_BUCKET_OUTPUT/*\",
        \"arn:aws:s3:::$$MINIO_BUCKET_REFS/*\",
        \"arn:aws:s3:::$$MINIO_BUCKET_TEMP/*\",
        \"arn:aws:s3:::$$MINIO_BUCKET_JOBS\",
        \"arn:aws:s3:::$$MINIO_BUCKET_OUTPUT\",
        \"arn:aws:s3:::$$MINIO_BUCKET_REFS\",
        \"arn:aws:s3:::$$MINIO_BUCKET_TEMP\"
      ]
    }
  ]
}
EOF
      
      mc admin policy create myminio darkchannel-app-policy /tmp/darkchannel-policy.json;
      mc admin policy attach myminio darkchannel-app-policy --user $$MINIO_ACCESS_KEY;
      
      echo '✅ Setup concluído!';
      echo '🔑 Service Account: '$$MINIO_ACCESS_KEY;
      "
    networks:
      - darkchannel-network
```

### Integração com Serviços

Todos os serviços usarão o **Service Account** (não root):

```yaml
services:
  n8n:
    environment:
      MINIO_ENDPOINT: ${MINIO_ENDPOINT}
      MINIO_ACCESS_KEY: ${MINIO_ACCESS_KEY}
      MINIO_SECRET_KEY: ${MINIO_SECRET_KEY}
      MINIO_BUCKET_JOBS: ${MINIO_BUCKET_JOBS}
      MINIO_BUCKET_OUTPUT: ${MINIO_BUCKET_OUTPUT}
      MINIO_BUCKET_REFS: ${MINIO_BUCKET_REFS}
      MINIO_BUCKET_TEMP: ${MINIO_BUCKET_TEMP}

  openvoice:
    environment:
      MINIO_ENDPOINT: ${MINIO_ENDPOINT}
      MINIO_ACCESS_KEY: ${MINIO_ACCESS_KEY}
      MINIO_SECRET_KEY: ${MINIO_SECRET_KEY}
      MINIO_BUCKET_JOBS: ${MINIO_BUCKET_JOBS}
      MINIO_BUCKET_REFS: ${MINIO_BUCKET_REFS}

  kokoro-tts:
    environment:
      MINIO_ENDPOINT: ${MINIO_ENDPOINT}
      MINIO_ACCESS_KEY: ${MINIO_ACCESS_KEY}
      MINIO_SECRET_KEY: ${MINIO_SECRET_KEY}
      MINIO_BUCKET_JOBS: ${MINIO_BUCKET_JOBS}

  ssml:
    environment:
      MINIO_ENDPOINT: ${MINIO_ENDPOINT}
      MINIO_ACCESS_KEY: ${MINIO_ACCESS_KEY}
      MINIO_SECRET_KEY: ${MINIO_SECRET_KEY}
      MINIO_BUCKET_TEMP: ${MINIO_BUCKET_TEMP}
```

### Uso nos Serviços (Python/Boto3)

```python
import os
import boto3
from botocore.client import Config

# Configurar cliente S3 usando Service Account
s3_client = boto3.client(
    's3',
    endpoint_url=os.getenv('MINIO_ENDPOINT'),
    aws_access_key_id=os.getenv('MINIO_ACCESS_KEY'),
    aws_secret_access_key=os.getenv('MINIO_SECRET_KEY'),
    config=Config(signature_version='s3v4'),
    region_name='us-east-1'
)

# Upload de arquivo
s3_client.upload_file(
    'audio.wav',
    os.getenv('MINIO_BUCKET_JOBS'),
    f'{job_id}/chunks/chunk-001.wav'
)
```

---

## ✅ Consequências

### Positivas

1. **Isolamento Total**
   - Cada job tem seu próprio namespace
   - Sem conflitos entre jobs simultâneos

2. **Escalabilidade**
   - Suporta 10, 100, 1000+ jobs simultâneos
   - Preparado para produção

3. **Segurança**
   - Service Account com acesso limitado
   - Root user separado da aplicação
   - Princípio do menor privilégio

4. **Desacoplamento**
   - Configuração via variáveis de ambiente
   - Fácil trocar endpoints (dev → prod)
   - Fácil migrar para AWS S3 se necessário

5. **Rastreabilidade**
   - Fácil identificar arquivos por job
   - Metadata centralizado

6. **Limpeza Automática**
   - Lifecycle policies removem arquivos antigos
   - Sem acúmulo de lixo

7. **Integração Fácil**
   - N8N tem node S3 nativo
   - Python tem boto3 (cliente S3)
   - API compatível com AWS S3

8. **UI Administrativa**
   - Visualizar arquivos via web
   - Gestão de buckets e usuários
   - Monitoramento

### Negativas

1. **Complexidade Adicional**
   - Mais um serviço para gerenciar
   - Configuração de credenciais
   - Curva de aprendizado

2. **Overhead de Recursos**
   - ~100-200MB de RAM
   - ~100MB de espaço em disco (imagem)
   - CPU adicional

3. **Dependência**
   - Mais um ponto de falha
   - Precisa estar sempre rodando
   - Backup do MinIO necessário

4. **Versão Antiga**
   - Não receberá novas features
   - Possível falta de patches de segurança
   - Necessário monitorar vulnerabilidades

### Riscos e Mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|-------|--------------|---------|-----------|
| MinIO falhar | Baixa | Alto | Health checks + restart automático |
| Versão antiga vulnerável | Média | Médio | Monitorar CVEs + isolar na rede interna |
| Espaço em disco cheio | Média | Alto | Lifecycle policies + monitoramento |
| Perda de dados | Baixa | Alto | Backup regular do volume minio_data |
| Credenciais vazadas | Baixa | Alto | Service Account + não commitar .env |

---

## 🔄 Alternativas Consideradas

### 1. Continuar com Filesystem Docker
**Prós**: Simples, sem overhead  
**Contras**: Não resolve conflitos de jobs simultâneos  
**Decisão**: ❌ Rejeitado - não atende requisito de concorrência

### 2. Usar AWS S3 Real
**Prós**: Gerenciado, escalável, sem manutenção  
**Contras**: Custo, dependência externa, latência  
**Decisão**: ❌ Rejeitado - preferimos self-hosted

### 3. Usar MinIO Versão Mais Recente
**Prós**: Features novas, patches de segurança  
**Contras**: Sem UI administrativa  
**Decisão**: ❌ Rejeitado - UI é importante para desenvolvimento

### 4. Usar SeaweedFS
**Prós**: Open source, performático  
**Contras**: Menos maduro, menos integração  
**Decisão**: ❌ Rejeitado - MinIO tem melhor ecossistema

### 5. Usar Ceph
**Prós**: Enterprise-grade, muito escalável  
**Contras**: Complexo demais, overhead alto  
**Decisão**: ❌ Rejeitado - overkill para nosso caso

---

## 📅 Cronograma de Implementação

### Fase 1: Setup Básico (2 dias)
- [ ] Adicionar MinIO ao docker-compose
- [ ] Configurar buckets e políticas
- [ ] Criar Service Account
- [ ] Testar upload/download manual

### Fase 2: Helper Functions Python (2 dias)
- [ ] Cliente S3 wrapper
- [ ] Gestão de jobs
- [ ] Testes unitários

### Fase 3: Integração N8N (3 dias)
- [ ] Atualizar workflow para gerar Job IDs
- [ ] Integrar node S3 no workflow
- [ ] Testar workflow end-to-end com MinIO

### Fase 4: Integração Serviços TTS (3 dias)
- [ ] OpenVoice: Salvar áudios direto no MinIO
- [ ] Kokoro: Salvar áudios direto no MinIO
- [ ] Testes de concorrência (múltiplos jobs)

### Fase 5: Produção (2 dias)
- [ ] Backup automático do MinIO
- [ ] Monitoramento de espaço
- [ ] Alertas de falha
- [ ] Documentação de operação

**Total**: 12 dias

---

## 🎯 Critérios de Sucesso

1. ✅ 10+ jobs simultâneos sem conflitos
2. ✅ Isolamento completo entre jobs
3. ✅ Limpeza automática de arquivos temporários
4. ✅ UI acessível e funcional
5. ✅ Integração com N8N funcionando
6. ✅ Service Account funcionando (não usar root)
7. ✅ Tempo de upload/download < 1s para arquivos de 10MB
8. ✅ Zero perda de dados em 30 dias de operação

---

## 📚 Referências

1. **MinIO Documentation**: https://min.io/docs/minio/linux/index.html
2. **MinIO Access Management**: https://min.io/docs/minio/linux/administration/identity-access-management.html
3. **MinIO S3 API Compatibility**: https://docs.min.io/docs/minio-server-limits-per-tenant.html
4. **N8N S3 Node**: https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.awss3/
5. **Boto3 (Python S3 Client)**: https://boto3.amazonaws.com/v1/documentation/api/latest/index.html
6. **MinIO UI Limitations**: Pesquisa sobre remoção de UI em versões recentes
7. **Docker Compose Best Practices**: https://docs.docker.com/compose/compose-file/

---

**Status**: 🟡 Aguardando Aprovação  
**Próximo Passo**: Revisar ADR e aprovar implementação  
**Responsável**: Equipe DarkChannel

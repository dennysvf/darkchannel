# 📦 Projeto: Integração MinIO para Armazenamento de Objetos

**Versão**: 1.0.0  
**Data Início**: 2025-11-09  
**Status**: 🟡 Planejamento  
**ADR**: [ADR-003: MinIO Storage](./ADR-003-minio-storage.md)

---

## 🎯 Objetivo

Implementar MinIO como solução de armazenamento de objetos para suportar múltiplos jobs simultâneos de geração de audiolivros, com isolamento completo, rastreabilidade e limpeza automática.

---

## 📋 Escopo

### ✅ Incluído

1. **Infraestrutura**
   - MinIO server (versão 2025-04-22)
   - Setup automático de buckets
   - Configuração de lifecycle policies
   - Health checks e restart automático

2. **Integração N8N**
   - Geração de Job IDs únicos
   - Upload de chunks para MinIO
   - Download de resultados
   - Gestão de metadata

3. **Helper Functions**
   - Python SDK para S3
   - Upload/download helpers
   - Gestão de jobs
   - Cleanup utilities

4. **Documentação**
   - Guia de uso
   - API reference
   - Troubleshooting
   - Exemplos

### ❌ Excluído (Futuro)

- Replicação multi-site
- Integração com CDN
- Streaming de áudio direto do MinIO
- Versionamento de objetos
- Encryption at rest
- Multi-tenancy

---

## 🏗️ Arquitetura Detalhada

### Componentes

```
┌─────────────────────────────────────────────────────────┐
│                    DarkChannel Stack                     │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────┐      ┌──────────┐      ┌──────────┐     │
│  │   N8N    │─────▶│  MinIO   │◀─────│ OpenVoice│     │
│  │ Workflow │      │  Server  │      │   TTS    │     │
│  └──────────┘      └──────────┘      └──────────┘     │
│       │                  │                  │           │
│       │                  │                  │           │
│       ▼                  ▼                  ▼           │
│  ┌─────────────────────────────────────────────┐       │
│  │           MinIO Storage Buckets             │       │
│  ├─────────────────────────────────────────────┤       │
│  │ • darkchannel-jobs     (processing)         │       │
│  │ • darkchannel-output   (finalized)          │       │
│  │ • darkchannel-refs     (voice references)   │       │
│  │ • darkchannel-temp     (temporary, 24h)     │       │
│  └─────────────────────────────────────────────┘       │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Fluxo de Dados Detalhado

```
1. N8N Webhook Recebe Requisição
   ↓
2. Gera Job ID: uuid.uuid4()
   ↓
3. Cria Metadata Inicial
   {
     "job_id": "uuid-123",
     "status": "pending",
     "created_at": "2025-11-09T10:00:00Z",
     "chapter_title": "...",
     "input_text": "..."
   }
   ↓
4. Upload Metadata: s3://darkchannel-jobs/{job-id}/metadata.json
   ↓
5. SSML Parser → Chunks
   ↓
6. Para Cada Chunk (Paralelo):
   ├─ 6.1. TTS Gera Áudio
   ├─ 6.2. Upload: s3://darkchannel-jobs/{job-id}/chunks/chunk-{n}.wav
   ├─ 6.3. Atualiza Metadata (chunks_completed++)
   └─ 6.4. Log Progress
   ↓
7. Aguarda Todos os Chunks
   ↓
8. Merge Chunks (FFmpeg ou Pydub)
   ↓
9. Upload Final: s3://darkchannel-jobs/{job-id}/final/audiobook.mp3
   ↓
10. Copia para Output: s3://darkchannel-output/{date}/{name}.mp3
   ↓
11. Gera URL Pré-Assinada (1 hora de validade)
   ↓
12. Atualiza Metadata Final
   {
     "status": "completed",
     "output_url": "...",
     "completed_at": "..."
   }
   ↓
13. Retorna Resposta ao Cliente
   {
     "success": true,
     "job_id": "uuid-123",
     "download_url": "https://minio:9000/...",
     "expires_in": 3600
   }
```

---

## 📁 Estrutura de Arquivos

### Novos Arquivos

```
darkchannel/
├── docker-compose.yml                    # ← Atualizado
├── .env.example                          # ← Atualizado
├── docs/
│   ├── ADR-003-minio-storage.md         # ← Novo
│   ├── PROJECT-MINIO-INTEGRATION.md     # ← Novo
│   └── MINIO_GUIDE.md                   # ← Novo
├── src/
│   └── minio/
│       ├── __init__.py                  # ← Novo
│       ├── client.py                    # ← Novo (S3 client wrapper)
│       ├── jobs.py                      # ← Novo (Job management)
│       └── utils.py                     # ← Novo (Helper functions)
├── workflows/
│   └── ssml-openvoice-minio.json        # ← Novo (Workflow com MinIO)
└── scripts/
    ├── minio-setup.sh                   # ← Novo (Setup buckets)
    └── minio-backup.sh                  # ← Novo (Backup script)
```

---

## 🔧 Implementação por Fase

### **FASE 1: Setup Básico** (Sprint Atual - 2 dias)

#### Tarefas

**1.1. Adicionar MinIO ao Docker Compose**
- [ ] Adicionar serviço `minio` ao `docker-compose.yml`
- [ ] Adicionar serviço `minio-setup` para criar buckets
- [ ] Configurar volumes e networks
- [ ] Adicionar health checks
- [ ] Testar `docker-compose up minio`

**1.2. Configurar Credenciais**
- [ ] Adicionar variáveis ao `.env.example`
  ```env
  MINIO_ROOT_USER=admin
  MINIO_ROOT_PASSWORD=miniopass123
  MINIO_ENDPOINT=http://minio:9000
  MINIO_CONSOLE_URL=http://localhost:9001
  ```
- [ ] Documentar em `MINIO_GUIDE.md`

**1.3. Criar Buckets e Políticas**
- [ ] Script `minio-setup.sh` para criar buckets
- [ ] Configurar lifecycle policy para `darkchannel-temp`
- [ ] Testar criação manual via UI
- [ ] Validar políticas

**1.4. Testes Básicos**
- [ ] Upload manual via UI
- [ ] Download manual via UI
- [ ] Upload via `mc` CLI
- [ ] Download via `mc` CLI

**Critérios de Aceitação**:
- ✅ MinIO rodando e acessível em `http://localhost:9001`
- ✅ 4 buckets criados automaticamente
- ✅ Upload/download funcionando
- ✅ Lifecycle policy ativa em `darkchannel-temp`

---

### **FASE 2: Helper Functions Python** (Sprint Atual - 2 dias)

#### Tarefas

**2.1. Criar Cliente S3**
```python
# src/minio/client.py
from boto3 import client
from botocore.exceptions import ClientError

class MinIOClient:
    def __init__(self):
        self.s3 = client(
            's3',
            endpoint_url=os.getenv('MINIO_ENDPOINT'),
            aws_access_key_id=os.getenv('MINIO_ROOT_USER'),
            aws_secret_access_key=os.getenv('MINIO_ROOT_PASSWORD')
        )
    
    def upload_file(self, file_path, bucket, key):
        """Upload arquivo para MinIO"""
        pass
    
    def download_file(self, bucket, key, file_path):
        """Download arquivo do MinIO"""
        pass
    
    def generate_presigned_url(self, bucket, key, expiration=3600):
        """Gera URL pré-assinada"""
        pass
```

**2.2. Criar Gestão de Jobs**
```python
# src/minio/jobs.py
import uuid
import json
from datetime import datetime

class JobManager:
    def __init__(self, minio_client):
        self.client = minio_client
        self.bucket = 'darkchannel-jobs'
    
    def create_job(self, chapter_title, input_text):
        """Cria novo job"""
        job_id = str(uuid.uuid4())
        metadata = {
            "job_id": job_id,
            "status": "pending",
            "created_at": datetime.utcnow().isoformat(),
            "chapter_title": chapter_title,
            "input_text": input_text
        }
        # Upload metadata
        return job_id
    
    def update_job_status(self, job_id, status, **kwargs):
        """Atualiza status do job"""
        pass
    
    def get_job_metadata(self, job_id):
        """Recupera metadata do job"""
        pass
```

**2.3. Testes Unitários**
- [ ] Teste de upload
- [ ] Teste de download
- [ ] Teste de URL pré-assinada
- [ ] Teste de criação de job
- [ ] Teste de atualização de job

**Critérios de Aceitação**:
- ✅ Cliente S3 funcional
- ✅ Upload/download via Python
- ✅ Gestão de jobs implementada
- ✅ Testes passando

---

### **FASE 3: Integração N8N** (Sprint +1 - 3 dias)

#### Tarefas

**3.1. Atualizar Workflow**
- [ ] Adicionar node "Generate Job ID"
- [ ] Adicionar node "Upload to MinIO" após cada TTS
- [ ] Adicionar node "Download from MinIO" para merge
- [ ] Adicionar node "Generate Download URL"
- [ ] Testar workflow end-to-end

**3.2. Configurar Credenciais N8N**
- [ ] Adicionar credencial "AWS S3" no N8N
- [ ] Configurar endpoint MinIO
- [ ] Testar conexão

**3.3. Implementar Metadata Tracking**
- [ ] Upload metadata inicial
- [ ] Atualizar metadata após cada chunk
- [ ] Upload metadata final
- [ ] Endpoint para consultar status

**Critérios de Aceitação**:
- ✅ Workflow gerando Job IDs únicos
- ✅ Chunks salvos no MinIO
- ✅ Audiolivro final no MinIO
- ✅ URL de download funcionando
- ✅ Metadata rastreável

---

### **FASE 4: Integração Serviços TTS** (Sprint +2 - 3 dias)

#### Tarefas

**4.1. OpenVoice → MinIO**
- [ ] Adicionar endpoint `/synthesize-to-s3`
- [ ] Upload direto para MinIO após síntese
- [ ] Retornar S3 key em vez de arquivo
- [ ] Testar integração

**4.2. Kokoro → MinIO**
- [ ] Similar ao OpenVoice
- [ ] Testar integração

**4.3. Testes de Concorrência**
- [ ] Executar 10 jobs simultâneos
- [ ] Validar isolamento
- [ ] Verificar performance
- [ ] Identificar gargalos

**Critérios de Aceitação**:
- ✅ TTS salvando direto no MinIO
- ✅ 10+ jobs simultâneos sem conflitos
- ✅ Performance aceitável (< 2s por chunk)

---

### **FASE 5: Produção** (Sprint +3 - 2 dias)

#### Tarefas

**5.1. Backup**
- [ ] Script `minio-backup.sh`
- [ ] Cron job para backup diário
- [ ] Testar restore
- [ ] Documentar procedimento

**5.2. Monitoramento**
- [ ] Dashboard de espaço em disco
- [ ] Alertas de falha
- [ ] Métricas de uso
- [ ] Logs centralizados

**5.3. Documentação Final**
- [ ] Guia de operação
- [ ] Troubleshooting
- [ ] Disaster recovery
- [ ] Runbook

**Critérios de Aceitação**:
- ✅ Backup automático funcionando
- ✅ Monitoramento ativo
- ✅ Documentação completa
- ✅ Pronto para produção

---

## 📊 Estimativas

| Fase | Duração | Complexidade | Risco |
|------|---------|--------------|-------|
| Fase 1: Setup Básico | 2 dias | Baixa | Baixo |
| Fase 2: Helper Functions | 2 dias | Média | Baixo |
| Fase 3: Integração N8N | 3 dias | Média | Médio |
| Fase 4: Integração TTS | 3 dias | Alta | Médio |
| Fase 5: Produção | 2 dias | Média | Baixo |
| **TOTAL** | **12 dias** | - | - |

---

## 🎯 Métricas de Sucesso

### Performance
- ✅ Upload de 10MB em < 1s
- ✅ Download de 10MB em < 1s
- ✅ 10+ jobs simultâneos sem degradação
- ✅ Latência de API < 100ms

### Confiabilidade
- ✅ Uptime > 99.9%
- ✅ Zero perda de dados em 30 dias
- ✅ Recovery time < 5 minutos
- ✅ Backup diário bem-sucedido

### Usabilidade
- ✅ UI acessível e funcional
- ✅ Documentação completa
- ✅ Troubleshooting < 10 minutos
- ✅ Onboarding de novo dev < 1 hora

---

## ⚠️ Riscos e Mitigações

| Risco | Impacto | Probabilidade | Mitigação |
|-------|---------|---------------|-----------|
| MinIO falhar durante job | Alto | Baixa | Retry automático + health checks |
| Espaço em disco cheio | Alto | Média | Lifecycle policies + alertas |
| Performance degradada | Médio | Média | Testes de carga + otimização |
| Versão antiga vulnerável | Médio | Média | Monitorar CVEs + isolar rede |
| Integração N8N complexa | Médio | Baixa | POC antes da implementação |
| Perda de dados | Alto | Baixa | Backup diário + testes de restore |

---

## 📚 Recursos Necessários

### Infraestrutura
- **CPU**: +0.5 core (MinIO)
- **RAM**: +200MB (MinIO)
- **Disco**: +10GB inicial (crescimento conforme uso)
- **Network**: Banda interna Docker

### Desenvolvimento
- **Backend**: 1 dev Python (helper functions)
- **DevOps**: 1 dev (Docker + setup)
- **Integração**: 1 dev (N8N workflows)
- **QA**: Testes de concorrência e performance

### Ferramentas
- boto3 (Python S3 client)
- minio/mc (CLI)
- N8N S3 node
- Monitoring tools

---

## 📅 Cronograma

```
Semana 1:
  Seg-Ter: Fase 1 (Setup Básico)
  Qua-Qui: Fase 2 (Helper Functions)
  Sex:     Testes e ajustes

Semana 2:
  Seg-Qua: Fase 3 (Integração N8N)
  Qui-Sex: Fase 4 (Integração TTS) - Início

Semana 3:
  Seg:     Fase 4 (Integração TTS) - Conclusão
  Ter-Qua: Fase 5 (Produção)
  Qui-Sex: Testes finais e documentação
```

---

## ✅ Checklist de Aprovação

Antes de iniciar a implementação:

- [ ] ADR-003 revisado e aprovado
- [ ] Projeto revisado e aprovado
- [ ] Recursos alocados
- [ ] Cronograma validado
- [ ] Riscos aceitos
- [ ] Stakeholders alinhados

---

**Status**: 🟡 Aguardando Aprovação  
**Próximo Passo**: Revisar e aprovar para iniciar Fase 1  
**Responsável**: Equipe DarkChannel

# 📁 Estrutura do Projeto - DarkChannel Stack

Documentação completa da estrutura de arquivos e diretórios.

---

## 🗂️ Visão Geral

```
dark-channel/
├── 📄 README.md                      # Documentação principal
├── 📄 LICENSE                        # Licença MIT
├── 📄 docker-compose.yml             # Configuração Docker Compose
├── 📄 Dockerfile.n8n                 # Imagem customizada do N8N
├── 📄 Dockerfile.openvoice           # Imagem customizada do OpenVoice
├── 📄 .dockerignore                  # Arquivos ignorados no build
├── 📄 .gitignore                     # Arquivos ignorados no Git
├── 📄 .env.example                   # Exemplo de variáveis de ambiente
├── 📁 docs/                          # 📚 Documentação completa
│   ├── QUICKSTART.md                 # Guia rápido de início
│   ├── TROUBLESHOOTING.md            # Resolução de problemas
│   ├── PROJECT_STRUCTURE.md          # Este arquivo
│   ├── API_REFERENCE.md              # Referência completa das APIs
│   ├── KOKORO_API.md                 # Documentação Kokoro TTS
│   ├── OPENVOICE_API.md              # Documentação OpenVoice
│   ├── WORKFLOW_AUDIOBOOK.md         # Guia de audiolivros
│   └── ADR-001-openvoice.md          # Decisões arquiteturais
├── 📁 scripts/                       # 🔧 Scripts de automação
│   ├── start.bat                     # Iniciar stack (Windows)
│   ├── stop.bat                      # Parar stack (Windows)
│   ├── start.sh                      # Iniciar stack (Linux/Mac)
│   └── stop.sh                       # Parar stack (Linux/Mac)
├── 📁 src/                           # 💻 Código fonte
│   ├── openvoice-server.py           # Servidor HTTP do OpenVoice
│   └── openvoice-entrypoint.sh       # Script de inicialização
├── 📁 tests/                         # 🧪 Testes
│   ├── test-openvoice.py             # Testes do OpenVoice
│   └── test_pt_br.py                 # Testes em português
├── 📁 workflows/                     # 🔄 Workflows do N8N
│   ├── README.md                     # Documentação dos workflows
│   ├── workflow-kokoro-tts.json      # Teste Kokoro TTS
│   ├── workflow-openvoice-clone.json # Teste OpenVoice
│   └── workflow-audiobook-complete.json  # Gerador audiolivro
└── 📁 init-db.sql/                   # 🗄️ Scripts SQL de inicialização
```

---

## 📄 Descrição dos Arquivos

### Documentação

#### `README.md`
- **Propósito**: Documentação completa do projeto
- **Conteúdo**:
  - Instruções de instalação
  - Como rodar a stack
  - Comandos úteis
  - Configurações
  - Resolução de problemas básicos

#### `QUICKSTART.md`
- **Propósito**: Guia rápido para início imediato
- **Conteúdo**:
  - 3 passos para rodar
  - Links essenciais
  - Comandos básicos

#### `TROUBLESHOOTING.md`
- **Propósito**: Guia detalhado de resolução de problemas
- **Conteúdo**:
  - Problemas comuns e soluções
  - Comandos de diagnóstico
  - Dicas por sistema operacional

#### `PROJECT_STRUCTURE.md`
- **Propósito**: Documentação da estrutura do projeto
- **Conteúdo**: Este arquivo

---

### Configuração Docker

#### `docker-compose.yml`
- **Propósito**: Orquestração dos containers
- **Define**:
  - 3 serviços: n8n, postgres, kokoro-tts
  - Volumes persistentes
  - Rede interna
  - Variáveis de ambiente
  - Healthchecks

**Estrutura**:
```yaml
name: darkchannel
services:
  postgres:     # Banco de dados
  n8n:          # Plataforma de automação
  kokoro-tts:   # Text-to-speech
volumes:
  postgres_data:
  n8n_data:
networks:
  n8n_network:
```

#### `Dockerfile.n8n`
- **Propósito**: Criar imagem customizada do N8N
- **Modificações**:
  - Baseado em `n8nio/n8n:1.118.2`
  - Adiciona ffmpeg para processamento de mídia
  - Mantém configurações originais

**Conteúdo**:
```dockerfile
FROM n8nio/n8n:1.118.2
USER root
RUN apk add --no-cache ffmpeg
USER node
```

#### `.dockerignore`
- **Propósito**: Excluir arquivos do contexto de build
- **Ignora**:
  - Dados de volumes
  - Arquivos de ambiente
  - Logs
  - Arquivos temporários

---

### Configuração de Ambiente

#### `.env.example`
- **Propósito**: Template de variáveis de ambiente
- **Uso**:
  1. Copiar para `.env`
  2. Ajustar valores
  3. Nunca commitar `.env` no Git

**Variáveis**:
- Credenciais do PostgreSQL
- Configurações do N8N
- Portas dos serviços

#### `.gitignore`
- **Propósito**: Proteger dados sensíveis
- **Ignora**:
  - `.env` e variações
  - Dados de volumes
  - Backups
  - Logs
  - Arquivos temporários
  - Configurações de IDE

---

### Scripts de Automação

#### `start.bat` (Windows)
- **Propósito**: Iniciar a stack no Windows
- **Funcionalidades**:
  - Verifica se Docker está rodando
  - Inicia containers
  - Exibe URLs de acesso
  - Mostra mensagens de status

**Uso**:
```cmd
start.bat
```

#### `stop.bat` (Windows)
- **Propósito**: Parar a stack no Windows
- **Funcionalidades**:
  - Para todos os containers
  - Preserva dados
  - Exibe confirmação

**Uso**:
```cmd
stop.bat
```

#### `start.sh` (Linux/Mac)
- **Propósito**: Iniciar a stack no Linux/Mac
- **Funcionalidades**: Idênticas ao start.bat

**Uso**:
```bash
chmod +x start.sh
./start.sh
```

#### `stop.sh` (Linux/Mac)
- **Propósito**: Parar a stack no Linux/Mac
- **Funcionalidades**: Idênticas ao stop.bat

**Uso**:
```bash
chmod +x stop.sh
./stop.sh
```

---

## 📁 Diretórios

### `docs/` - Documentação
- **Propósito**: Centralizar toda a documentação do projeto
- **Conteúdo**:
  - Guias de início rápido e troubleshooting
  - Documentação completa das APIs
  - Guias de workflows e audiolivros
  - Decisões arquiteturais (ADRs)

### `scripts/` - Scripts de Automação
- **Propósito**: Scripts para facilitar operações comuns
- **Conteúdo**:
  - Scripts de start/stop para Windows (.bat)
  - Scripts de start/stop para Linux/Mac (.sh)
- **Uso**: Simplificam inicialização e parada da stack

### `src/` - Código Fonte
- **Propósito**: Código fonte customizado do projeto
- **Conteúdo**:
  - `openvoice-server.py`: Servidor HTTP Flask para OpenVoice
  - `openvoice-entrypoint.sh`: Script de inicialização do container
- **Uso**: Arquivos copiados para os containers Docker

### `tests/` - Testes
- **Propósito**: Scripts de teste e validação
- **Conteúdo**:
  - `test-openvoice.py`: Testes da API OpenVoice
  - `test_pt_br.py`: Testes específicos para português
- **Uso**: Validar funcionamento dos serviços

### `workflows/` - Workflows N8N
- **Propósito**: Armazenar workflows do N8N
- **Conteúdo**:
  - Workflows prontos para teste
  - Exemplos de uso das APIs
  - Pipeline completo de audiolivro
- **Uso**:
  - Versionamento de workflows
  - Backup de automações
  - Compartilhamento entre ambientes

**Montagem**:
```yaml
volumes:
  - ./workflows:/home/node/.n8n/workflows
```

### `init-db.sql/` - Scripts SQL
- **Propósito**: Scripts de inicialização do banco de dados
- **Uso**: Executados automaticamente na primeira inicialização do PostgreSQL

### Volumes Docker (Criados automaticamente)

#### `darkchannel_postgres_data`
- **Conteúdo**: Dados do PostgreSQL
- **Localização**: Gerenciado pelo Docker
- **Persistência**: Mantido entre reinicializações

#### `darkchannel_n8n_data`
- **Conteúdo**: 
  - Workflows do N8N
  - Credenciais
  - Configurações
  - Histórico de execuções
- **Localização**: Gerenciado pelo Docker
- **Persistência**: Mantido entre reinicializações

---

## 🔒 Arquivos Sensíveis (Não Versionados)

Estes arquivos **NÃO** devem ser commitados no Git:

- `.env` - Variáveis de ambiente com credenciais
- `*.sql` - Backups do banco de dados
- `*.log` - Arquivos de log
- `workflows/` - (opcional) Se contiver dados sensíveis

---

## 🌐 Rede Docker

### `darkchannel_n8n_network`
- **Tipo**: Bridge
- **Propósito**: Comunicação entre containers
- **Containers conectados**:
  - n8n
  - postgres
  - kokoro-tts

**Comunicação interna**:
- N8N → PostgreSQL: `postgres:5432`
- N8N → Kokoro TTS: `kokoro-tts:8880`

---

## 📦 Volumes e Persistência

### O que é persistido?

✅ **Persistido** (mantido após `docker-compose down`):
- Workflows do N8N
- Credenciais do N8N
- Dados do PostgreSQL
- Histórico de execuções

❌ **Não persistido** (perdido após `docker-compose down -v`):
- Logs dos containers
- Cache temporário
- Processos em execução

---

## 🔄 Fluxo de Dados

```
┌─────────────────┐
│   Usuário       │
│  (Navegador)    │
└────────┬────────┘
         │
         │ http://localhost:5678
         ▼
┌─────────────────┐
│      N8N        │◄──────┐
│  (Container)    │       │
└────────┬────────┘       │
         │                │
         │ postgres:5432  │ kokoro-tts:8880
         ▼                │
┌─────────────────┐       │
│   PostgreSQL    │       │
│  (Container)    │       │
└─────────────────┘       │
                          │
                 ┌────────┴────────┐
                 │   Kokoro TTS    │
                 │   (Container)   │
                 └─────────────────┘
```

---

## 🛠️ Customização

### Adicionar novo serviço

1. Edite `docker-compose.yml`
2. Adicione o serviço na seção `services:`
3. Configure volumes e redes
4. Atualize documentação

### Alterar versão do N8N

1. Edite `Dockerfile.n8n`
2. Altere a linha `FROM n8nio/n8n:X.X.X`
3. Rebuild: `docker-compose build n8n`

### Adicionar variável de ambiente

1. Edite `.env.example`
2. Adicione a variável
3. Edite `docker-compose.yml`
4. Adicione na seção `environment:`

---

## 📊 Tamanhos Aproximados

| Item | Tamanho |
|------|---------|
| Imagem N8N base | ~500 MB |
| Imagem N8N + ffmpeg | ~550 MB |
| Imagem PostgreSQL | ~150 MB |
| Imagem Kokoro TTS | ~1.4 GB |
| **Total (primeira vez)** | **~2.6 GB** |

---

## 🔍 Localização dos Dados

### Windows
```
C:\ProgramData\Docker\volumes\darkchannel_postgres_data\_data
C:\ProgramData\Docker\volumes\darkchannel_n8n_data\_data
```

### Linux
```
/var/lib/docker/volumes/darkchannel_postgres_data/_data
/var/lib/docker/volumes/darkchannel_n8n_data/_data
```

### Mac
```
~/Library/Containers/com.docker.docker/Data/vms/0/data/docker/volumes/
```

---

## 📝 Notas Importantes

1. **Nunca edite** arquivos diretamente nos volumes Docker
2. **Use comandos Docker** para interagir com os dados
3. **Faça backups** regularmente do banco de dados
4. **Mantenha** o `.env` fora do controle de versão
5. **Documente** qualquer customização que fizer

---

**Estrutura mantida por**: DarkChannel Team 🎯

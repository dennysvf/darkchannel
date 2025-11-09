# 🚀 DarkChannel Stack - N8N + PostgreSQL + Kokoro TTS

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)
[![N8N](https://img.shields.io/badge/N8N-1.118.2-orange.svg)](https://n8n.io/)

Stack completa para automação com N8N, incluindo banco de dados PostgreSQL e serviço de text-to-speech Kokoro TTS.

## ✨ Características

- 🔄 **N8N** - Plataforma de automação de workflows
- 🎬 **FFmpeg** - Processamento de áudio e vídeo integrado
- 💾 **PostgreSQL** - Banco de dados robusto e confiável
- 🎤 **Kokoro TTS** - Conversão de texto para áudio (síntese rápida)
- 🎙️ **OpenVoice** - Clonagem e aprimoramento de voz (voice cloning)
- 🐳 **Docker** - Fácil deploy e portabilidade
- 📦 **Tudo em um** - Stack completa pronta para uso

## 📋 Pré-requisitos

Antes de começar, você precisa instalar:

### 1. Docker Desktop

#### Windows
1. **Baixe** o Docker Desktop: https://www.docker.com/products/docker-desktop/
2. **Execute** o instalador `Docker Desktop Installer.exe`
3. **Siga** o assistente de instalação
4. **Reinicie** o computador quando solicitado
5. **Abra** o Docker Desktop e aguarde inicializar
6. **Verifique** se o Docker está rodando (ícone da baleia na bandeja do sistema)

#### Mac
1. **Baixe** o Docker Desktop: https://www.docker.com/products/docker-desktop/
2. **Arraste** o Docker.app para a pasta Applications
3. **Abra** o Docker Desktop
4. **Aguarde** a inicialização completa

#### Linux
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

### 2. Git (Opcional)

Se quiser clonar o repositório:

#### Windows
- **Baixe**: https://git-scm.com/download/win
- **Execute** o instalador e siga as instruções

#### Mac
```bash
brew install git
```

#### Linux
```bash
sudo apt-get install git
```

---

## 📥 Como Baixar os Arquivos

### Opção 1: Clonar com Git
```bash
git clone [URL_DO_REPOSITORIO]
cd [NOME_DA_PASTA]
```

### Opção 2: Download Manual
1. Acesse o repositório no GitHub
2. Clique em **"Code"** → **"Download ZIP"**
3. Extraia o arquivo ZIP
4. Abra o terminal/prompt na pasta extraída

---

## 🏗️ Estrutura dos Arquivos

```
📁 dark-channel/
├── 📄 docker-compose.yml           # Configuração principal do Docker
├── 📄 Dockerfile.n8n               # Imagem customizada do N8N com ffmpeg
├── 📄 Dockerfile.openvoice         # Imagem customizada do OpenVoice
├── 📄 .dockerignore                # Arquivos ignorados no build
├── 📄 .env.example                 # Exemplo de variáveis de ambiente
├── 📄 .gitignore                   # Arquivos ignorados no Git
├── 📄 LICENSE                      # Licença MIT
├── 📄 README.md                    # Este arquivo
├── 📁 docs/                        # 📚 Documentação completa
│   ├── QUICKSTART.md               # Guia rápido de início
│   ├── TROUBLESHOOTING.md          # Resolução de problemas
│   ├── PROJECT_STRUCTURE.md        # Estrutura detalhada do projeto
│   ├── API_REFERENCE.md            # Referência completa das APIs
│   ├── KOKORO_API.md               # Documentação da API Kokoro TTS
│   ├── OPENVOICE_API.md            # Documentação da API OpenVoice
│   ├── WORKFLOW_AUDIOBOOK.md       # Guia de criação de audiolivros
│   └── ADR-001-openvoice.md        # Decisões arquiteturais
├── 📁 scripts/                     # 🔧 Scripts de automação
│   ├── start.bat                   # Iniciar stack (Windows)
│   ├── stop.bat                    # Parar stack (Windows)
│   ├── start.sh                    # Iniciar stack (Linux/Mac)
│   └── stop.sh                     # Parar stack (Linux/Mac)
├── 📁 src/                         # 💻 Código fonte
│   ├── openvoice-server.py         # Servidor HTTP do OpenVoice
│   └── openvoice-entrypoint.sh     # Script de inicialização
├── 📁 tests/                       # 🧪 Testes
│   ├── test-openvoice.py           # Testes do OpenVoice
│   └── test_pt_br.py               # Testes em português
├── 📁 workflows/                   # 🔄 Workflows do N8N
│   ├── README.md                   # Documentação dos workflows
│   ├── workflow-kokoro-tts.json    # Teste Kokoro TTS
│   ├── workflow-openvoice-clone.json  # Teste OpenVoice
│   └── workflow-audiobook-complete.json  # Gerador de audiolivro
└── 📁 init-db.sql/                 # 🗄️ Scripts SQL de inicialização
```

---

## 🚀 Como Rodar a Stack

### Passo 1: Abrir Terminal na Pasta do Projeto

#### Windows
1. Abra a pasta do projeto no Explorer
2. Clique na barra de endereço
3. Digite `cmd` ou `powershell` e pressione Enter

#### Mac/Linux
```bash
cd /caminho/para/a/pasta
```

### Passo 2: Iniciar a Stack

```bash
docker-compose up -d
```

**O que acontece:**
- ⬇️ Download das imagens (primeira vez pode demorar ~5-10 minutos)
- 🔨 Build da imagem customizada do N8N com ffmpeg
- 🚀 Inicialização dos containers

### Passo 3: Aguardar Inicialização

```bash
# Ver logs em tempo real
docker-compose logs -f

# Pressione Ctrl+C para sair dos logs
```

### Passo 4: Verificar se Está Rodando

```bash
docker-compose ps
```

Você deve ver 3 containers rodando:
- ✅ `n8n` - Estado: Up
- ✅ `n8n-postgres` - Estado: Up
- ✅ `kokoro-tts-cpu` - Estado: Up

---

## 🌐 Acessar os Serviços

Após a inicialização completa:

| Serviço | URL | Descrição |
|---------|-----|-----------|
| **N8N** | http://localhost:5678 | Interface de automação |
| **Kokoro TTS** | http://localhost:8880 | API de text-to-speech |
| **OpenVoice** | http://localhost:8000 | API de clonagem de voz |
| **PostgreSQL** | localhost:5432 | Banco de dados |

### Primeiro Acesso ao N8N

1. Abra: http://localhost:5678
2. **Crie** sua conta de administrador
3. **Configure** seu e-mail e senha
4. **Importe** os workflows prontos da pasta `workflows/`
5. Pronto! Você já pode testar os serviços

### 🔄 Workflows Prontos

Incluímos 3 workflows prontos para uso:

| Workflow | Arquivo | Descrição |
|----------|---------|-----------|
| 🎤 **Teste Kokoro TTS** | `workflow-kokoro-tts.json` | Teste simples de síntese de voz |
| 🎙️ **Teste OpenVoice** | `workflow-openvoice-clone.json` | Teste de clonagem de voz |
| 📚 **Gerador de Audiolivro** | `workflow-audiobook-complete.json` | Pipeline completo para audiolivros |

**Como importar**: Menu ☰ → Import from File → Selecione o arquivo JSON

Veja mais detalhes em: [workflows/README.md](workflows/README.md)

---

## ⚡ Scripts de Automação

Para facilitar o uso, incluímos scripts prontos na pasta `scripts/`:

### Windows
```cmd
# Iniciar a stack
scripts\start.bat

# Parar a stack
scripts\stop.bat
```

### Linux/Mac
```bash
# Dar permissão de execução (primeira vez)
chmod +x scripts/*.sh

# Iniciar a stack
./scripts/start.sh

# Parar a stack
./scripts/stop.sh
```

Os scripts verificam automaticamente se o Docker está rodando e exibem os URLs de acesso.

---

## 🛠️ Comandos Úteis

### Parar a Stack
```bash
docker-compose down
```

### Reiniciar a Stack
```bash
docker-compose restart
```

### Ver Logs de um Serviço Específico
```bash
# N8N
docker-compose logs -f n8n

# PostgreSQL
docker-compose logs -f postgres

# Kokoro TTS
docker-compose logs -f kokoro-tts
```

### Reconstruir a Imagem do N8N
```bash
docker-compose build n8n
docker-compose up -d
```

### Limpar Tudo (⚠️ Apaga dados!)
```bash
docker-compose down -v
```

---

## 🔧 Configurações Avançadas

### Alterar Portas

Edite o arquivo `docker-compose.yml`:

```yaml
ports:
  - "5678:5678"  # Altere 5678 para outra porta
```

### Adicionar Variáveis de Ambiente

No `docker-compose.yml`, seção `environment` do serviço `n8n`:

```yaml
environment:
  - MINHA_VARIAVEL=valor
```

### Backup do Banco de Dados

```bash
docker exec n8n-postgres pg_dump -U postgres n8n_db > backup.sql
```

### Restaurar Backup

```bash
docker exec -i n8n-postgres psql -U postgres n8n_db < backup.sql
```

---

## 📦 O que Está Incluído

### N8N (com ffmpeg)
- **Versão**: 1.118.2
- **Recursos**: Automação de workflows, webhooks, integrações
- **Extra**: ffmpeg instalado para processamento de mídia

### PostgreSQL
- **Versão**: 15
- **Banco**: n8n_db
- **Usuário**: postgres
- **Senha**: postgres123

### Kokoro TTS
- **Versão**: v0.2.2
- **Tipo**: CPU (não requer GPU)
- **Uso**: Conversão de texto para áudio (síntese rápida)

### OpenVoice
- **Tipo**: CPU (não requer GPU)
- **Uso**: Clonagem e aprimoramento de voz
- **API**: REST HTTP
- **Documentação**: [docs/OPENVOICE_API.md](docs/OPENVOICE_API.md)

---

## 🔐 Credenciais Padrão

### PostgreSQL
- **Host**: postgres (interno) ou localhost (externo)
- **Porta**: 5432
- **Database**: n8n_db
- **Usuário**: postgres
- **Senha**: postgres123

⚠️ **IMPORTANTE**: Altere a senha em produção!

---

## 🐛 Resolução de Problemas

### Erro: "port is already allocated"
**Causa**: Porta já está em uso  
**Solução**: Altere a porta no docker-compose.yml ou pare o serviço que está usando a porta

### Erro: "Cannot connect to Docker daemon"
**Causa**: Docker Desktop não está rodando  
**Solução**: Abra o Docker Desktop e aguarde inicializar

### N8N não abre no navegador
**Causa**: Container ainda está inicializando  
**Solução**: 
```bash
docker-compose logs -f n8n
# Aguarde ver: "Editor is now accessible via: http://localhost:5678"
```

### Kokoro TTS demora muito para iniciar
**Causa**: Imagem grande (~1.4GB)  
**Solução**: Aguarde o download completo na primeira execução

### Erro de permissão (Linux)
**Causa**: Usuário não está no grupo docker  
**Solução**:
```bash
sudo usermod -aG docker $USER
# Faça logout e login novamente
```

---

## 📚 Documentação Completa

Toda a documentação está organizada na pasta `docs/`:

### 📖 Guias
- **[QUICKSTART.md](docs/QUICKSTART.md)** - Início rápido em 3 passos
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Resolução de problemas detalhada
- **[PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md)** - Estrutura completa do projeto

### 🔌 APIs
- **[API_REFERENCE.md](docs/API_REFERENCE.md)** - Referência completa das APIs
- **[KOKORO_API.md](docs/KOKORO_API.md)** - Documentação Kokoro TTS
- **[OPENVOICE_API.md](docs/OPENVOICE_API.md)** - Documentação OpenVoice

### 🎯 Workflows
- **[WORKFLOW_AUDIOBOOK.md](docs/WORKFLOW_AUDIOBOOK.md)** - Guia de criação de audiolivros
- **[workflows/README.md](workflows/README.md)** - Documentação dos workflows prontos

### 🏗️ Arquitetura
- **[ADR-001-openvoice.md](docs/ADR-001-openvoice.md)** - Decisões arquiteturais

### Recursos Externos
- **N8N**: https://docs.n8n.io/
- **Docker**: https://docs.docker.com/
- **PostgreSQL**: https://www.postgresql.org/docs/
- **N8N Forum**: https://community.n8n.io/
- **Discord N8N**: https://discord.gg/n8n

---

## 🔄 Atualizações

### Atualizar N8N para Nova Versão

1. Edite `Dockerfile.n8n` e altere a versão:
```dockerfile
FROM n8nio/n8n:1.120.0  # Nova versão
```

2. Reconstrua:
```bash
docker-compose build n8n
docker-compose up -d
```

---

## 📝 Notas Importantes

- ✅ Os dados do N8N e PostgreSQL são persistidos em volumes Docker
- ✅ Mesmo parando os containers, seus workflows e dados são mantidos
- ⚠️ Use `down -v` apenas se quiser apagar TUDO
- 🔒 Em produção, altere as senhas e use HTTPS

---

## 💡 Dicas

1. **Backup Regular**: Faça backup do banco de dados periodicamente
2. **Variáveis de Ambiente**: Use arquivo `.env` para credenciais sensíveis
3. **Logs**: Monitore os logs regularmente para identificar problemas
4. **Recursos**: Ajuste memória e CPU no Docker Desktop se necessário

---

## 🆘 Suporte

Se encontrar problemas:

1. Verifique os logs: `docker-compose logs`
2. Consulte a seção de resolução de problemas acima
3. Abra uma issue no repositório do projeto

---

## 📄 Licença

Este projeto está licenciado sob a [MIT License](LICENSE) - veja o arquivo LICENSE para detalhes.

Você é livre para:
- ✅ Usar comercialmente
- ✅ Modificar
- ✅ Distribuir
- ✅ Uso privado

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para:

1. Fazer fork do projeto
2. Criar uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'feat: adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abrir um Pull Request

---

## ⭐ Apoie o Projeto

Se este projeto foi útil para você, considere:
- ⭐ Dar uma estrela no GitHub
- 🐛 Reportar bugs
- 💡 Sugerir melhorias
- 📢 Compartilhar com outros

---

**Desenvolvido por DarkChannel** 🎯  
**Compartilhado com a comunidade** ❤️
# darkchannel

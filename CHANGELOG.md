# 📝 Changelog - DarkChannel Stack

## [Reorganização] - 2025-11-09

### 🎯 Reorganização Completa do Projeto

#### ✨ Melhorias na Estrutura
- **Separação clara**: Código, documentação, scripts e testes agora em pastas dedicadas
- **Raiz limpa**: Apenas arquivos essenciais (docker-compose, Dockerfiles, README, LICENSE)
- **Melhor navegação**: Estrutura intuitiva e organizada

#### 📁 Nova Estrutura de Pastas

```
dark-channel/
├── 📚 docs/          → Toda a documentação (8 arquivos)
├── 🔧 scripts/       → Scripts de automação (4 arquivos)
├── 💻 src/           → Código fonte Python/Shell (2 arquivos)
├── 🧪 tests/         → Scripts de teste (2 arquivos)
└── 🔄 workflows/     → Workflows N8N (4 arquivos)
```

#### 📦 Arquivos Movidos

**Para `docs/`:**
- PROJECT_STRUCTURE.md
- QUICKSTART.md
- TROUBLESHOOTING.md
- (+ 5 arquivos já existentes)

**Para `scripts/`:**
- start.bat / start.sh
- stop.bat / stop.sh

**Para `src/`:**
- openvoice-server.py
- openvoice-entrypoint.sh

**Para `tests/`:**
- test-openvoice.py
- test_pt_br.py

#### 🔧 Atualizações de Configuração

- **Dockerfile.openvoice**: Caminhos atualizados para `src/`
- **.gitignore**: Adicionadas entradas para cache Python e outputs de teste
- **README.md**: 
  - Estrutura de arquivos atualizada
  - Nova seção de scripts de automação
  - Seção expandida de documentação com links
- **PROJECT_STRUCTURE.md**: Descrições detalhadas de todas as pastas

#### 📝 Simplificação de Comandos

Todos os comandos docker-compose foram simplificados:
- ❌ Antes: `docker-compose -f docker-compose.simple.yml up -d`
- ✅ Agora: `docker-compose up -d`

Arquivo renomeado: `docker-compose.simple.yml` → `docker-compose.yml`

#### 🎁 Benefícios

1. **Organização**: Fácil encontrar documentação, código e scripts
2. **Manutenibilidade**: Estrutura clara facilita manutenção
3. **Profissionalismo**: Projeto segue boas práticas de organização
4. **Escalabilidade**: Estrutura preparada para crescimento
5. **Simplicidade**: Comandos mais curtos e intuitivos

---

## Versões Anteriores

### [Inicial] - 2025-11-08
- Configuração inicial do projeto
- Integração N8N + PostgreSQL + Kokoro TTS + OpenVoice
- Workflows prontos para uso
- Documentação básica

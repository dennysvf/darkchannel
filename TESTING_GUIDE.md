# 🧪 Guia de Testes - SSML Service

**Data**: 2025-11-09  
**Versão**: 1.0  
**Status**: Pronto para Testes

---

## 📋 Pré-requisitos

- ✅ Docker Desktop rodando
- ✅ Porta 8888 disponível
- ✅ Git atualizado com últimas mudanças

---

## 🚀 Passo 1: Build da Imagem

```bash
# Navegar para o projeto
cd c:\projetos\dark-channel

# Build apenas do serviço SSML
docker-compose build ssml

# Ou build de todos os serviços
docker-compose build
```

**Tempo estimado**: 2-3 minutos

**Saída esperada**:
```
[+] Building 120.5s (12/12) FINISHED
 => [internal] load build definition from Dockerfile.ssml
 => => transferring dockerfile: 1.2kB
 => [internal] load .dockerignore
 => ...
 => => naming to docker.io/library/darkchannel-ssml:latest
```

---

## 🏃 Passo 2: Iniciar o Serviço

```bash
# Iniciar apenas SSML
docker-compose up -d ssml

# Ou iniciar toda a stack
docker-compose up -d
```

**Verificar status**:
```bash
docker-compose ps
```

**Saída esperada**:
```
NAME            IMAGE                          STATUS
ssml-service    darkchannel-ssml:latest        Up (healthy)
```

---

## 🔍 Passo 3: Verificar Logs

```bash
# Ver logs do SSML
docker-compose logs -f ssml
```

**Saída esperada**:
```
ssml-service  | INFO:     Started server process [1]
ssml-service  | INFO:     Waiting for application startup.
ssml-service  | INFO:     Application startup complete.
ssml-service  | INFO:     Uvicorn running on http://0.0.0.0:8888
```

---

## ✅ Passo 4: Testes Básicos

### 4.1 Health Check

```bash
curl http://localhost:8888/health
```

**Resposta esperada**:
```json
{"status":"healthy"}
```

### 4.2 Info do Serviço

```bash
curl http://localhost:8888/api/v1/info
```

**Resposta esperada**:
```json
{
  "service": "SSML Parser Service",
  "version": "1.0.0",
  "language": "pt-BR",
  "supported_tags": [
    "speak", "break", "prosody", "phoneme", "emphasis", "p", "s"
  ],
  "features": {
    "break": "Pausas controladas",
    "prosody_rate": "Controle de velocidade (OpenVoice V2)",
    "prosody_pitch": "Controle de tom (OpenVoice V2)",
    "phoneme": "Pronúncia fonética (IPA)",
    "emphasis": "Ênfase em palavras"
  }
}
```

---

## 🧪 Passo 5: Testes Funcionais

### 5.1 Teste Simples

```bash
curl -X POST http://localhost:8888/api/v1/ssml/parse \
  -H "Content-Type: application/json" \
  -d '{
    "text": "<speak>Olá mundo</speak>"
  }' | jq
```

**Resposta esperada**:
```json
{
  "success": true,
  "chunks": [
    {
      "type": "text",
      "content": "Olá mundo",
      "metadata": {}
    }
  ],
  "plain_text": "Olá mundo",
  "total_breaks": 0,
  "total_duration": 0
}
```

### 5.2 Teste com Pausas

```bash
curl -X POST http://localhost:8888/api/v1/ssml/parse \
  -H "Content-Type: application/json" \
  -d '{
    "text": "<speak>Olá <break time=\"1.5s\"/> mundo</speak>"
  }' | jq
```

**Resposta esperada**:
```json
{
  "success": true,
  "chunks": [
    {
      "type": "text",
      "content": "Olá",
      "metadata": {}
    },
    {
      "type": "break",
      "duration": 1.5,
      "metadata": {}
    },
    {
      "type": "text",
      "content": "mundo",
      "metadata": {}
    }
  ],
  "plain_text": "Olá mundo",
  "total_breaks": 1,
  "total_duration": 1.5
}
```

### 5.3 Teste com Prosody

```bash
curl -X POST http://localhost:8888/api/v1/ssml/parse \
  -H "Content-Type: application/json" \
  -d '{
    "text": "<speak><prosody rate=\"slow\" pitch=\"-2\">Texto devagar</prosody></speak>"
  }' | jq
```

**Resposta esperada**:
```json
{
  "success": true,
  "chunks": [
    {
      "type": "text",
      "content": "Texto devagar",
      "metadata": {
        "rate": "slow",
        "speed": 0.8,
        "pitch": -2
      }
    }
  ],
  "plain_text": "Texto devagar",
  "total_breaks": 0,
  "total_duration": 0
}
```

### 5.4 Teste com Phoneme

```bash
curl -X POST http://localhost:8888/api/v1/ssml/parse \
  -H "Content-Type: application/json" \
  -d '{
    "text": "<speak><phoneme alphabet=\"ipa\" ph=\"ʒoˈɐ̃w\">João</phoneme> chegou</speak>"
  }' | jq
```

**Resposta esperada**:
```json
{
  "success": true,
  "chunks": [
    {
      "type": "text",
      "content": "João",
      "metadata": {
        "phoneme": {
          "alphabet": "ipa",
          "pronunciation": "ʒoˈɐ̃w",
          "original": "João"
        }
      }
    },
    {
      "type": "text",
      "content": "chegou",
      "metadata": {}
    }
  ],
  "plain_text": "João chegou",
  "total_breaks": 0,
  "total_duration": 0
}
```

### 5.5 Teste Complexo (Audiolivro)

```bash
curl -X POST http://localhost:8888/api/v1/ssml/parse \
  -H "Content-Type: application/json" \
  -d '{
    "text": "<speak>Capítulo 1: O Início.<break time=\"2s\"/><prosody rate=\"0.9\">Era uma vez</prosody><break time=\"1s\"/>um menino chamado <phoneme alphabet=\"ipa\" ph=\"ˈpedɾu\">Pedro</phoneme>.</speak>"
  }' | jq
```

---

## 🔬 Passo 6: Teste de Validação

```bash
# SSML válido
curl -X POST http://localhost:8888/api/v1/ssml/validate \
  -H "Content-Type: application/json" \
  -d '{
    "text": "<speak>Texto válido</speak>"
  }' | jq

# SSML inválido
curl -X POST http://localhost:8888/api/v1/ssml/validate \
  -H "Content-Type: application/json" \
  -d '{
    "text": "<speak>Tag não fechada"
  }' | jq
```

---

## 🐛 Passo 7: Testes de Erro

### 7.1 SSML Mal-formado

```bash
curl -X POST http://localhost:8888/api/v1/ssml/parse \
  -H "Content-Type: application/json" \
  -d '{
    "text": "<speak><break time=\"abc\"/></speak>"
  }' | jq
```

**Comportamento esperado**: Deve fazer fallback para texto plano

### 7.2 Tag Não Suportada

```bash
curl -X POST http://localhost:8888/api/v1/ssml/parse \
  -H "Content-Type: application/json" \
  -d '{
    "text": "<speak><emotion type=\"happy\">Feliz!</emotion></speak>"
  }' | jq
```

**Comportamento esperado**: Deve processar como texto normal

---

## 🧪 Passo 8: Testes Unitários

```bash
# Entrar no container
docker exec -it ssml-service bash

# Executar testes
cd /app
python tests/ssml/test_parser.py
```

**Saída esperada**:
```
Executando testes...
✅ test_parse_simple_text
✅ test_parse_with_break
✅ test_parse_prosody
✅ test_parse_phoneme
✅ test_parse_complex

🎉 Todos os testes passaram!
```

---

## 📊 Passo 9: Verificar Recursos

```bash
# Uso de memória e CPU
docker stats ssml-service --no-stream

# Logs de erro
docker-compose logs ssml | grep ERROR

# Verificar volumes
docker volume ls | grep ssml
```

---

## 🔄 Passo 10: Restart e Cleanup

```bash
# Restart do serviço
docker-compose restart ssml

# Parar serviço
docker-compose stop ssml

# Remover e recriar
docker-compose down
docker-compose up -d

# Limpar tudo (CUIDADO!)
docker-compose down -v
docker system prune -a
```

---

## ✅ Checklist de Validação

### Build
- [ ] Build completo sem erros
- [ ] Imagem criada com sucesso
- [ ] Tamanho da imagem razoável (< 500MB)

### Startup
- [ ] Container inicia sem erros
- [ ] Health check passa
- [ ] Logs mostram "Application startup complete"
- [ ] Porta 8888 acessível

### Funcionalidade
- [ ] `/health` retorna 200
- [ ] `/api/v1/info` retorna dados corretos
- [ ] Parse de texto simples funciona
- [ ] Parse com `<break>` funciona
- [ ] Parse com `<prosody>` funciona
- [ ] Parse com `<phoneme>` funciona
- [ ] Validação detecta erros

### Performance
- [ ] Resposta < 500ms
- [ ] Uso de memória < 256MB
- [ ] CPU < 50% em idle

### Integração
- [ ] Acessível de outros containers
- [ ] Volumes criados corretamente
- [ ] Network configurada

---

## 🐛 Troubleshooting

### Erro: "Port 8888 already in use"

```bash
# Verificar o que está usando a porta
netstat -ano | findstr :8888

# Parar o processo ou mudar a porta no docker-compose.yml
```

### Erro: "Build failed"

```bash
# Limpar cache do Docker
docker builder prune -a

# Rebuild sem cache
docker-compose build --no-cache ssml
```

### Erro: "Module not found"

```bash
# Verificar se requirements foram instalados
docker exec -it ssml-service pip list

# Reinstalar
docker exec -it ssml-service pip install -r requirements-ssml.txt
```

### Container não inicia

```bash
# Ver logs detalhados
docker-compose logs ssml

# Entrar no container manualmente
docker run -it darkchannel-ssml:latest /bin/bash
```

---

## 📈 Métricas de Sucesso

### ✅ Tudo OK se:
- Build completa em < 5 minutos
- Container inicia em < 10 segundos
- Health check passa
- Todos os endpoints respondem
- Testes unitários passam
- Uso de recursos é razoável

### ⚠️ Atenção se:
- Build demora > 10 minutos
- Container reinicia constantemente
- Endpoints retornam 500
- Uso de memória > 512MB

### ❌ Problema se:
- Build falha
- Container não inicia
- Endpoints não respondem
- Testes falham

---

## 📝 Próximos Passos Após Testes

1. ✅ Se tudo passar → Commit e push
2. ⚠️ Se houver warnings → Documentar e planejar fix
3. ❌ Se houver erros → Debug e corrigir

---

**Boa sorte com os testes!** 🚀  
**Qualquer problema, consulte a documentação em `docs/`**

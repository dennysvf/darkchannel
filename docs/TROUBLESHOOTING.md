# 🔧 Troubleshooting - Resolução de Problemas

Guia completo para resolver problemas comuns.

---

## 🐳 Problemas com Docker

### Docker Desktop não inicia (Windows)

**Sintomas**: Erro ao abrir Docker Desktop

**Soluções**:
1. **Habilitar Virtualização na BIOS**
   - Reinicie o PC e entre na BIOS (geralmente F2, F10 ou Del)
   - Procure por "Virtualization Technology" ou "Intel VT-x"
   - Habilite e salve

2. **Habilitar WSL 2** (Windows)
   ```powershell
   wsl --install
   wsl --set-default-version 2
   ```

3. **Reinstalar Docker Desktop**
   - Desinstale completamente
   - Baixe a versão mais recente
   - Instale novamente

### "Cannot connect to Docker daemon"

**Causa**: Docker não está rodando

**Solução**:
```bash
# Windows/Mac: Abra o Docker Desktop

# Linux:
sudo systemctl start docker
sudo systemctl enable docker
```

---

## 🔌 Problemas de Porta

### "Port is already allocated"

**Causa**: Outra aplicação está usando a porta

**Soluções**:

#### Descobrir o que está usando a porta:

**Windows**:
```powershell
netstat -ano | findstr :5678
taskkill /PID [NUMERO_DO_PID] /F
```

**Linux/Mac**:
```bash
lsof -i :5678
kill -9 [PID]
```

#### Ou altere a porta no docker-compose:
```yaml
ports:
  - "5679:5678"  # Usa porta 5679 ao invés de 5678
```

---

## 🚫 Containers Não Iniciam

### Verificar status dos containers

```bash
docker-compose ps
```

### Ver logs de erro

```bash
# Todos os containers
docker-compose logs

# Container específico
docker-compose logs n8n
docker-compose logs postgres
docker-compose logs kokoro-tts
```

### Container reiniciando constantemente

**Causa**: Erro na inicialização

**Solução**:
```bash
# Ver últimas 50 linhas do log
docker-compose logs --tail=50 n8n

# Recriar o container
docker-compose up -d --force-recreate n8n
```

---

## 🌐 Problemas de Acesso

### N8N não abre no navegador

**Verificações**:

1. **Container está rodando?**
   ```bash
   docker-compose ps
   ```

2. **Aguarde a inicialização completa**
   ```bash
   docker-compose logs -f n8n
   # Aguarde ver: "Editor is now accessible via"
   ```

3. **Teste a porta**
   ```bash
   # Windows
   Test-NetConnection localhost -Port 5678
   
   # Linux/Mac
   nc -zv localhost 5678
   ```

4. **Limpe o cache do navegador**
   - Pressione Ctrl+Shift+Delete
   - Limpe cache e cookies
   - Tente novamente

### "502 Bad Gateway" ou "Connection refused"

**Causa**: N8N ainda está inicializando

**Solução**: Aguarde 30-60 segundos e recarregue a página

---

## 💾 Problemas com Banco de Dados

### PostgreSQL não inicia

**Verificar logs**:
```bash
docker-compose logs postgres
```

**Problemas comuns**:

1. **Permissões de volume**
   ```bash
   docker-compose down -v
   docker-compose up -d
   ```

2. **Porta já em uso**
   - Altere a porta no docker-compose.yml
   - Ou pare o PostgreSQL local

### N8N não conecta ao banco

**Verificar**:
```bash
# Entrar no container do N8N
docker exec -it n8n sh

# Testar conexão
ping postgres
```

**Solução**: Reinicie os containers
```bash
docker-compose restart
```

---

## 🎤 Problemas com Kokoro TTS

### Download muito lento

**Causa**: Imagem grande (~1.4GB)

**Solução**: 
- Aguarde pacientemente
- Use conexão estável
- Pode demorar 10-30 minutos dependendo da internet

### Kokoro não responde

**Verificar**:
```bash
docker-compose logs kokoro-tts
```

**Testar API**:
```bash
curl http://localhost:8880
```

---

## 🔨 Problemas de Build

### "failed to solve with frontend dockerfile.v0"

**Causa**: Erro no Dockerfile

**Solução**:
```bash
# Limpar cache do Docker
docker builder prune -a

# Rebuild
docker-compose build --no-cache n8n
docker-compose up -d
```

### "Error response from daemon: pull access denied"

**Causa**: Tentando fazer pull de imagem que não existe

**Solução**:
```bash
# Forçar build local
docker-compose build n8n
docker-compose up -d
```

---

## 💥 Resetar Tudo

### Limpar completamente e recomeçar

⚠️ **ATENÇÃO**: Isso apagará TODOS os dados!

```bash
# Parar e remover containers, volumes e redes
docker-compose down -v

# Limpar imagens não utilizadas
docker image prune -a

# Iniciar do zero
docker-compose up -d --build
```

---

## 🐧 Problemas Específicos do Linux

### Permissão negada

**Causa**: Usuário não está no grupo docker

**Solução**:
```bash
sudo usermod -aG docker $USER
newgrp docker

# Ou faça logout e login novamente
```

### Volumes com permissões erradas

**Solução**:
```bash
sudo chown -R $USER:$USER .
```

---

## 🪟 Problemas Específicos do Windows

### WSL 2 não instalado

**Solução**:
```powershell
# PowerShell como Administrador
wsl --install
wsl --set-default-version 2
```

### Hyper-V desabilitado

**Solução**:
```powershell
# PowerShell como Administrador
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```

---

## 🍎 Problemas Específicos do Mac

### "Docker.sock permission denied"

**Solução**:
```bash
sudo chmod 666 /var/run/docker.sock
```

### Rosetta 2 (Mac M1/M2)

**Solução**:
```bash
softwareupdate --install-rosetta
```

---

## 📊 Monitoramento

### Ver uso de recursos

```bash
docker stats
```

### Ver espaço em disco usado

```bash
docker system df
```

### Limpar espaço

```bash
# Limpar containers parados
docker container prune

# Limpar imagens não usadas
docker image prune -a

# Limpar volumes não usados
docker volume prune

# Limpar tudo (cuidado!)
docker system prune -a --volumes
```

---

## 🆘 Ainda com Problemas?

1. **Verifique os logs completos**:
   ```bash
   docker-compose logs > logs.txt
   ```

2. **Informações do sistema**:
   ```bash
   docker version
   docker-compose version
   docker info
   ```

3. **Abra uma issue** no repositório com:
   - Sistema operacional e versão
   - Versão do Docker
   - Logs completos
   - Passos para reproduzir o problema

---

## 📚 Recursos Úteis

- **Docker Docs**: https://docs.docker.com/
- **N8N Community**: https://community.n8n.io/
- **Stack Overflow**: https://stackoverflow.com/questions/tagged/docker

---

**Lembre-se**: A maioria dos problemas é resolvida com um simples restart! 🔄

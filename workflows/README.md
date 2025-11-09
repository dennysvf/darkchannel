# 🔄 Workflows N8N - DarkChannel Stack

Workflows prontos para testar Kokoro TTS e OpenVoice.

---

## 📦 Workflows Disponíveis

### 1. 🎤 Teste Kokoro TTS
**Arquivo**: `workflow-kokoro-tts.json`

**Descrição**: Workflow simples para testar a síntese de voz com Kokoro TTS.

**O que faz**:
- Configura texto, voz e velocidade
- Envia para Kokoro TTS
- Salva arquivo de áudio gerado
- Retorna resultado com informações

**Parâmetros**:
- `text`: Texto para sintetizar
- `voice`: Voz a usar (af_sarah, am_adam, etc)
- `speed`: Velocidade da fala (0.5 - 2.0)

---

### 2. 🎙️ Teste OpenVoice - Clone de Voz
**Arquivo**: `workflow-openvoice-clone.json`

**Descrição**: Workflow para testar clonagem de voz com OpenVoice.

**O que faz**:
1. Verifica status do OpenVoice
2. Lista idiomas suportados
3. Gera áudio base com Kokoro TTS
4. **Usa o áudio do Kokoro como referência** para OpenVoice
5. Clona voz usando OpenVoice
6. Retorna resultado

**Parâmetros**:
- `text`: Texto para clonar
- `language`: Idioma (pt-br, en, es, fr, zh, ja, ko)
- `speed`: Velocidade da fala

**Como funciona**:
- O workflow gera um áudio com Kokoro TTS
- Esse áudio é automaticamente enviado como referência para o OpenVoice
- O OpenVoice clona as características da voz do Kokoro
- Resultado: áudio com características modificadas

**Nota**: Este é um teste do pipeline. Para clonar uma voz real, você precisaria fornecer um áudio de referência personalizado.

---

### 3. 📚 Gerador de Audiolivro Completo
**Arquivo**: `workflow-audiobook-complete.json`

**Descrição**: Pipeline completo para gerar audiolivro com múltiplos capítulos.

**O que faz**:
1. Configura informações do livro
2. Divide texto em capítulos
3. Para cada capítulo:
   - Gera áudio base (Kokoro TTS)
   - Clona voz do autor (OpenVoice)
   - Salva arquivo de áudio
4. Agrega resultados de todos os capítulos

**Parâmetros**:
- `book_title`: Título do livro
- `author`: Nome do autor
- `language`: Idioma
- `chapters`: Array com texto de cada capítulo

**Saída**: Arquivos WAV para cada capítulo (ex: `Meu_Audiolivro_capitulo_1.wav`)

---

## 📥 Como Importar no N8N

### Passo 1: Acessar N8N
```
http://localhost:5678
```

### Passo 2: Importar Workflow

1. Clique no menu **☰** (canto superior esquerdo)
2. Selecione **"Import from File"** ou **"Importar do arquivo"**
3. Escolha um dos arquivos JSON:
   - `workflow-kokoro-tts.json`
   - `workflow-openvoice-clone.json`
   - `workflow-audiobook-complete.json`
4. Clique em **"Import"**

### Passo 3: Executar Workflow

1. Abra o workflow importado
2. Clique no botão **"Execute Workflow"** ou **"Executar Workflow"**
3. Aguarde o processamento
4. Veja os resultados em cada node

---

## 🎯 Exemplos de Uso

### Teste Rápido do Kokoro TTS

```json
{
  "text": "Olá! Bem-vindo ao DarkChannel Stack.",
  "voice": "af_sarah",
  "speed": "1.0"
}
```

### Teste de Clonagem de Voz

```json
{
  "text": "Este é um teste de clonagem de voz em português.",
  "language": "pt-br",
  "speed": "1.0"
}
```

### Gerar Audiolivro

```json
{
  "book_title": "Aventuras Fantásticas",
  "author": "João Silva",
  "language": "pt-br",
  "chapters": [
    "Capítulo 1: O início da jornada...",
    "Capítulo 2: O encontro inesperado...",
    "Capítulo 3: A grande revelação..."
  ]
}
```

---

## 🔧 Personalização

### Alterar Voz do Kokoro TTS

Vozes disponíveis:
- `af_sarah` - Feminina, clara
- `am_adam` - Masculina, profunda
- `af_nicole` - Feminina, suave
- `am_michael` - Masculina, enérgica

### Ajustar Velocidade

- `0.5` - Muito lento (didático)
- `0.8` - Lento
- `1.0` - Normal (padrão)
- `1.2` - Rápido
- `1.5` - Muito rápido
- `2.0` - Máximo

### Idiomas Suportados (OpenVoice)

- 🇧🇷 `pt-br` - Português (Brasil)
- 🇺🇸 `en` - English
- 🇪🇸 `es` - Español
- 🇫🇷 `fr` - Français
- 🇨🇳 `zh` - 中文
- 🇯🇵 `ja` - 日本語
- 🇰🇷 `ko` - 한국어

---

## 🐛 Troubleshooting

### Erro: "No reference audio provided"

**Causa**: O áudio binário não está sendo enviado corretamente para o OpenVoice

**Solução**:
1. Verifique se o node do Kokoro TTS está configurado com `responseFormat: "file"`
2. Certifique-se que o node do OpenVoice tem:
   - `sendBinaryData: true`
   - `binaryPropertyName: "data"`
3. Re-importe o workflow atualizado

**Configuração correta no N8N**:
```json
{
  "sendBody": true,
  "contentType": "multipart-form-data",
  "sendBinaryData": true,
  "binaryPropertyName": "data",
  "options": {
    "bodyParameter": {
      "sendBinaryData": true,
      "binaryPropertyName": "data",
      "binaryPropertyOutput": "reference_audio"
    }
  }
}
```

### Erro: "Could not connect to service"

**Causa**: Serviço não está rodando

**Solução**:
```bash
docker-compose ps
docker-compose up -d
```

### Erro: "JSON parameter needs to be valid JSON"

**Causa**: Formato incorreto do body JSON

**Solução**: Use `bodyParameters` ao invés de `jsonBody` no N8N

### Erro: "File not found"

**Causa**: Caminho de salvamento inválido

**Solução**: Verifique permissões de escrita ou altere o caminho no node "Salvar Áudio"

### Áudio sem qualidade

**Causa**: Parâmetros inadequados

**Solução**:
- Ajuste `speed` para 1.0
- Use voz adequada ao idioma
- Verifique texto de entrada

---

## 📊 Monitoramento

### Ver Logs dos Serviços

```bash
# Kokoro TTS
docker-compose logs -f kokoro-tts

# OpenVoice
docker-compose logs -f openvoice

# N8N
docker-compose logs -f n8n
```

### Verificar Status

```bash
# Status geral
docker-compose ps

# Health check OpenVoice
curl http://localhost:8000/health

# Health check Kokoro
curl http://localhost:8880/health
```

---

## 💡 Dicas

1. **Teste Incremental**: Comece com o workflow simples do Kokoro antes de testar o pipeline completo

2. **Áudio de Referência**: Para melhor clonagem, use áudio de referência de 15-30 segundos, limpo e claro

3. **Processamento em Lote**: Use o workflow de audiolivro para processar múltiplos capítulos automaticamente

4. **Salvar Resultados**: Configure o node "Salvar Áudio" com o caminho desejado

5. **Reutilizar Workflows**: Duplique e customize os workflows para seus casos de uso específicos

---

## 🔗 Recursos Adicionais

- [Documentação N8N](https://docs.n8n.io/)
- [Kokoro TTS API](../docs/KOKORO_API.md)
- [OpenVoice API](../docs/OPENVOICE_API.md)
- [Workflow Audiobook](../docs/WORKFLOW_AUDIOBOOK.md)

---

**Criado para DarkChannel Stack** 🎯

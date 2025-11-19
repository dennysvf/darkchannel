# 🎙️ Workflow: SSML + OpenVoice - Gerador de Audiolivro

**Versão**: 1.0.0  
**Autor**: DarkChannel Stack  
**Data**: 2025-11-09

---

## 📋 Descrição

Workflow N8N completo que integra o serviço SSML com OpenVoice V2 para gerar audiolivros com controle avançado de prosódia, pausas e pronúncia.

### Fluxo de Trabalho

```
Webhook (POST)
    ↓
Preparar SSML
    ↓
Parse SSML (Service)
    ↓
Processar Chunks
    ↓
Filtrar por Tipo
    ├─→ Texto → OpenVoice TTS
    └─→ Pausa → Gerar Silêncio
         ↓
    Juntar Chunks
         ↓
    Preparar Merge
         ↓
    Resposta (JSON)
```

---

## 🚀 Como Usar

### 1. Importar Workflow

1. Acesse N8N: `http://localhost:5678`
2. Clique em **"Import from File"**
3. Selecione: `workflows/ssml-openvoice-audiobook.json`
4. Ative o workflow

### 2. Endpoint do Webhook

```
POST http://localhost:5678/webhook/audiobook
```

### 3. Payload de Exemplo

#### Exemplo 1: Audiolivro Simples

```json
{
  "text": "Era uma vez, em um reino distante, um jovem príncipe chamado Pedro. Ele era muito corajoso e destemido.",
  "chapter_title": "Capítulo 1: O Príncipe Corajoso",
  "voice_reference": null
}
```

#### Exemplo 2: Com SSML Avançado

```json
{
  "text": "<prosody rate=\"slow\" pitch=\"-2\">Era uma vez, em um reino distante,</prosody><break time=\"1s\"/>um jovem príncipe chamado <phoneme alphabet=\"ipa\" ph=\"ˈpedɾu\">Pedro</phoneme>.<break time=\"1.5s\"/><prosody rate=\"fast\" pitch=\"+1\">Ele era muito corajoso!</prosody>",
  "chapter_title": "Capítulo 1: O Início",
  "voice_reference": "/path/to/reference_voice.wav"
}
```

#### Exemplo 3: Diálogo com Emoções

```json
{
  "text": "<prosody rate=\"0.9\">João olhou para Maria e disse:</prosody><break time=\"0.5s\"/><prosody rate=\"slow\" pitch=\"-2\">\"Precisamos conversar sobre o que aconteceu.\"</prosody><break time=\"1s\"/><prosody rate=\"1.1\" pitch=\"+1\">\"Eu sei\", Maria respondeu nervosamente.</prosody>",
  "chapter_title": "Capítulo 5: A Conversa",
  "voice_reference": null
}
```

---

## 📊 Estrutura do Workflow

### Node 1: Webhook - Receber Texto
**Tipo**: `n8n-nodes-base.webhook`  
**Função**: Recebe requisições POST com texto e configurações

**Parâmetros Aceitos**:
- `text` (string, obrigatório): Texto ou SSML
- `chapter_title` (string, opcional): Título do capítulo
- `voice_reference` (string, opcional): Caminho para áudio de referência

---

### Node 2: Preparar SSML
**Tipo**: `n8n-nodes-base.code`  
**Função**: Envolve texto em tags SSML e adiciona estrutura

**Processamento**:
```javascript
const ssml = `<speak>
  <prosody rate="0.9">${chapterTitle}</prosody>
  <break time="2s"/>
  ${inputText}
</speak>`;
```

---

### Node 3: Parse SSML
**Tipo**: `n8n-nodes-base.httpRequest`  
**Endpoint**: `http://ssml-service:8888/api/v1/ssml/parse`

**Request**:
```json
{
  "text": "<speak>...</speak>"
}
```

**Response**:
```json
{
  "success": true,
  "chunks": [
    {
      "type": "text",
      "content": "Era uma vez",
      "metadata": {
        "rate": "slow",
        "speed": 0.8,
        "pitch": -2
      }
    },
    {
      "type": "break",
      "duration": 1.5
    }
  ]
}
```

---

### Node 4: Processar Chunks
**Tipo**: `n8n-nodes-base.code`  
**Função**: Otimiza chunks agrupando textos consecutivos

**Lógica**:
1. Agrupa chunks de texto com mesmos metadados
2. Preserva pausas entre grupos
3. Adiciona referência de voz a cada chunk

---

### Node 5: Filtrar Chunks de Texto
**Tipo**: `n8n-nodes-base.if`  
**Função**: Separa chunks de texto de pausas

**Condição**: `chunk.type === "text"`
- ✅ True → Sintetizar Áudio
- ❌ False → Gerar Silêncio

---

### Node 6: Sintetizar Áudio (OpenVoice)
**Tipo**: `n8n-nodes-base.httpRequest`  
**Endpoint**: `http://openvoice:8000/synthesize`

**Request**:
```json
{
  "text": "Era uma vez",
  "language": "pt-BR",
  "speed": 0.8,
  "pitch": -2,
  "reference_audio": "/path/to/voice.wav"
}
```

**Response**: Arquivo de áudio (WAV/MP3)

---

### Node 7: Gerar Silêncio
**Tipo**: `n8n-nodes-base.code`  
**Função**: Cria metadados para pausas

**Output**:
```json
{
  "type": "silence",
  "duration": 1.5,
  "samples": 33075
}
```

---

### Node 8: Juntar Chunks de Áudio
**Tipo**: `n8n-nodes-base.merge`  
**Função**: Combina áudios e pausas na ordem correta

---

### Node 9: Preparar para Merge
**Tipo**: `n8n-nodes-base.code`  
**Função**: Organiza arquivos de áudio para concatenação

---

### Node 10: Resposta - Sucesso
**Tipo**: `n8n-nodes-base.respondToWebhook`  
**Função**: Retorna resultado ao cliente

**Response**:
```json
{
  "success": true,
  "chapter_title": "Capítulo 1",
  "total_chunks": 15,
  "audio_chunks": 8,
  "message": "Audiolivro gerado com sucesso!",
  "download_url": "/download/audiobook_final.mp3"
}
```

---

## 🎯 Casos de Uso

### 1. Audiolivro Profissional
```bash
curl -X POST http://localhost:5678/webhook/audiobook \
  -H "Content-Type: application/json" \
  -d '{
    "text": "<prosody rate=\"0.9\">Capítulo 1: A Jornada Começa</prosody><break time=\"2s\"/><prosody rate=\"slow\">Era uma manhã de domingo quando tudo mudou.</prosody>",
    "chapter_title": "Capítulo 1",
    "voice_reference": "/references/narrator_voice.wav"
  }'
```

### 2. Narração de Notícias
```bash
curl -X POST http://localhost:5678/webhook/audiobook \
  -H "Content-Type: application/json" \
  -d '{
    "text": "<prosody rate=\"1.1\">Bom dia! Estas são as principais notícias de hoje.</prosody><break time=\"1s\"/>Primeira notícia...",
    "chapter_title": "Notícias - 09/11/2025"
  }'
```

### 3. Diálogos Dramatizados
```bash
curl -X POST http://localhost:5678/webhook/audiobook \
  -H "Content-Type: application/json" \
  -d '{
    "text": "<prosody rate=\"slow\" pitch=\"-3\">\"Quem está aí?\", perguntou João.</prosody><break time=\"1s\"/><prosody rate=\"fast\" pitch=\"+2\">\"Sou eu, Maria!\"</prosody>",
    "chapter_title": "Cena 3: O Encontro"
  }'
```

---

## ⚙️ Configuração

### Variáveis de Ambiente (N8N)

```env
# URLs dos serviços
SSML_SERVICE_URL=http://ssml-service:8888
OPENVOICE_SERVICE_URL=http://openvoice:8000

# Configurações de áudio
DEFAULT_SAMPLE_RATE=22050
DEFAULT_AUDIO_FORMAT=wav

# Limites
MAX_TEXT_LENGTH=10000
MAX_CHUNKS_PER_REQUEST=100
```

### Requisitos

- ✅ N8N rodando
- ✅ SSML Service ativo (porta 8888)
- ✅ OpenVoice ativo (porta 8000)
- ⚠️ FFmpeg (opcional, para merge final)

---

## 🔧 Customização

### Adicionar Mais Vozes

Modifique o node "Preparar SSML":

```javascript
const voiceMap = {
  "narrator": "/references/narrator.wav",
  "character1": "/references/char1.wav",
  "character2": "/references/char2.wav"
};

const voiceReference = voiceMap[$input.item.json.body.voice_name] || null;
```

### Ajustar Qualidade de Áudio

Modifique o node "Sintetizar Áudio":

```json
{
  "sample_rate": 44100,
  "bit_depth": 24,
  "format": "flac"
}
```

### Adicionar Efeitos

Adicione node após "Sintetizar Áudio":

```javascript
// Aplicar reverb, equalização, etc.
const processedAudio = applyEffects($json.binary, {
  reverb: 0.2,
  eq: {
    low: 1.1,
    mid: 1.0,
    high: 0.9
  }
});
```

---

## 📈 Performance

### Métricas Esperadas

| Métrica | Valor |
|---------|-------|
| **Tempo por chunk** | 2-5s |
| **Chunks simultâneos** | 5-10 |
| **Tempo total (10 chunks)** | 20-30s |
| **Uso de memória** | ~200MB |

### Otimizações

1. **Paralelização**: Processar múltiplos chunks simultaneamente
2. **Cache**: Reutilizar áudios de frases repetidas
3. **Batch**: Agrupar chunks pequenos
4. **Streaming**: Retornar chunks conforme são gerados

---

## 🐛 Troubleshooting

### Erro: "SSML Service não responde"

```bash
# Verificar serviço
docker-compose ps ssml
docker-compose logs ssml

# Reiniciar
docker-compose restart ssml
```

### Erro: "OpenVoice falhou"

```bash
# Verificar logs
docker-compose logs openvoice

# Testar manualmente
curl http://localhost:8000/health
```

### Erro: "Chunks não processados"

- Verificar formato do SSML
- Validar com: `POST http://localhost:8888/api/v1/ssml/validate`

---

## 📚 Exemplos Avançados

### Exemplo 1: Audiolivro Multi-Capítulo

```javascript
// Loop por capítulos
const chapters = [
  { title: "Cap 1", text: "..." },
  { title: "Cap 2", text: "..." }
];

for (const chapter of chapters) {
  // Processar cada capítulo
  await processChapter(chapter);
}
```

### Exemplo 2: Narração com Múltiplas Vozes

```json
{
  "text": "<voice name=\"narrator\">Era uma vez</voice><break time=\"1s\"/><voice name=\"character1\">Olá!</voice>",
  "voices": {
    "narrator": "/ref/narrator.wav",
    "character1": "/ref/char1.wav"
  }
}
```

---

## ✅ Checklist de Deploy

- [ ] N8N configurado e rodando
- [ ] SSML Service ativo
- [ ] OpenVoice ativo
- [ ] Workflow importado
- [ ] Webhook testado
- [ ] Áudios de referência carregados
- [ ] Limites de rate configurados
- [ ] Logs habilitados
- [ ] Backup configurado

---

## 🎉 Conclusão

Este workflow demonstra a integração completa entre:
- ✅ Parser SSML (controle de prosódia)
- ✅ OpenVoice V2 (síntese de voz)
- ✅ N8N (orquestração)

**Resultado**: Geração automatizada de audiolivros profissionais com controle total sobre velocidade, tom, pausas e pronúncia!

---

**Desenvolvido para DarkChannel Stack** 🎯  
**Integração SSML + OpenVoice** 🎙️  
**Pronto para Produção** ✅

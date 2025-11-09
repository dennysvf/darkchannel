# 📚 Workflow: Geração de Audiolivro com Voz Clonada

Exemplo de workflow no N8N para gerar audiolivro com a voz do autor.

---

## 🎯 Objetivo

Automatizar a geração de audiolivro:
1. Ler capítulos de um livro (texto)
2. Gerar áudio sintético com Kokoro TTS
3. Clonar voz do autor com OpenVoice
4. Salvar arquivos de áudio finais

---

## 📋 Pré-requisitos

1. Stack DarkChannel rodando
2. Voz de referência do autor carregada no OpenVoice
3. Capítulos do livro em formato texto

---

## 🔄 Fluxo do Workflow

```
┌──────────────────┐
│  1. Trigger      │ (Manual ou Schedule)
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  2. Read Files   │ (Ler capítulos .txt)
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  3. Split Text   │ (Dividir em parágrafos)
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  4. Kokoro TTS   │ (Gerar áudio base)
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  5. OpenVoice    │ (Clonar voz)
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  6. Save Audio   │ (Salvar MP3)
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  7. Notify       │ (Enviar notificação)
└──────────────────┘
```

---

## 🛠️ Configuração dos Nodes

### 1. Manual Trigger
**Node**: Manual Trigger  
**Configuração**: Padrão

---

### 2. Read Binary Files
**Node**: Read Binary Files  
**Configuração**:
```json
{
  "fileSelector": "/data/livro/*.txt",
  "options": {}
}
```

---

### 3. Split Text
**Node**: Code (JavaScript)  
**Código**:
```javascript
// Dividir texto em parágrafos
const text = $input.item.binary.data.toString();
const paragraphs = text.split('\n\n').filter(p => p.trim());

return paragraphs.map((paragraph, index) => ({
  json: {
    chapter: $input.item.json.fileName,
    paragraph_index: index,
    text: paragraph.trim()
  }
}));
```

---

### 4. Kokoro TTS - Gerar Áudio Base
**Node**: HTTP Request  
**Configuração**:
```json
{
  "method": "POST",
  "url": "http://kokoro-tts:8880/synthesize",
  "sendBody": true,
  "bodyParameters": {
    "text": "={{ $json.text }}",
    "voice": "af_sarah",
    "speed": 1.0
  },
  "options": {
    "response": {
      "response": {
        "responseFormat": "file"
      }
    }
  }
}
```

---

### 5. OpenVoice - Clonar Voz
**Node**: HTTP Request  
**Configuração**:
```json
{
  "method": "POST",
  "url": "http://openvoice:8000/synthesize",
  "sendBody": true,
  "contentType": "multipart-form-data",
  "bodyParameters": {
    "audio": "={{ $binary.data }}",
    "speaker_id": "autor_principal",
    "speed": 1.0
  },
  "options": {
    "response": {
      "response": {
        "responseFormat": "file"
      }
    }
  }
}
```

---

### 6. Write Binary File
**Node**: Write Binary File  
**Configuração**:
```json
{
  "fileName": "={{ $json.chapter }}_{{ $json.paragraph_index }}.wav",
  "dataPropertyName": "data",
  "options": {
    "append": false
  }
}
```

---

### 7. Send Email (Opcional)
**Node**: Send Email  
**Configuração**:
```json
{
  "fromEmail": "noreply@darkchannel.com",
  "toEmail": "autor@example.com",
  "subject": "Audiolivro Gerado",
  "text": "O capítulo {{ $json.chapter }} foi processado com sucesso!"
}
```

---

## 🎙️ Preparação da Voz de Referência

Antes de executar o workflow, carregue a voz do autor:

```bash
curl -X POST http://localhost:8000/upload_reference \
  -F "audio=@voz_autor.wav" \
  -F "speaker_id=autor_principal"
```

**Dicas para gravação**:
- Duração: 15-30 segundos
- Ambiente silencioso
- Falar naturalmente
- Ler um trecho do próprio livro

---

## 📊 Workflow Avançado: Batch Processing

Para processar múltiplos capítulos em paralelo:

```
┌──────────────────┐
│  1. Schedule     │ (Diário às 2AM)
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  2. List Files   │ (Listar capítulos pendentes)
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  3. Split Batch  │ (Dividir em lotes de 5)
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  4. Loop         │ (Para cada lote)
│  ├─ Kokoro TTS   │
│  ├─ OpenVoice    │
│  └─ Save         │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  5. Merge Audio  │ (Combinar capítulos)
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  6. Upload       │ (S3, Drive, etc)
└──────────────────┘
```

---

## ⚙️ Otimizações

### 1. Cache de TTS
Salve áudios intermediários para evitar reprocessamento:
```javascript
// Verificar se áudio já existe
const cacheKey = `${chapter}_${paragraph_index}`;
if (cache.has(cacheKey)) {
  return cache.get(cacheKey);
}
```

### 2. Processamento Paralelo
Use o node **Split in Batches** para processar múltiplos parágrafos simultaneamente.

### 3. Retry Logic
Adicione retry em caso de falha:
```json
{
  "retryOnFail": true,
  "maxTries": 3,
  "waitBetweenTries": 5000
}
```

---

## 📈 Monitoramento

### Logs
Ver logs do processamento:
```bash
docker-compose -f docker-compose.simple.yml logs -f openvoice
```

### Métricas
- Tempo médio por parágrafo: ~30-60s
- Capítulo de 3000 palavras: ~20-30 minutos
- Livro de 10 capítulos: ~4-6 horas

---

## 🎬 Pós-Processamento

### Normalizar Volume
```bash
ffmpeg -i input.wav -af "loudnorm=I=-16:TP=-1.5:LRA=11" output.wav
```

### Converter para MP3
```bash
ffmpeg -i input.wav -codec:a libmp3lame -b:a 128k output.mp3
```

### Adicionar Metadados
```bash
ffmpeg -i input.mp3 -metadata title="Capítulo 1" \
  -metadata artist="Nome do Autor" \
  -metadata album="Título do Livro" \
  output.mp3
```

---

## 🐛 Troubleshooting

### Áudio com qualidade ruim
- Verificar qualidade da voz de referência
- Ajustar parâmetros de speed no OpenVoice
- Usar áudio base de melhor qualidade do Kokoro

### Processamento lento
- Normal para CPU
- Processar em lotes menores
- Executar durante a noite

### Erro de memória
- Dividir capítulos muito longos
- Reduzir batch size
- Aumentar memória do container

---

## 📚 Recursos Adicionais

- [OpenVoice API Docs](OPENVOICE_API.md)
- [N8N Documentation](https://docs.n8n.io/)
- [FFmpeg Guide](https://ffmpeg.org/documentation.html)

---

## 💡 Casos de Uso

1. **Audiolivros**: Narração completa de livros
2. **Podcasts**: Episódios narrados com voz personalizada
3. **Vídeos**: Narração para vídeos educacionais
4. **Acessibilidade**: Converter conteúdo escrito em áudio
5. **Marketing**: Criar conteúdo de áudio personalizado

---

**Workflow criado para DarkChannel Stack** 🎯

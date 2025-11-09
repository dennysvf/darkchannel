# 🎤 OpenVoice API Documentation

API REST para clonagem e síntese de voz usando OpenVoice.

---

## 🌐 Base URL

```
http://localhost:8000
```

Dentro da rede Docker:
```
http://openvoice:8000
```

---

## 📋 Endpoints

### 1. Health Check

Verificar status do serviço.

**Endpoint**: `GET /health`

**Resposta**:
```json
{
  "status": "healthy",
  "device": "cpu",
  "model_loaded": true
}
```

---

### 2. Upload de Voz de Referência

Fazer upload de um áudio de referência para clonar a voz.

**Endpoint**: `POST /upload_reference`

**Content-Type**: `multipart/form-data`

**Parâmetros**:
| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `audio` | file | Sim | Arquivo de áudio (WAV, MP3) |
| `speaker_id` | string | Não | ID único do falante (padrão: "default") |

**Exemplo (cURL)**:
```bash
curl -X POST http://localhost:8000/upload_reference \
  -F "audio=@minha_voz.wav" \
  -F "speaker_id=autor_joao"
```

**Resposta**:
```json
{
  "status": "success",
  "speaker_id": "autor_joao",
  "reference_path": "autor_joao_reference.wav",
  "message": "Voz de referência carregada com sucesso"
}
```

---

### 3. Sintetizar Áudio com Voz Clonada

Gerar áudio com a voz clonada.

**Endpoint**: `POST /synthesize`

**Content-Type**: `multipart/form-data`

**Parâmetros**:
| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `audio` | file | Sim | Áudio base (TTS ou gravação) |
| `speaker_id` | string | Sim | ID do falante de referência |
| `speed` | float | Não | Velocidade (padrão: 1.0) |
| `pitch` | int | Não | Tom (padrão: 0) |

**Exemplo (cURL)**:
```bash
curl -X POST http://localhost:8000/synthesize \
  -F "audio=@texto_narrado.wav" \
  -F "speaker_id=autor_joao" \
  -F "speed=1.1" \
  -o resultado.wav
```

**Resposta**:
```json
{
  "status": "success",
  "output_file": "autor_joao_a1b2c3d4.wav",
  "download_url": "/download/autor_joao_a1b2c3d4.wav"
}
```

---

### 4. Download de Áudio Gerado

Baixar arquivo de áudio processado.

**Endpoint**: `GET /download/<filename>`

**Exemplo**:
```bash
curl -O http://localhost:8000/download/autor_joao_a1b2c3d4.wav
```

---

### 5. Listar Speakers

Listar todos os speakers (vozes) cadastrados.

**Endpoint**: `GET /list_speakers`

**Resposta**:
```json
{
  "speakers": ["autor_joao", "narradora_maria", "default"],
  "count": 3
}
```

---

### 6. Deletar Speaker

Remover um speaker e sua referência.

**Endpoint**: `DELETE /delete_speaker/<speaker_id>`

**Exemplo**:
```bash
curl -X DELETE http://localhost:8000/delete_speaker/autor_joao
```

**Resposta**:
```json
{
  "status": "success",
  "message": "Speaker autor_joao deletado"
}
```

---

## 🔄 Workflow Típico

### 1. Preparar Voz de Referência

```bash
# Gravar ou selecionar um áudio de 10-30 segundos da voz original
# Formato: WAV, 16kHz ou 22kHz, mono

# Upload
curl -X POST http://localhost:8000/upload_reference \
  -F "audio=@voz_referencia.wav" \
  -F "speaker_id=meu_autor"
```

### 2. Gerar TTS Base (usando Kokoro)

```bash
# Gerar áudio sintético do texto
curl -X POST http://localhost:8880/synthesize \
  -H "Content-Type: application/json" \
  -d '{"text": "Este é o capítulo um do meu livro."}' \
  -o base_tts.wav
```

### 3. Clonar Voz

```bash
# Aplicar características da voz de referência
curl -X POST http://localhost:8000/synthesize \
  -F "audio=@base_tts.wav" \
  -F "speaker_id=meu_autor" \
  -F "speed=1.0" \
  -o capitulo_01_final.wav
```

---

## 🎯 Integração com N8N

### Exemplo de Workflow

```
┌─────────────┐
│   Trigger   │ (Webhook ou Schedule)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Read Text  │ (Ler capítulo do livro)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Kokoro TTS  │ (Gerar áudio base)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  OpenVoice  │ (Clonar voz do autor)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Save/Upload │ (Salvar ou enviar para storage)
└─────────────┘
```

### Node HTTP Request (N8N)

**Upload Reference**:
```json
{
  "method": "POST",
  "url": "http://openvoice:8000/upload_reference",
  "bodyParameters": {
    "audio": "{{ $binary.data }}",
    "speaker_id": "autor_principal"
  }
}
```

**Synthesize**:
```json
{
  "method": "POST",
  "url": "http://openvoice:8000/synthesize",
  "bodyParameters": {
    "audio": "{{ $binary.data }}",
    "speaker_id": "autor_principal",
    "speed": 1.0
  }
}
```

---

## ⚙️ Parâmetros de Ajuste

### Speed (Velocidade)
- **Padrão**: 1.0
- **Range**: 0.5 - 2.0
- **Uso**:
  - `0.8` - Mais lento, didático
  - `1.0` - Normal
  - `1.2` - Mais rápido, dinâmico

### Pitch (Tom)
- **Padrão**: 0
- **Range**: -12 a +12 (semitons)
- **Uso**:
  - `-3` - Tom mais grave
  - `0` - Tom original
  - `+3` - Tom mais agudo

---

## 📊 Requisitos de Áudio

### Áudio de Referência
- **Duração**: 10-30 segundos
- **Formato**: WAV, MP3
- **Sample Rate**: 16kHz ou 22kHz
- **Canais**: Mono (recomendado)
- **Qualidade**: Sem ruído de fundo

### Áudio Base (TTS)
- **Formato**: WAV
- **Sample Rate**: 22kHz
- **Canais**: Mono
- **Origem**: Kokoro TTS, gravação, ou outro TTS

---

## 🐛 Troubleshooting

### Erro: "Speaker ID não encontrado"
**Causa**: Referência não foi carregada  
**Solução**: Fazer upload da referência primeiro com `/upload_reference`

### Áudio com qualidade ruim
**Causa**: Áudio de referência com ruído  
**Solução**: Usar áudio limpo, sem ruído de fundo

### Processamento lento
**Causa**: Execução em CPU  
**Solução**: Normal para CPU. Aguarde ~10-30s por minuto de áudio

### Erro de memória
**Causa**: Áudio muito longo  
**Solução**: Processar em chunks menores (< 5 minutos)

---

## 💡 Dicas de Uso

1. **Qualidade da Referência**: Use áudio limpo e claro
2. **Duração Ideal**: 15-20 segundos de referência é suficiente
3. **Múltiplos Speakers**: Cadastre diferentes vozes para diferentes personagens
4. **Batch Processing**: Processe múltiplos capítulos em paralelo no N8N
5. **Cache**: Mantenha referências carregadas para reutilização

---

## 📚 Recursos Adicionais

- **OpenVoice GitHub**: https://github.com/myshell-ai/OpenVoice
- **Paper**: Instant Voice Cloning
- **Demo Online**: https://research.myshell.ai/open-voice

---

## 🔐 Segurança

⚠️ **Importante**:
- Não exponha a porta 8000 publicamente sem autenticação
- Use HTTPS em produção
- Implemente rate limiting se necessário
- Respeite direitos autorais e privacidade ao clonar vozes

---

**Desenvolvido para DarkChannel Stack** 🎯

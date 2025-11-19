# 🎙️ SSML com Clonagem de Voz - Guia Completo

## 📋 Visão Geral

Este guia mostra como usar **SSML** (Speech Synthesis Markup Language) com **clonagem de voz** do OpenVoice, usando as vozes geradas do Kokoro como referência.

---

## 🔄 Fluxo Completo

```
SSML Input → SSML Service → Kokoro TTS → OpenVoice Clone → MinIO Storage
```

1. **SSML Service** processa o markup e divide em chunks
2. **Kokoro TTS** gera áudio base com a voz selecionada
3. **OpenVoice** clona a voz usando sample de referência
4. **MinIO** armazena o resultado final

---

## 📝 Exemplo 1: Narração Simples com Voz Clonada

### Passo 1: Preparar Voz de Referência

```powershell
# Gerar biblioteca de vozes
.\generate-all-kokoro-voices.ps1

# Copiar para OpenVoice
docker cp references-kokoro/ openvoice:/app/references/
```

### Passo 2: Criar SSML com Voz Específica

```xml
<?xml version="1.0" encoding="UTF-8"?>
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="pt-BR">
  <voice name="adulto_af-sarah_Sarah">
    <prosody rate="medium" pitch="medium">
      Olá! Bem-vindo ao nosso sistema de narração com clonagem de voz.
      Esta é uma demonstração de como usar SSML com OpenVoice.
    </prosody>
  </voice>
</speak>
```

### Passo 3: Processar via API

```python
import requests

# Endpoint SSML
ssml_url = "http://localhost:8002/process-ssml"

# SSML com voz específica
ssml_content = """
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="pt-BR">
  <voice name="adulto_af-sarah_Sarah">
    <prosody rate="medium" pitch="medium">
      Olá! Esta é uma narração profissional em português do Brasil.
    </prosody>
  </voice>
</speak>
"""

# Processar SSML
response = requests.post(ssml_url, json={
    "ssml": ssml_content,
    "voice_reference": "references-kokoro/adulto/adulto_af-sarah_Sarah.wav",
    "use_voice_cloning": True
})

result = response.json()
print(f"✅ Áudio gerado: {result['output_file']}")
```

---

## 📝 Exemplo 2: Múltiplas Vozes (Diálogo)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="pt-BR">
  
  <!-- Narrador -->
  <voice name="adulto_am-adam_Adam">
    <prosody rate="0.9" pitch="low">
      Era uma vez, em um reino distante...
    </prosody>
  </voice>
  
  <break time="500ms"/>
  
  <!-- Princesa -->
  <voice name="jovem_af-sky_Sky">
    <prosody rate="1.1" pitch="high">
      Olá! Eu sou a princesa do reino!
    </prosody>
  </voice>
  
  <break time="500ms"/>
  
  <!-- Rei -->
  <voice name="idoso_am-adam_Adam">
    <prosody rate="0.8" pitch="low">
      Bem-vinda, minha filha. Tenho uma missão importante para você.
    </prosody>
  </voice>
  
</speak>
```

### Processar Diálogo

```python
import requests
import uuid

job_id = str(uuid.uuid4())

ssml_content = """
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="pt-BR">
  <voice name="adulto_am-adam_Adam">
    <prosody rate="0.9">Era uma vez, em um reino distante...</prosody>
  </voice>
  <break time="500ms"/>
  <voice name="jovem_af-sky_Sky">
    <prosody rate="1.1">Olá! Eu sou a princesa do reino!</prosody>
  </voice>
  <break time="500ms"/>
  <voice name="idoso_am-adam_Adam">
    <prosody rate="0.8">Bem-vinda, minha filha.</prosody>
  </voice>
</speak>
"""

# Processar com clonagem de voz
response = requests.post("http://localhost:8002/process-ssml", json={
    "ssml": ssml_content,
    "job_id": job_id,
    "voice_cloning_enabled": True,
    "voice_references": {
        "adulto_am-adam_Adam": "/app/references/adulto/adulto_am-adam_Adam.wav",
        "jovem_af-sky_Sky": "/app/references/jovem/jovem_af-sky_Sky.wav",
        "idoso_am-adam_Adam": "/app/references/idoso/idoso_am-adam_Adam.wav"
    }
})

result = response.json()
print(f"✅ Chunks gerados: {len(result['chunks'])}")
for chunk in result['chunks']:
    print(f"  - {chunk['s3_key']}")
```

---

## 📝 Exemplo 3: Audiobook com Emoções

```xml
<?xml version="1.0" encoding="UTF-8"?>
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="pt-BR">
  
  <!-- Capítulo 1 -->
  <voice name="adulto_af-nicole_Nicole">
    
    <!-- Introdução calma -->
    <prosody rate="0.95" pitch="medium">
      Capítulo Um: O Início da Jornada.
    </prosody>
    
    <break time="1s"/>
    
    <!-- Narração normal -->
    <prosody rate="1.0">
      Maria acordou cedo naquela manhã. O sol ainda não havia nascido,
      mas ela já sabia que aquele seria um dia especial.
    </prosody>
    
    <break time="500ms"/>
    
    <!-- Emoção - animação -->
    <prosody rate="1.15" pitch="high" volume="loud">
      "Hoje é o dia!" - ela exclamou com entusiasmo.
    </prosody>
    
    <break time="500ms"/>
    
    <!-- Volta ao normal -->
    <prosody rate="1.0">
      Ela se levantou rapidamente e começou a se preparar para a grande aventura.
    </prosody>
    
  </voice>
  
</speak>
```

---

## 📝 Exemplo 4: Podcast com Múltiplos Apresentadores

```xml
<?xml version="1.0" encoding="UTF-8"?>
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="pt-BR">
  
  <!-- Apresentador 1 -->
  <voice name="adulto_am-michael_Michael">
    <prosody rate="1.05" pitch="medium">
      Olá pessoal! Bem-vindos ao nosso podcast de tecnologia!
      Eu sou o Michael, e hoje vamos falar sobre inteligência artificial.
    </prosody>
  </voice>
  
  <break time="800ms"/>
  
  <!-- Apresentadora 2 -->
  <voice name="adulto_af-sarah_Sarah">
    <prosody rate="1.0" pitch="medium">
      E eu sou a Sarah! Hoje temos um episódio especial sobre
      síntese de voz e clonagem de áudio. Vai ser incrível!
    </prosody>
  </voice>
  
  <break time="800ms"/>
  
  <!-- Apresentador 1 -->
  <voice name="adulto_am-michael_Michael">
    <prosody rate="1.1" pitch="medium">
      Isso mesmo! Vamos começar falando sobre as últimas novidades
      em modelos de linguagem e geração de voz.
    </prosody>
  </voice>
  
</speak>
```

---

## 🔧 Workflow Completo com N8N

### Node 1: Preparar SSML

```json
{
  "ssml": "<speak>...</speak>",
  "job_id": "{{ $json.job_id }}",
  "voice_cloning": true
}
```

### Node 2: Processar SSML

```
POST http://ssml-service:8002/process-ssml
```

### Node 3: Para cada chunk, clonar voz

```javascript
// Para cada chunk do SSML
const chunks = $json.chunks;

for (const chunk of chunks) {
  // Buscar voz de referência baseada no nome da voz
  const voiceName = chunk.voice_name;
  const referenceAudio = `/app/references/${voiceName}.wav`;
  
  // Clonar voz com OpenVoice
  const clonedAudio = await cloneVoice({
    text: chunk.text,
    reference_audio: referenceAudio,
    language: 'pt-br'
  });
  
  // Upload para MinIO
  await uploadToMinio(clonedAudio, chunk.s3_key);
}
```

### Node 4: Combinar chunks

```
POST http://ssml-service:8002/combine-chunks
```

---

## 📊 Mapeamento de Vozes

### Vozes Recomendadas por Uso

| Uso | Voz | Idade | Arquivo |
|-----|-----|-------|---------|
| **Narração Profissional** | Sarah | Adulto | `adulto_af-sarah_Sarah.wav` |
| **Documentário** | Adam | Adulto | `adulto_am-adam_Adam.wav` |
| **Audiobook Feminino** | Nicole | Adulto | `adulto_af-nicole_Nicole.wav` |
| **Podcast Energético** | Michael | Jovem | `jovem_am-michael_Michael.wav` |
| **Conteúdo Infantil** | Sky | Criança | `crianca_af-sky_Sky.wav` |
| **Histórias de Vovô** | Adam | Idoso | `idoso_am-adam_Adam.wav` |
| **Meditação** | Eric | Adulto | `adulto_am-eric_Eric.wav` |
| **Literatura Clássica** | Emma UK | Adulto | `adulto_bf-emma_Emma-UK.wav` |

---

## 💡 Dicas Avançadas

### 1. Combinar Velocidade + Clonagem

```xml
<voice name="adulto_af-sarah_Sarah">
  <!-- Falar devagar para ênfase -->
  <prosody rate="0.8">
    Preste muita atenção nesta parte importante.
  </prosody>
  
  <!-- Voltar ao normal -->
  <prosody rate="1.0">
    Agora vamos continuar normalmente.
  </prosody>
</voice>
```

### 2. Usar Pausas Estratégicas

```xml
<voice name="adulto_am-adam_Adam">
  Primeiro ponto importante.
  <break time="1s"/>
  Segundo ponto importante.
  <break time="1s"/>
  E finalmente, o terceiro ponto.
</voice>
```

### 3. Ênfase em Palavras

```xml
<voice name="adulto_af-sarah_Sarah">
  Este é um conceito <emphasis level="strong">muito importante</emphasis>
  que você precisa entender.
</voice>
```

---

## 🚀 Script PowerShell Completo

```powershell
# test-ssml-voice-cloning.ps1

$jobId = [guid]::NewGuid().ToString()

$ssml = @"
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="pt-BR">
  <voice name="adulto_af-sarah_Sarah">
    <prosody rate="1.0">
      Olá! Esta é uma demonstração de SSML com clonagem de voz.
      O áudio está sendo gerado com a voz da Sarah, 
      e depois clonado usando OpenVoice para maior naturalidade.
    </prosody>
  </voice>
</speak>
"@

$body = @{
    ssml = $ssml
    job_id = $jobId
    voice_cloning_enabled = $true
    voice_reference_base = "/app/references-kokoro"
} | ConvertTo-Json

Write-Host "`n🎙️  Processando SSML com clonagem de voz...`n" -ForegroundColor Cyan

$response = Invoke-RestMethod `
    -Uri "http://localhost:8002/process-ssml" `
    -Method POST `
    -Body $body `
    -ContentType "application/json"

Write-Host "✅ Processamento concluído!`n" -ForegroundColor Green
Write-Host "📊 Chunks gerados: $($response.chunks.Count)`n" -ForegroundColor Cyan

foreach ($chunk in $response.chunks) {
    Write-Host "  🔗 $($chunk.s3_key)" -ForegroundColor Gray
    if ($chunk.download_url) {
        Write-Host "     Download: $($chunk.download_url)" -ForegroundColor DarkGray
    }
}

Write-Host ""
```

---

## 📋 Resumo

✅ **SSML** define o texto e marcações  
✅ **Kokoro** gera áudio base com vozes específicas  
✅ **OpenVoice** clona e melhora a naturalidade  
✅ **MinIO** armazena os resultados  
✅ **52 vozes** disponíveis (13 vozes x 4 idades)

---

**Criado para DarkChannel Stack** 🎯  
**Versão**: 1.0.0  
**Data**: 09/11/2025

# 📖 Guia de Uso SSML - DarkChannel

Guia completo para usar SSML (Speech Synthesis Markup Language) no DarkChannel Stack com foco em **Português do Brasil**.

---

## 🎯 O que é SSML?

SSML é uma linguagem de marcação XML que permite controlar aspectos detalhados da síntese de fala:
- ⏸️ Pausas controladas
- 🎵 Velocidade e tom
- 🗣️ Pronúncia específica
- 💪 Ênfase em palavras

---

## 🚀 Início Rápido

### Exemplo Básico

```xml
<speak>
  Olá! Bem-vindo ao audiolivro.
  <break time="1s"/>
  Vamos começar?
</speak>
```

### Testando via API

```bash
curl -X POST http://localhost:8888/api/v1/ssml/parse \
  -H "Content-Type: application/json" \
  -d '{
    "text": "<speak>Olá <break time=\"1s\"/> mundo!</speak>"
  }'
```

---

## 📚 Tags Suportadas

### 1. `<speak>` - Tag Raiz

**Obrigatória** - Envolve todo o conteúdo SSML.

```xml
<speak>
  Seu texto aqui
</speak>
```

---

### 2. `<break>` - Pausas

Insere pausas de duração específica.

**Atributos**:
- `time`: Duração da pausa (ex: "1s", "500ms", "2.5s")

**Exemplos**:

```xml
<!-- Pausa de 1 segundo -->
<speak>
  Primeira frase.
  <break time="1s"/>
  Segunda frase.
</speak>

<!-- Pausa de 500 milissegundos -->
<speak>
  Rápido.
  <break time="500ms"/>
  Muito rápido!
</speak>

<!-- Pausa dramática -->
<speak>
  E então...
  <break time="3s"/>
  ele apareceu!
</speak>
```

**Uso em Audiolivros**:
```xml
<speak>
  Capítulo 1: O Mistério.
  <break time="2s"/>
  
  Era uma noite escura e tempestuosa.
  <break time="1.5s"/>
  
  João olhou pela janela.
  <break time="1s"/>
</speak>
```

---

### 3. `<prosody>` - Controle de Prosódia

Controla velocidade, tom e volume da fala.

**Atributos**:
- `rate`: Velocidade ("slow", "medium", "fast", ou valor numérico)
- `pitch`: Tom em semitons (ex: "-2", "+3")
- `volume`: Volume (não implementado na Fase 1)

**Exemplos de Velocidade**:

```xml
<!-- Palavras-chave -->
<speak>
  <prosody rate="slow">
    Fala devagar e clara.
  </prosody>
  
  <prosody rate="fast">
    Fala rápida e animada!
  </prosody>
</speak>

<!-- Valores numéricos -->
<speak>
  <prosody rate="0.8">
    80% da velocidade normal.
  </prosody>
  
  <prosody rate="1.2">
    120% da velocidade normal.
  </prosody>
</speak>

<!-- Porcentagem -->
<speak>
  <prosody rate="90%">
    90% da velocidade.
  </prosody>
</speak>
```

**Mapeamento de Velocidades**:
| Palavra-chave | Valor Numérico |
|---------------|----------------|
| `x-slow` | 0.5 |
| `slow` | 0.8 |
| `medium` | 1.0 |
| `fast` | 1.2 |
| `x-fast` | 1.5 |

**Exemplos de Tom (Pitch)**:

```xml
<!-- Tom mais grave -->
<speak>
  <prosody pitch="-3">
    Voz grave e séria.
  </prosody>
</speak>

<!-- Tom mais agudo -->
<speak>
  <prosody pitch="+2">
    Voz aguda e animada!
  </prosody>
</speak>

<!-- Combinando velocidade e tom -->
<speak>
  <prosody rate="slow" pitch="-2">
    Devagar e grave.
  </prosody>
</speak>
```

**Uso em Diálogos**:
```xml
<speak>
  <prosody rate="0.9">
    "Onde você estava?", perguntou Maria calmamente.
  </prosody>
  <break time="0.5s"/>
  
  <prosody rate="1.3" pitch="+1">
    "Eu... eu estava no parque!", respondeu Pedro nervoso.
  </prosody>
</speak>
```

---

### 4. `<phoneme>` - Pronúncia Fonética

Especifica como pronunciar palavras usando alfabeto fonético.

**Atributos**:
- `alphabet`: "ipa" (International Phonetic Alphabet)
- `ph`: Pronúncia fonética

**Exemplos**:

```xml
<!-- Nomes próprios -->
<speak>
  <phoneme alphabet="ipa" ph="ʒoˈɐ̃w">João</phoneme> chegou.
</speak>

<speak>
  <phoneme alphabet="ipa" ph="ˈpedɾu">Pedro</phoneme> e
  <phoneme alphabet="ipa" ph="maˈɾi.ɐ">Maria</phoneme> saíram.
</speak>

<!-- Palavras estrangeiras -->
<speak>
  O restaurante <phoneme alphabet="ipa" ph="ʁɛstoˈɾɐ̃">restaurant</phoneme>
  fica na esquina.
</speak>

<!-- Termos técnicos -->
<speak>
  O <phoneme alphabet="ipa" ph="deˈzeˈɛni">DNA</phoneme>
  foi analisado.
</speak>
```

**IPA para Português Brasileiro**:
| Palavra | IPA | Uso |
|---------|-----|-----|
| João | ʒoˈɐ̃w | Nome próprio |
| Maria | maˈɾi.ɐ | Nome próprio |
| Pedro | ˈpedɾu | Nome próprio |
| São Paulo | sɐ̃w ˈpawlu | Cidade |
| Brasil | bɾaˈziw | País |

---

### 5. `<emphasis>` - Ênfase

Adiciona ênfase a palavras ou frases.

**Atributos**:
- `level`: "strong", "moderate", "reduced"

**Exemplos**:

```xml
<speak>
  Isso é <emphasis level="strong">muito</emphasis> importante!
</speak>

<speak>
  <emphasis>Nunca</emphasis> faça isso novamente.
</speak>
```

---

## 🎬 Exemplos Práticos

### Audiolivro - Capítulo Completo

```xml
<speak>
  <break time="1s"/>
  Capítulo Três: A Descoberta.
  <break time="2.5s"/>
  
  <prosody rate="0.9">
    Era uma manhã de domingo quando
    <phoneme alphabet="ipa" ph="ʒoˈɐ̃w">João</phoneme>
    encontrou o mapa antigo.
  </prosody>
  <break time="1.5s"/>
  
  <prosody rate="1.1" pitch="+1">
    "Não acredito!", ele exclamou.
  </prosody>
  <break time="1s"/>
  
  <prosody rate="0.85">
    O pergaminho estava amarelado pelo tempo,
    mas os símbolos ainda eram visíveis.
  </prosody>
  <break time="2s"/>
</speak>
```

### Narração com Diálogos

```xml
<speak>
  <prosody rate="0.9">
    Maria olhou para Pedro e disse:
  </prosody>
  <break time="0.5s"/>
  
  <prosody rate="slow" pitch="-1">
    "Precisamos conversar."
  </prosody>
  <break time="1s"/>
  
  <prosody rate="1.2">
    "Sobre o quê?", Pedro respondeu rapidamente.
  </prosody>
  <break time="0.8s"/>
  
  <prosody rate="0.8">
    Ela suspirou profundamente antes de continuar.
  </prosody>
</speak>
```

### Tutorial/Instrução

```xml
<speak>
  <break time="0.5s"/>
  Passo um:
  <break time="1s"/>
  
  <prosody rate="slow">
    Abra o aplicativo no seu celular.
  </prosody>
  <break time="1.5s"/>
  
  Passo dois:
  <break time="1s"/>
  
  <prosody rate="slow">
    Toque no botão <emphasis>Configurações</emphasis>.
  </prosody>
  <break time="2s"/>
</speak>
```

---

## 🔧 Integração com N8N

### Workflow Básico

```json
{
  "nodes": [
    {
      "name": "HTTP Request - SSML Parse",
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "method": "POST",
        "url": "http://ssml:8888/api/v1/ssml/parse",
        "jsonParameters": true,
        "options": {},
        "bodyParametersJson": "={{ JSON.stringify({text: $json.ssml_text}) }}"
      }
    }
  ]
}
```

---

## ⚠️ Limitações e Boas Práticas

### Limitações Atuais

❌ **Não Suportado na Fase 1**:
- Tags `<emotion>` (controle emocional)
- Tags `<voice>` (troca de voz)
- Tags `<audio>` (inserir áudio externo)
- Tags `<say-as>` (interpretação de números/datas)

### Boas Práticas

✅ **Faça**:
- Use pausas para dar ritmo à narração
- Combine `rate` e `pitch` para diálogos diferentes
- Use `<phoneme>` para nomes próprios complexos
- Teste com pequenos trechos primeiro

❌ **Evite**:
- Pausas muito longas (> 3s)
- Mudanças bruscas de velocidade
- Excesso de tags em uma única frase
- SSML mal-formado (sempre valide)

---

## 🧪 Testando SSML

### Validar SSML

```bash
curl -X POST http://localhost:8888/api/v1/ssml/validate \
  -H "Content-Type: application/json" \
  -d '{
    "text": "<speak>Seu SSML aqui</speak>"
  }'
```

### Parsear e Ver Chunks

```bash
curl -X POST http://localhost:8888/api/v1/ssml/parse \
  -H "Content-Type: application/json" \
  -d '{
    "text": "<speak>Olá <break time=\"1s\"/> mundo</speak>"
  }' | jq
```

---

## 📖 Recursos Adicionais

- **W3C SSML Spec**: https://www.w3.org/TR/speech-synthesis11/
- **IPA Chart**: https://www.ipachart.com/
- **Português IPA**: https://pt.wikipedia.org/wiki/Alfabeto_fonético_internacional_para_o_português

---

**Desenvolvido para DarkChannel Stack** 🎯  
**Foco em Português do Brasil** 🇧🇷

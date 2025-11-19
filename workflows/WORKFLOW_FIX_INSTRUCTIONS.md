# 🔧 Correção do Workflow - Erro no Node "Preparar SSML"

## ❌ Erro Identificado

```
Cannot read properties of undefined (reading 'text')
```

**Causa**: O código JavaScript está tentando acessar `$input.item.json.body.text` mas a estrutura de dados está incorreta.

## ✅ Correção

### Node: "Preparar SSML"

**CÓDIGO INCORRETO**:
```javascript
const inputText = $input.item.json.body.text || '';
const chapterTitle = $input.item.json.body.chapter_title || 'Capítulo';
```

**CÓDIGO CORRETO**:
```javascript
// Acessar dados do webhook corretamente
const body = $input.item.json.body || $input.item.json;
const inputText = body.text || '';
const chapterTitle = body.chapter_title || 'Capítulo';
const voice = body.voice || 'af_bella';

// Gerar SSML estruturado
const ssml = `<speak>
  <prosody rate="0.9">${chapterTitle}</prosody>
  <break time="2s"/>
  ${inputText}
</speak>`;

return {
  ssml: ssml,
  chapter_title: chapterTitle,
  original_text: inputText
};
```

## 📝 Como Corrigir no N8N

1. Abra o workflow no N8N
2. Clique no node **"Preparar SSML"**
3. Substitua o código JavaScript pelo código correto acima
4. Salve o workflow
5. Teste novamente

## 🧪 Teste Após Correção

```bash
curl -X POST http://localhost:5678/webhook/audiobook \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Era uma vez um príncipe corajoso.",
    "chapter_title": "Capítulo 1"
  }'
```

## 📋 Estrutura de Dados do Webhook

O webhook N8N recebe os dados assim:

```javascript
$input.item.json = {
  "body": {
    "text": "...",
    "chapter_title": "..."
  }
}
```

OU (dependendo da configuração):

```javascript
$input.item.json = {
  "text": "...",
  "chapter_title": "..."
}
```

Por isso o código correto verifica ambos:
```javascript
const body = $input.item.json.body || $input.item.json;
```

---

**Quer que eu crie um workflow corrigido completo?**

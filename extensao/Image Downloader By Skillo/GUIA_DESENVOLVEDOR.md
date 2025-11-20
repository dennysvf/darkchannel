# 🛠️ Guia do Desenvolvedor - Adicionar Novos Sites

Este guia ensina como adicionar suporte para novos sites de geração de imagens.

## 📋 Pré-requisitos

1. Conhecimento básico de JavaScript
2. Entender seletores CSS e DOM
3. Chrome DevTools (F12)
4. Acesso ao site que deseja adicionar

## 🚀 Passos para Adicionar um Novo Site

### 1️⃣ Analisar o Site

Antes de começar, você precisa identificar:

#### A. Caixa de Texto (Input)
Abra o DevTools e encontre:
- `<textarea>` ou `<input>` onde digita o prompt
- Atributos importantes: `placeholder`, `aria-label`, `class`, `id`

**Exemplo:**
```html
<textarea placeholder="Enter your prompt here" class="prompt-input"></textarea>
```

#### B. Botão de Gerar
Encontre o botão que inicia a geração:
- Tipo: `<button>` ou `<div>` clicável
- Atributos: `aria-label`, `class`, texto interno

**Exemplo:**
```html
<button aria-label="Generate image" class="generate-btn">Generate</button>
```

#### C. Container de Imagens
Identifique onde as imagens aparecem:
- Tags: `<img>`, `<canvas>`, ou containers
- Atributos do `src`: URL pattern, hospedagem

**Exemplo:**
```html
<img src="https://site.com/generated/abc123.jpg" alt="Generated image">
```

### 2️⃣ Criar Arquivo do Site

Crie `content_SEUSITE.js` na pasta `sites/`:

```javascript
// content_seusite.js - Seu Site
// Site: https://seusite.com

let processedImages = new Set();
let isInitialized = false;
let shouldStop = false;
const MAX_HISTORY = 10;
const SITE_NAME = "SeuSite";

console.log(`[${SITE_NAME}] Content script carregado!`);

// Funções auxiliares básicas
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

function scrollToTop() {
    window.scrollTo({ top: 0, behavior: 'smooth' });
}
```

### 3️⃣ Adaptar Seletores

#### Encontrar Caixa de Texto
```javascript
async function findTextBox() {
    const selectors = [
        // Adicione seus seletores aqui, do mais específico ao mais genérico
        'textarea[placeholder*="Enter"]',      // Específico
        'textarea[class*="prompt"]',           // Classe específica
        'textarea',                             // Genérico
        'input[type="text"]',                   // Alternativo
        '[contenteditable="true"]'              // Fallback
    ];
    
    for (const selector of selectors) {
        const element = document.querySelector(selector);
        if (element) {
            console.log(`[${SITE_NAME}] Caixa encontrada: ${selector}`);
            return element;
        }
    }
    
    console.error(`[${SITE_NAME}] Caixa de texto não encontrada`);
    return null;
}
```

#### Encontrar Botão de Gerar
```javascript
async function findGenerateButton() {
    const selectors = [
        'button[aria-label*="Generate"]',
        'button[class*="generate"]',
        'button[type="submit"]'
    ];
    
    for (const selector of selectors) {
        try {
            const element = document.querySelector(selector);
            if (element && !element.disabled) {
                return element;
            }
        } catch (e) {
            continue;
        }
    }
    
    // Busca por texto
    const buttons = Array.from(document.querySelectorAll('button'));
    for (const button of buttons) {
        const text = button.textContent.trim().toLowerCase();
        if (text.includes('generate') && !button.disabled) {
            return button;
        }
    }
    
    return null;
}
```

#### Detectar e Baixar Imagens
```javascript
async function waitAndDownloadImages(prompt) {
    const maxWaitTime = 45000;     // Ajuste conforme o site
    const checkInterval = 3000;     // Intervalo de verificação
    let elapsedTime = 0;
    let newImagesFound = [];

    while (elapsedTime < maxWaitTime) {
        if (shouldStop) return 0;
        
        await sleep(checkInterval);
        elapsedTime += checkInterval;
        scrollToTop();
        await sleep(1000);

        // IMPORTANTE: Adapte este seletor para seu site
        const allImages = document.querySelectorAll(
            'img[src*="seusite.com"]' +       // URL específica
            ', img[class*="generated"]' +      // Classe específica
            ', div[class*="result"] img'       // Container
        );
        
        console.log(`[${SITE_NAME}] Check ${elapsedTime/1000}s: ${allImages.length} imagens`);
        
        // Filtrar apenas imagens novas e válidas
        newImagesFound = Array.from(allImages).filter(img => 
            !processedImages.has(img.src) &&   // Não processada
            img.src &&                          // Tem src
            !img.src.includes('data:image') &&  // Não é data URL
            !img.src.includes('logo') &&        // Não é logo
            !img.src.includes('icon') &&        // Não é ícone
            img.complete &&                     // Carregada
            img.naturalWidth > 200              // Tamanho mínimo
        );
        
        console.log(`[${SITE_NAME}] ${newImagesFound.length} nova(s) imagem(ns)`);
        
        // Condições de parada
        if (newImagesFound.length >= 4) {
            await downloadImages(newImagesFound.slice(0, 4), prompt);
            return newImagesFound.length;
        }
        
        if (newImagesFound.length > 0 && elapsedTime >= maxWaitTime - checkInterval) {
            await downloadImages(newImagesFound, prompt);
            return newImagesFound.length;
        }
    }

    return 0;
}
```

### 4️⃣ Implementar Download

```javascript
async function downloadImages(imagesToProcess, prompt) {
    if (shouldStop) return;
    
    const timestamp = new Date().getTime();
    const cleanPrompt = prompt.substring(0, 30).replace(/[^a-z0-9]/gi, '_');

    for (let j = 0; j < imagesToProcess.length; j++) {
        if (shouldStop) break;
        
        const img = imagesToProcess[j];
        
        try {
            const response = await fetch(img.src);
            const blob = await response.blob();
            
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.style.display = 'none';
            a.href = url;
            a.download = `seusite_${cleanPrompt}_${timestamp}_${j + 1}.jpg`;
            
            document.body.appendChild(a);
            a.click();
            
            window.URL.revokeObjectURL(url);
            document.body.removeChild(a);
            
            processedImages.add(img.src);
            
            console.log(`[${SITE_NAME}] ✓ Download ${j + 1} concluído`);
            
            if (j < imagesToProcess.length - 1) {
                await sleep(2000);
            }
            
        } catch (error) {
            console.error(`[${SITE_NAME}] ✗ Erro:`, error);
        }
    }
}
```

### 5️⃣ Adicionar ao Manifest

Edite `manifest.json`:

```json
{
  "host_permissions": [
    "https://seusite.com/*"
  ],
  "content_scripts": [
    {
      "matches": ["https://seusite.com/*"],
      "js": ["sites/content_seusite.js"]
    }
  ]
}
```

### 6️⃣ Testar

1. **Carregar extensão** no Chrome
2. **Abrir o site** alvo
3. **Abrir DevTools** (F12) → Console
4. **Procurar logs** começando com `[SeuSite]`
5. **Testar automação** com prompts simples

## 🔍 Debugging

### Logs Importantes
```javascript
console.log(`[${SITE_NAME}] Caixa encontrada`);
console.log(`[${SITE_NAME}] Botão encontrado`);
console.log(`[${SITE_NAME}] ${newImagesFound.length} imagens`);
```

### Testar Seletores no Console
```javascript
// Testar no DevTools Console:
document.querySelector('textarea[placeholder*="prompt"]');
document.querySelectorAll('img[src*="generated"]');
```

### Verificar Eventos
```javascript
// Ver se eventos são disparados:
textBox.addEventListener('input', () => console.log('Input event!'));
button.addEventListener('click', () => console.log('Click event!'));
```

## 📊 Checklist de Qualidade

Antes de considerar pronto:

- [ ] ✅ Extensão carrega sem erros
- [ ] ✅ Detecta caixa de texto corretamente
- [ ] ✅ Detecta botão de gerar
- [ ] ✅ Insere prompt corretamente
- [ ] ✅ Botão é clicado com sucesso
- [ ] ✅ Aguarda tempo suficiente para geração
- [ ] ✅ Detecta imagens novas (não antigas)
- [ ] ✅ Baixa imagens corretamente
- [ ] ✅ Não baixa duplicatas
- [ ] ✅ Funciona com múltiplos prompts
- [ ] ✅ Botão de parar funciona
- [ ] ✅ Barra de progresso atualiza

## 🎯 Dicas Avançadas

### 1. Sites com Animações/Transições
```javascript
// Aguardar elemento aparecer
async function waitForElement(selector, timeout = 10000) {
    const start = Date.now();
    while (Date.now() - start < timeout) {
        const element = document.querySelector(selector);
        if (element) return element;
        await sleep(500);
    }
    return null;
}
```

### 2. Sites com Shadow DOM
```javascript
// Acessar elementos dentro de Shadow DOM
function querySelectorShadow(selector) {
    const shadowHosts = document.querySelectorAll('*');
    for (const host of shadowHosts) {
        if (host.shadowRoot) {
            const element = host.shadowRoot.querySelector(selector);
            if (element) return element;
        }
    }
    return null;
}
```

### 3. Sites com Carregamento Dinâmico
```javascript
// MutationObserver para detectar mudanças no DOM
function observeNewImages(callback) {
    const observer = new MutationObserver((mutations) => {
        for (const mutation of mutations) {
            if (mutation.addedNodes.length) {
                callback(mutation.addedNodes);
            }
        }
    });
    
    observer.observe(document.body, {
        childList: true,
        subtree: true
    });
    
    return observer;
}
```

### 4. Sites com API/WebSocket
```javascript
// Interceptar requisições fetch
const originalFetch = window.fetch;
window.fetch = async (...args) => {
    const response = await originalFetch(...args);
    
    // Se a requisição é para gerar imagem
    if (args[0].includes('/generate')) {
        console.log('Geração iniciada!');
    }
    
    return response;
};
```

## 📝 Exemplo Completo

Veja os arquivos existentes para exemplos completos:
- `content_metaai.js` - Site complexo com vídeos
- `content_imagefx.js` - Site Google com seletores específicos
- `content_whisk.js` - Site mais lento, tempos ajustados
- `content_piclumen.js` - Site com detecção avançada

## 🤝 Contribuindo

Ao adicionar um novo site:
1. Teste extensivamente (mínimo 20 prompts)
2. Documente peculiaridades no código
3. Adicione comentários explicativos
4. Atualize o README.md
5. Adicione o site em sites-config.json

## 📞 Suporte

**Dúvidas?** Entre em contato:
- Canal CLTube: [YouTube](https://www.youtube.com/@cltube-canaisdark)
- Grupo WhatsApp: [Entrar](https://chat.whatsapp.com/HHbb9e4QuKPGNdwKgOiz86)

---

**Boa sorte desenvolvendo! 🚀**

// content_whisk.js - Whisk do Google
// Site: https://labs.google/fx/tools/whisk

let processedImages = new Set();
let isInitialized = false;
let shouldStop = false;
const MAX_HISTORY = 10;
// ===== INÍCIO DO SCRIPT WHISK =====
// Verificar se já foi carregado para evitar duplicatas
if (window.__WHISK_SCRIPT_LOADED__) {
    console.log('[Whisk] Script já carregado, ignorando duplicata');
} else {
    window.__WHISK_SCRIPT_LOADED__ = true;
    console.log('[Whisk] Script carregado pela primeira vez');
}

const SITE_NAME = "Whisk";

console.log(`[${SITE_NAME}] Content script carregado!`);

// Funções auxiliares
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

function scrollToTop() {
    console.log(`[${SITE_NAME}] Rolando para o topo...`);
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

async function initializeImageHistory() {
    if (!isInitialized) {
        console.log(`[${SITE_NAME}] Inicializando histórico de imagens...`);
        await sleep(2000);
        
        scrollToTop();
        await sleep(2000);
        
        // Whisk: seletores específicos para imagens geradas
        const existingImages = document.querySelectorAll('img[src*="googleusercontent.com"], img[src*="labs.google"], div[class*="result"] img, div[class*="output"] img');
        console.log(`[${SITE_NAME}] Encontradas ${existingImages.length} imagens existentes`);
        
        const imagesToAdd = Math.min(existingImages.length, MAX_HISTORY);
        
        for (let i = 0; i < imagesToAdd; i++) {
            processedImages.add(existingImages[i].src);
        }
        
        console.log(`[${SITE_NAME}] Histórico inicializado com ${processedImages.size} imagens`);
        isInitialized = true;
        
        chrome.storage.local.set({ 
            whisk_processedImages: Array.from(processedImages),
            whisk_isInitialized: true
        });
    }
}

// Listener de mensagens
chrome.runtime.onMessage.addListener(async (request, sender, sendResponse) => {
    console.log(`[${SITE_NAME}] Mensagem recebida:`, request);
    
    if (request.action === "stopImageDownload") {
        console.log(`[${SITE_NAME}] Comando de parada recebido!`);
        shouldStop = true;
        sendResponse({ status: "stopping" });
        return true;
    }
    
    if (request.action === "startImageDownload") {
        shouldStop = false;
        console.log(`[${SITE_NAME}] Iniciando automação...`);
        console.log(`[${SITE_NAME}] Prompts recebidos:`, request.prompts.length);
        
        if (!isInitialized) {
            await initializeImageHistory();
        }
        
        sendResponse({ status: "started" });
        
        // Processar cada prompt
        for (let i = 0; i < request.prompts.length; i++) {
            if (shouldStop) {
                chrome.runtime.sendMessage({
                    action: "updateImageProgress",
                    data: {
                        current: i,
                        total: request.prompts.length,
                        status: 'stopped'
                    }
                });
                break;
            }
            
            const prompt = request.prompts[i];
            console.log(`[${SITE_NAME}] ========================================`);
            console.log(`[${SITE_NAME}] Processando prompt ${i + 1}/${request.prompts.length}`);
            console.log(`[${SITE_NAME}] Prompt: "${prompt}"`);
            
            chrome.runtime.sendMessage({
                action: "updateImageProgress",
                data: {
                    current: i + 1,
                    total: request.prompts.length,
                    status: 'processing',
                    details: `"${prompt.substring(0, 50)}${prompt.length > 50 ? '...' : ''}"`
                }
            });
            
            const imagesGenerated = await processSinglePrompt(prompt);
            
            if (shouldStop) {
                chrome.runtime.sendMessage({
                    action: "updateImageProgress",
                    data: {
                        current: i + 1,
                        total: request.prompts.length,
                        status: 'stopped'
                    }
                });
                break;
            }
            
            console.log(`[${SITE_NAME}] Prompt ${i + 1} concluído: ${imagesGenerated} imagem(ns)`);
            
            chrome.runtime.sendMessage({
                action: "updateImageProgress",
                data: {
                    current: i + 1,
                    total: request.prompts.length,
                    status: 'processing',
                    imagesGenerated: imagesGenerated
                }
            });
            
            // Aguardar entre prompts
            if (i < request.prompts.length - 1) {
                const waitTime = 6000; // Whisk pode ser mais lento
                console.log(`[${SITE_NAME}] Aguardando ${waitTime/1000}s antes do próximo prompt...`);
                
                chrome.runtime.sendMessage({
                    action: "updateImageProgress",
                    data: {
                        current: i + 1,
                        total: request.prompts.length,
                        status: 'waiting',
                        details: `Aguardando ${waitTime/1000}s antes do próximo prompt...`
                    }
                });
                
                await sleep(waitTime);
            }
        }
        
        if (!shouldStop) {
            console.log(`[${SITE_NAME}] Todos os prompts processados!`);
            chrome.runtime.sendMessage({
                action: "updateImageProgress",
                data: {
                    current: request.prompts.length,
                    total: request.prompts.length,
                    status: 'completed'
                }
            });
            alert('Automação concluída! Imagens baixadas com sucesso.');
        } else {
            alert('Automação interrompida!');
        }
        
        return true;
    }
    
    return true;
});

// Função principal para processar um prompt
async function processSinglePrompt(prompt) {
    console.log(`[${SITE_NAME}] >>> Processando prompt: "${prompt}"`);
    
    if (shouldStop) return 0;
    
    // 1. Encontrar caixa de texto
    const textBox = await findTextBox();
    if (!textBox) {
        console.error(`[${SITE_NAME}] ✗ Caixa de texto não encontrada!`);
        return 0;
    }
    
    console.log(`[${SITE_NAME}] ✓ Caixa de texto encontrada`);
    
    // 2. Limpar e inserir prompt
    textBox.focus();
    await sleep(500);
    
    textBox.value = '';
    textBox.textContent = '';
    
    // Simular digitação
    textBox.value = prompt;
    textBox.textContent = prompt;
    
    const inputEvent = new Event('input', { bubbles: true });
    textBox.dispatchEvent(inputEvent);
    
    await sleep(1000);
    
    // 3. Clicar no botão de gerar
    const generateButton = await findGenerateButton();
    if (!generateButton) {
        console.error(`[${SITE_NAME}] ✗ Botão de gerar não encontrado!`);
        return 0;
    }
    
    console.log(`[${SITE_NAME}] ✓ Botão encontrado, clicando...`);
    generateButton.click();
    
    await sleep(500); // Reduzido de 3000ms para 500ms!
    
    // 4. Aguardar e baixar imagens
    const imagesCount = await waitAndDownloadImages(prompt);
    
    return imagesCount;
}

// Whisk: Seletores específicos
async function findTextBox() {
    const selectors = [
        'textarea[placeholder*="Describe"]',
        'textarea[placeholder*="caption"]',
        'textarea[aria-label*="prompt"]',
        'textarea[aria-label*="describe"]',
        'textarea',
        'input[type="text"]',
        '[contenteditable="true"]'
    ];
    
    for (const selector of selectors) {
        const element = document.querySelector(selector);
        if (element) {
            console.log(`[${SITE_NAME}] Caixa de texto encontrada com seletor: ${selector}`);
            return element;
        }
    }
    
    console.error(`[${SITE_NAME}] Nenhuma caixa de texto encontrada`);
    return null;
}

async function findGenerateButton() {
    const selectors = [
        'button[aria-label*="Whisk"]',
        'button[aria-label*="Generate"]',
        'button[aria-label*="Create"]',
        'button[aria-label*="Mix"]',
        'button[aria-label*="Gerar"]',
        'button[aria-label*="Criar"]',
        'button[aria-label*="Misturar"]',
        'button[type="submit"]'
    ];
    
    for (const selector of selectors) {
        try {
            const element = document.querySelector(selector);
            if (element && !element.disabled) {
                console.log(`[${SITE_NAME}] Botão encontrado via seletor: ${selector}`);
                return element;
            }
        } catch (e) {
            // Seletor inválido, continuar
        }
    }
    
    // Busca alternativa por texto (português e inglês)
    const buttons = Array.from(document.querySelectorAll('button'));
    console.log(`[${SITE_NAME}] Procurando entre ${buttons.length} botões...`);
    
    for (const button of buttons) {
        const text = button.textContent.trim().toLowerCase();
        const ariaLabel = (button.getAttribute('aria-label') || '').toLowerCase();
        
        const keywords = [
            'whisk', 'generate', 'create', 'mix',
            'gerar', 'criar', 'misturar', 'sorte'
        ];
        
        const hasKeyword = keywords.some(keyword => 
            text.includes(keyword) || ariaLabel.includes(keyword)
        );
        
        if (hasKeyword && !button.disabled) {
            console.log(`[${SITE_NAME}] Botão encontrado: "${text}"`);
            return button;
        }
    }
    
    return null;
}

async function waitAndDownloadImages(prompt) {
    console.log(`[${SITE_NAME}] Aguardando imagens serem geradas...`);
    
    if (shouldStop) return 0;
    
    scrollToTop();
    await sleep(300); // Reduzido de 1000ms para 300ms!
    
    const maxWaitTime = 60000; // 60 segundos - Whisk pode demorar mais
    const checkInterval = 1000; // Reduzido de 2000ms para 1000ms! Verifica mais rápido
    let elapsedTime = 0;
    let newImagesFound = [];

    while (elapsedTime < maxWaitTime) {
        if (shouldStop) return 0;
        
        await sleep(checkInterval);
        elapsedTime += checkInterval;

        scrollToTop();
        await sleep(200); // Reduzido de 500ms para 200ms!

        // Whisk: seletores de imagens geradas
        const allImages = document.querySelectorAll('img[src*="googleusercontent.com"], img[src*="labs.google"], div[class*="result"] img, div[class*="output"] img, div[class*="generated"] img');
        
        console.log(`[${SITE_NAME}] Check ${elapsedTime/1000}s: ${allImages.length} imagens encontradas`);
        
        newImagesFound = Array.from(allImages).filter(img => 
            !processedImages.has(img.src) && 
            img.src && 
            !img.src.includes('data:image') &&
            img.complete &&
            img.naturalWidth > 100
        );
        
        console.log(`[${SITE_NAME}] ${newImagesFound.length} nova(s) imagem(ns) detectada(s)`);
        
        if (newImagesFound.length >= 3) {
            console.log(`[${SITE_NAME}] ✓ 3+ imagens encontradas! Baixando...`);
            await sleep(200); // Reduzido de 500ms para 200ms!
            await downloadImages(newImagesFound, prompt);
            return newImagesFound.length;
        }
        
        if (newImagesFound.length > 0 && elapsedTime >= maxWaitTime - checkInterval) {
            console.log(`[${SITE_NAME}] ✓ Baixando ${newImagesFound.length} imagem(ns) encontrada(s)...`);
            await downloadImages(newImagesFound, prompt);
            return newImagesFound.length;
        }
    }

    if (newImagesFound.length > 0) {
        console.log(`[${SITE_NAME}] ✓ Baixando ${newImagesFound.length} imagem(ns)...`);
        await downloadImages(newImagesFound, prompt);
        return newImagesFound.length;
    }
    
    console.log(`[${SITE_NAME}] ⚠ Nenhuma imagem nova gerada`);
    return 0;
}

async function downloadImages(imagesToProcess, prompt) {
    console.log(`[${SITE_NAME}] >>> Baixando ${imagesToProcess.length} imagem(ns)...`);
    
    if (shouldStop) return;
    
    scrollToTop();
    await sleep(2000);

    let downloadedCount = 0;
    const timestamp = new Date().getTime();
    const cleanPrompt = prompt.substring(0, 30).replace(/[^a-z0-9]/gi, '_');

    for (let j = 0; j < imagesToProcess.length; j++) {
        if (shouldStop) break;
        
        const img = imagesToProcess[j];
        const imgSrc = img.src;
        
        console.log(`[${SITE_NAME}] >>> Baixando ${j + 1}/${imagesToProcess.length}`);
        
        try {
            const response = await fetch(imgSrc);
            const blob = await response.blob();
            
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.style.display = 'none';
            a.href = url;
            a.download = `whisk_${cleanPrompt}_${timestamp}_${j + 1}.jpg`;
            
            document.body.appendChild(a);
            a.click();
            
            window.URL.revokeObjectURL(url);
            document.body.removeChild(a);
            
            downloadedCount++;
            processedImages.add(imgSrc);
            
            console.log(`[${SITE_NAME}] ✓ Download ${j + 1} concluído!`);
            
            if (j < imagesToProcess.length - 1) {
                await sleep(200); // Reduzido de 500ms para 200ms
            }
            
        } catch (error) {
            console.error(`[${SITE_NAME}] ✗ Erro no download ${j + 1}:`, error);
        }
    }

    console.log(`[${SITE_NAME}] ✓ Concluído: ${downloadedCount}/${imagesToProcess.length} baixadas`);
    
    chrome.storage.local.set({ 
        whisk_processedImages: Array.from(processedImages)
    });
}

// Inicialização ao carregar página
if (document.readyState === 'loading') {
    window.addEventListener('DOMContentLoaded', initOnPageLoad);
} else {
    initOnPageLoad();
}

async function initOnPageLoad() {
    console.log(`[${SITE_NAME}] Página carregada!`);
    await sleep(3000);
    
    chrome.storage.local.get(['whisk_isInitialized'], async (result) => {
        if (!result.whisk_isInitialized) {
            console.log(`[${SITE_NAME}] Primeira carga, inicializando...`);
            await initializeImageHistory();
        } else {
            chrome.storage.local.get(['whisk_processedImages'], (result) => {
                if (result.whisk_processedImages) {
                    processedImages = new Set(result.whisk_processedImages);
                    isInitialized = true;
                    console.log(`[${SITE_NAME}] Carregadas ${processedImages.size} imagens do histórico`);
                }
            });
        }
    });
}

// Notificação visual
const notice = document.createElement('div');
notice.style.cssText = `
    position: fixed;
    bottom: 20px;
    right: 20px;
    padding: 10px 15px;
    background: rgba(0, 0, 0, 0.7);
    color: white;
    border-radius: 5px;
    z-index: 9999;
    font-family: Arial, sans-serif;
    font-size: 14px;
`;
notice.textContent = `✅ Image Downloader ativo (${SITE_NAME})`;
document.body.appendChild(notice);

setTimeout(() => {
    notice.style.opacity = '0';
    notice.style.transition = 'opacity 1s ease-out';
    setTimeout(() => notice.remove(), 1000);
}, 3000);

console.log(`[${SITE_NAME}] Script pronto!`);

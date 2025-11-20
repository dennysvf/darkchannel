// content.js - Image Downloader by Skillo - v1.0

// ===== INÍCIO DO SCRIPT META AI =====
// Verificar se já foi carregado para evitar duplicatas
if (window.__METAAI_SCRIPT_LOADED__) {
    console.log('[AutoMetaImage-DL] Script já carregado, ignorando duplicata');
} else {
    window.__METAAI_SCRIPT_LOADED__ = true;
    console.log('[AutoMetaImage-DL] Script carregado pela primeira vez');
}

let processedImagesDownload = new Set();
let isInitializedDownload = false;
let shouldStopDownload = false;
const MAX_HISTORY_DOWNLOAD = 10;

console.log('[AutoMetaImage-DL] Content script carregado!');

function scrollToTopDownload() {
    console.log('[AutoMetaImage-DL] Rolando para o topo...');
    window.scrollTo({
        top: 0,
        behavior: 'smooth'
    });
}

async function initializeImageHistoryDownload() {
    if (!isInitializedDownload) {
        console.log('[AutoMetaImage-DL] Inicializando histórico de imagens...');
        await sleepDownload(2000);
        
        scrollToTopDownload();
        await sleepDownload(2000);
        
        const existingImages = document.querySelectorAll('img[alt*="Mídia gerada"], img[alt*="Generated image"]');
        console.log(`[AutoMetaImage-DL] Encontradas ${existingImages.length} imagens existentes`);
        
        const imagesToAdd = Math.min(existingImages.length, MAX_HISTORY_DOWNLOAD);
        
        for (let i = 0; i < imagesToAdd; i++) {
            const imgSrc = existingImages[i].src;
            processedImagesDownload.add(imgSrc);
            console.log(`[AutoMetaImage-DL] Imagem ${i + 1}/${imagesToAdd} adicionada ao histórico`);
        }
        
        console.log(`[AutoMetaImage-DL] Histórico inicializado com ${processedImagesDownload.size} imagens`);
        isInitializedDownload = true;
        
        chrome.storage.local.set({ 
            processedImagesArrayDownload: Array.from(processedImagesDownload),
            isInitializedDownload: true
        });
    }
}

function updateProcessedImagesHistoryDownload(newImageUrl) {
    processedImagesDownload.add(newImageUrl);
    
    if (processedImagesDownload.size > MAX_HISTORY_DOWNLOAD) {
        const imagesArray = Array.from(processedImagesDownload);
        processedImagesDownload.delete(imagesArray[0]);
        console.log(`[AutoMetaImage-DL] Histórico excedeu ${MAX_HISTORY_DOWNLOAD}, removendo mais antiga`);
    }
    
    console.log(`[AutoMetaImage-DL] Histórico atualizado: ${processedImagesDownload.size} imagens`);
}

chrome.runtime.onMessage.addListener(async (request, sender, sendResponse) => {
    console.log('[AutoMetaImage-DL] Mensagem recebida:', request);
    
    if (request.action === "stopImageDownload") {
        console.log('[AutoMetaImage-DL] Comando de parada recebido!');
        shouldStopDownload = true;
        sendResponse({ status: "stopping" });
        return true;
    }
    
    if (request.action === "startImageDownload") {
        shouldStopDownload = false;
        console.log('[AutoMetaImage-DL] Ação startImageDownload detectada');
        console.log('[AutoMetaImage-DL] Prompts recebidos:', request.prompts.length);
        
        if (!isInitializedDownload) {
            console.log('[AutoMetaImage-DL] Inicializando histórico...');
            await initializeImageHistoryDownload();
        }
        
        sendResponse({ status: "started" });
        
        for (let i = 0; i < request.prompts.length; i++) {
            if (shouldStopDownload) {
                console.log('[AutoMetaImage-DL] Automação interrompida!');
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
            console.log(`[AutoMetaImage-DL] ========================================`);
            console.log(`[AutoMetaImage-DL] Processando prompt ${i + 1}/${request.prompts.length}`);
            console.log(`[AutoMetaImage-DL] Prompt: "${prompt}"`);
            
            chrome.runtime.sendMessage({
                action: "updateImageProgress",
                data: {
                    current: i + 1,
                    total: request.prompts.length,
                    status: 'processing',
                    details: `"${prompt.substring(0, 50)}${prompt.length > 50 ? '...' : ''}"`
                }
            });
            
            const imagesGenerated = await processSinglePromptDownload(prompt);
            
            if (shouldStopDownload) {
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
            
            console.log(`[AutoMetaImage-DL] Prompt ${i + 1} concluído: ${imagesGenerated} imagem(ns)`);
            
            chrome.runtime.sendMessage({
                action: "updateImageProgress",
                data: {
                    current: i + 1,
                    total: request.prompts.length,
                    status: 'processing',
                    imagesGenerated: imagesGenerated
                }
            });
            
            if (i < request.prompts.length - 1) {
                // Verificar se o próximo prompt é de vídeo
                const nextPrompt = request.prompts[i + 1];
                const isNextVideo = isVideoPrompt(nextPrompt);
                
                // Determinar tempo de espera baseado no tipo do prompt ATUAL
                const currentPromptIsVideo = isVideoPrompt(request.prompts[i]);
                let waitTime;
                
                if (currentPromptIsVideo) {
                    // Se foi vídeo, aguardar 40 segundos
                    waitTime = 40000;
                    console.log(`[AutoMetaImage-DL] 🎬 Prompt de vídeo concluído → Aguardando ${waitTime/1000}s...`);
                } else {
                    // Se foi imagem, tempo baseado na quantidade gerada
                    
                    waitTime = 4000;
                    
                    console.log(`[AutoMetaImage-DL] 🖼️ ${imagesGenerated} imagem(ns) baixada(s) → Aguardando ${waitTime/1000}s...`);
                }
                
                chrome.runtime.sendMessage({
                    action: "updateImageProgress",
                    data: {
                        current: i + 1,
                        total: request.prompts.length,
                        status: 'waiting',
                        details: `Aguardando ${waitTime/1000}s antes do próximo prompt${isNextVideo ? ' (VÍDEO)' : ''}...`
                    }
                });
                
                for (let elapsed = 0; elapsed < waitTime; elapsed += 1000) {
                    if (shouldStopDownload) break;
                    await sleepDownload(1000);
                }
                
                if (shouldStopDownload) {
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
            }
        }
        
        if (!shouldStopDownload) {
            console.log('[AutoMetaImage-DL] Todos os prompts processados!');
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

// CORRIGIDO: Função baseada no HTML real fornecido
async function findTextBox() {
    console.log('[AutoMetaImage-DL] Procurando campo de texto...');
    
    // Seletor EXATO do HTML fornecido
    let textBox = document.querySelector('div[aria-label="Descreva sua imagem..."][contenteditable="true"][role="textbox"][data-lexical-editor="true"]');
    
    if (textBox) {
        console.log('[AutoMetaImage-DL] ✓ Campo encontrado: Seletor exato do Meta AI');
        return textBox;
    }
    
    // Fallback 1: sem data-lexical-editor
    textBox = document.querySelector('div[aria-label="Descreva sua imagem..."][contenteditable="true"][role="textbox"]');
    if (textBox) {
        console.log('[AutoMetaImage-DL] ✓ Campo encontrado: Seletor sem data-lexical');
        return textBox;
    }
    
    // Fallback 2: apenas contenteditable + role + data-lexical
    textBox = document.querySelector('div[contenteditable="true"][role="textbox"][data-lexical-editor="true"]');
    if (textBox) {
        console.log('[AutoMetaImage-DL] ✓ Campo encontrado: Seletor genérico com lexical');
        return textBox;
    }
    
    // Fallback 3: classe notranslate + contenteditable
    textBox = document.querySelector('div.notranslate[contenteditable="true"][role="textbox"]');
    if (textBox) {
        console.log('[AutoMetaImage-DL] ✓ Campo encontrado: Por classe notranslate');
        return textBox;
    }
    
    // Fallback 4: busca por aria-placeholder
    textBox = document.querySelector('div[aria-placeholder="Descreva sua imagem..."]');
    if (textBox) {
        console.log('[AutoMetaImage-DL] ✓ Campo encontrado: Por aria-placeholder');
        return textBox;
    }

    // Fallback 5: Qualquer div contenteditable visível
    const allEditables = document.querySelectorAll('div[contenteditable="true"]');
    for (let i = 0; i < allEditables.length; i++) {
        const el = allEditables[i];
        if (el.offsetParent !== null) { // Verifica se é visível
            console.log('[AutoMetaImage-DL] ✓ Campo encontrado: Contenteditable visível');
            return el;
        }
    }
    
    console.error('[AutoMetaImage-DL] ✗ Campo de texto NÃO encontrado!');
    console.log('[AutoMetaImage-DL] Tentando buscar todos contenteditable...');
    
    // Debug: listar todos os contenteditable
    const allEditables2 = document.querySelectorAll('div[contenteditable="true"]');
    console.log(`[AutoMetaImage-DL] Encontrados ${allEditables2.length} elementos contenteditable`);
    
    for (let i = 0; i < allEditables2.length; i++) {
        const el = allEditables2[i];
        console.log(`[AutoMetaImage-DL] Contenteditable ${i}:`, {
            ariaLabel: el.getAttribute('aria-label'),
            role: el.getAttribute('role'),
            visible: el.offsetParent !== null
        });
    }
    
    return null;
}

// CORRIGIDO: Função baseada no HTML real fornecido
async function findSendButton() {
    console.log('[AutoMetaImage-DL] Procurando botão de enviar...');
    
    // Seletor EXATO baseado no HTML fornecido
    // O botão tem aria-label="Enviar" e está desabilitado inicialmente (aria-disabled="true")
    let button = document.querySelector('div[aria-label="Enviar"][role="button"]');
    
    if (button) {
        console.log('[AutoMetaImage-DL] ✓ Botão encontrado: Seletor exato');
        const isDisabled = button.getAttribute('aria-disabled') === 'true';
        console.log(`[AutoMetaImage-DL] Status do botão - Desabilitado: ${isDisabled}`);
        return button;
    }
    
    // Fallback 1: Buscar pelo SVG específico (path com d="M16.0279...")
    console.log('[AutoMetaImage-DL] Tentando encontrar pelo SVG...');
    const allButtons = document.querySelectorAll('[role="button"]');
    
    for (const btn of allButtons) {
        const svg = btn.querySelector('svg');
        if (svg) {
            const path = svg.querySelector('path[d*="M16.0279"]');
            if (path) {
                console.log('[AutoMetaImage-DL] ✓ Botão encontrado: Por SVG path específico');
                return btn;
            }
        }
        
        // Verificar também por aria-label que contenha "Enviar" ou "Send"
        const ariaLabel = btn.getAttribute('aria-label');
        if (ariaLabel && (ariaLabel.includes('Enviar') || ariaLabel.toLowerCase().includes('send'))) {
            console.log('[AutoMetaImage-DL] ✓ Botão encontrado: Por aria-label');
            return btn;
        }
    }

    // Fallback 2: Qualquer botão que pareça ser de envio
    for (const btn of allButtons) {
        // Verificar texto interno
        if (btn.textContent && (btn.textContent.includes('Enviar') || 
                              btn.textContent.toLowerCase().includes('send') ||
                              btn.textContent.includes('Gerar'))) {
            console.log('[AutoMetaImage-DL] ✓ Botão encontrado: Por texto interno');
            return btn;
        }

        // Verificar se contém ícone típico de envio (seta, avião, etc)
        const hasIcon = btn.querySelector('svg') !== null;
        if (hasIcon && btn.offsetParent !== null) { // Verifica se é visível
            console.log('[AutoMetaImage-DL] ✓ Botão encontrado: Possível botão de envio com ícone');
            return btn;
        }
    }
    
    console.error('[AutoMetaImage-DL] ✗ Botão de enviar NÃO encontrado!');

    // Última tentativa: pegar qualquer botão visível
    for (const btn of allButtons) {
        if (btn.offsetParent !== null) { // Verifica se é visível
            console.log('[AutoMetaImage-DL] ✓ Botão visível encontrado (tentativa final)');
            return btn;
        }
    }

    return null;
}

// Função para detectar se é um prompt de vídeo
function isVideoPrompt(prompt) {
    const videoKeywords = [
        // Português
        'crie um vídeo', 'crie vídeo', 'criar vídeo', 'criar um vídeo',
        'faça um vídeo', 'faça vídeo', 'fazer vídeo', 'fazer um vídeo',
        'gere um vídeo', 'gere vídeo', 'gerar vídeo', 'gerar um vídeo',
        'produza um vídeo', 'produza vídeo', 'produzir vídeo',
        'monte um vídeo', 'monte vídeo', 'montar vídeo',
        // Inglês
        'create a video', 'create video', 'make a video', 'make video',
        'generate a video', 'generate video', 'produce a video', 'produce video',
        'create a movie', 'create movie', 'make a movie', 'make movie',
        'generate a movie', 'generate movie',
        // Espanhol
        'crea un video', 'crea video', 'crear video', 'crear un video',
        'haz un video', 'haz video', 'hacer video'
    ];
    
    const lowerPrompt = prompt.toLowerCase().trim();
    
    for (const keyword of videoKeywords) {
        if (lowerPrompt.includes(keyword)) {
            return true;
        }
    }
    
    return false;
}

async function processSinglePromptDownload(prompt) {
    console.log(`[AutoMetaImage-DL] >>> Processando: "${prompt}"`);
    
    // Detectar se é prompt de vídeo
    const isVideo = isVideoPrompt(prompt);
    if (isVideo) {
        console.log('[AutoMetaImage-DL] 🎬 PROMPT DE VÍDEO DETECTADO! Modo vídeo ativado.');
    } else {
        console.log('[AutoMetaImage-DL] 🖼️ Prompt de imagem detectado. Modo normal.');
    }
    
    if (shouldStopDownload) return 0;
    
    // Encontrar o campo de texto
    const textBox = await findTextBox();
    if (!textBox) {
        console.error('[AutoMetaImage-DL] ✗ ERRO: Campo de texto não encontrado!');
        alert('Erro: Campo de texto não encontrado. Verifique se está na página correta do Meta AI (https://www.meta.ai/)');
        return 0;
    }

    console.log('[AutoMetaImage-DL] >>> Focando no campo de texto...');
    textBox.focus();
    await sleepDownload(300);
    
    // Limpar conteúdo anterior - MÉTODO MELHORADO
    console.log('[AutoMetaImage-DL] >>> Limpando campo...');
    
    try {
        // Limpar o parágrafo interno
        const paragraph = textBox.querySelector('p');
        if (paragraph) {
            paragraph.innerHTML = '<br>';
        } else {
            // Se não houver parágrafo, limpar o conteúdo diretamente
            textBox.innerHTML = '<br>';
        }
        
        await sleepDownload(200);
        
        // Inserir o novo prompt
        console.log('[AutoMetaImage-DL] >>> Inserindo prompt...');
        
        if (paragraph) {
            // Remover o <br> e adicionar o texto
            paragraph.innerHTML = '';
            paragraph.textContent = prompt;
        } else {
            // Criar novo parágrafo se não existir
            textBox.innerHTML = `<p>${prompt}</p>`;
        }
    } catch (error) {
        console.error('[AutoMetaImage-DL] Erro ao manipular o HTML:', error);
        
        // Método alternativo: usar execCommand (obsoleto mas ainda funcional)
        try {
            document.execCommand('selectAll', false, null);
            document.execCommand('delete', false, null);
            document.execCommand('insertText', false, prompt);
        } catch (cmdError) {
            console.error('[AutoMetaImage-DL] Erro ao usar execCommand:', cmdError);
            
            // Último recurso: usar propriedade textContent
            try {
                textBox.textContent = prompt;
            } catch (finalError) {
                console.error('[AutoMetaImage-DL] Erro final ao inserir texto:', finalError);
                return 0;
            }
        }
    }
    
    console.log('[AutoMetaImage-DL] >>> Texto inserido, disparando eventos...');
    
    // Focar novamente
    textBox.focus();
    await sleepDownload(200);
    
    // Disparar eventos de input
    try {
        const inputEvent = new InputEvent('input', { 
            bubbles: true, 
            cancelable: true,
            inputType: 'insertText',
            data: prompt
        });
        textBox.dispatchEvent(inputEvent);
        
        const changeEvent = new Event('change', { bubbles: true });
        textBox.dispatchEvent(changeEvent);
        
        // Simular digitação
        const keydownEvent = new KeyboardEvent('keydown', { 
            bubbles: true, 
            cancelable: true,
            key: 'Enter',
            code: 'Enter'
        });
        textBox.dispatchEvent(keydownEvent);
        
        await sleepDownload(1000);
    } catch (error) {
        console.error('[AutoMetaImage-DL] Erro ao disparar eventos:', error);
    }

    if (shouldStopDownload) return 0;

    // Encontrar o botão de enviar
    const sendButton = await findSendButton();
    if (!sendButton) {
        console.error('[AutoMetaImage-DL] ✗ ERRO: Botão não encontrado!');
        alert('Erro: Botão de enviar não encontrado.');
        return 0;
    }

    // Verificar se o botão está desabilitado
    const isDisabled = sendButton.getAttribute('aria-disabled') === 'true';
    if (isDisabled) {
        console.log('[AutoMetaImage-DL] ⚠ Botão ainda desabilitado, aguardando 1s...');
        await sleepDownload(1000);
    }
    
    console.log('[AutoMetaImage-DL] >>> Clicando no botão enviar...');
    sendButton.click();
    console.log('[AutoMetaImage-DL] ✓ Prompt enviado!');
    
    // Aguardar 2s antes de verificar imagens (REDUZIDO de 20s!)
    console.log('[AutoMetaImage-DL] >>> Aguardando 2s para geração...');
    await sleepDownload(2000); // Reduzido de 20 segundos para 2!
    
    // Se for vídeo, apenas aguardar sem baixar
    if (isVideo) {
        console.log('[AutoMetaImage-DL] 🎬 Modo vídeo: aguardando geração sem baixar...');
        const videosDetected = await waitForVideosOnly(prompt);
        return videosDetected;
    }
    
    // Se for imagem, baixar normalmente
    const imagesGenerated = await waitAndDownloadNewImagesDownload(prompt);
    return imagesGenerated;
}

async function waitAndDownloadNewImagesDownload(prompt) {
    console.log('[AutoMetaImage-DL] >>> Verificando novas imagens...');
    
    if (shouldStopDownload) return 0;
    
    scrollToTopDownload();
    await sleepDownload(300); // Reduzido de 1000ms para 300ms!
    
    const maxWaitTime = 40000;
    const checkInterval = 1000; // Reduzido de 2500ms para 1000ms! Verifica mais rápido
    const maxNewImages = 4;
    let elapsedTime = 0;
    let newImagesFound = [];

    while (elapsedTime < maxWaitTime) {
        if (shouldStopDownload) return 0;
        
        await sleepDownload(checkInterval);
        elapsedTime += checkInterval;

        scrollToTopDownload();
        await sleepDownload(200); // Reduzido de 500ms para 200ms!

        // Buscar por seletores mais amplos para encontrar as imagens
        const allImages = document.querySelectorAll('img[alt*="Mídia gerada"], img[alt*="Generated image"], img[alt*="gerada"], img[alt*="generated"]');
        
        // Se não encontrar nada com os seletores específicos, tenta imagens recentes
        let topFourImages = Array.from(allImages).slice(0, 4);
        
        // Se ainda não encontrar, pega as imagens mais recentes que aparecem na tela
        if (topFourImages.length === 0) {
            const allOtherImages = document.querySelectorAll('img');
            // Filtrar apenas imagens visíveis e razoavelmente grandes
            const visibleImages = Array.from(allOtherImages).filter(img => {
                if (!img.offsetParent) return false; // Invisível
                const rect = img.getBoundingClientRect();
                // Considerar apenas imagens com pelo menos 100x100px
                return rect.width >= 100 && rect.height >= 100;
            });
            
            topFourImages = visibleImages.slice(0, 4);
        }
        
        console.log(`[AutoMetaImage-DL] Check ${elapsedTime/1000}s: ${allImages.length} imagens totais, ${topFourImages.length} consideradas`);
        
        newImagesFound = [];
        for (const img of topFourImages) {
            if (!processedImagesDownload.has(img.src)) {
                newImagesFound.push(img);
            }
        }
        
        console.log(`[AutoMetaImage-DL] ${newImagesFound.length} nova(s) imagem(ns) detectada(s)`);
        
        if (newImagesFound.length >= maxNewImages) {
            console.log('[AutoMetaImage-DL] ✓ Máximo atingido! Baixando...');
            await sleepDownload(200); // Reduzido de 500ms para 200ms!
            await downloadImagesOnly(newImagesFound, prompt);
            return newImagesFound.length;
        }
        
        // Se encontrou pelo menos uma imagem e está no último ciclo de verificação
        if (newImagesFound.length > 0 && elapsedTime >= maxWaitTime - checkInterval) {
            console.log(`[AutoMetaImage-DL] ✓ Baixando ${newImagesFound.length} imagem(ns) encontrada(s)...`);
            await downloadImagesOnly(newImagesFound, prompt);
            return newImagesFound.length;
        }
    }

    if (newImagesFound.length > 0) {
        console.log(`[AutoMetaImage-DL] ✓ Baixando ${newImagesFound.length} imagem(ns)...`);
        await downloadImagesOnly(newImagesFound, prompt);
        return newImagesFound.length;
    }
    
    console.log('[AutoMetaImage-DL] ⚠ Nenhuma imagem nova gerada');
    return 0;
}

// Nova função: apenas aguardar vídeos sem baixar
async function waitForVideosOnly(prompt) {
    console.log('[AutoMetaImage-DL] 🎬 Aguardando vídeos (sem download)...');
    
    if (shouldStopDownload) return 0;
    
    scrollToTopDownload();
    await sleepDownload(2000);
    
    const maxWaitTime = 60000; // 60 segundos para vídeos (mais tempo que imagens)
    const checkInterval = 5000;
    const maxNewVideos = 4;
    let elapsedTime = 0;
    let videosFound = 0;

    while (elapsedTime < maxWaitTime) {
        if (shouldStopDownload) return 0;
        
        await sleepDownload(checkInterval);
        elapsedTime += checkInterval;

        scrollToTopDownload();
        await sleepDownload(1000);

        // Detectar vídeos (procurar por tags <video> ou elementos com indicadores de vídeo)
        const allVideos = document.querySelectorAll('video');
        videosFound = Math.min(allVideos.length, maxNewVideos);
        
        console.log(`[AutoMetaImage-DL] 🎬 Check ${elapsedTime/1000}s: ${allVideos.length} vídeo(s) detectado(s)`);
        
        if (videosFound >= maxNewVideos) {
            console.log(`[AutoMetaImage-DL] ✓ ${videosFound} vídeos gerados! Seguindo para próximo prompt.`);
            return videosFound;
        }
        
        // Verificar também por imagens relacionadas a vídeos (thumbnails)
        const videoThumbs = document.querySelectorAll('img[alt*="vídeo"], img[alt*="video"], img[alt*="Video"]');
        if (videoThumbs.length > 0) {
            videosFound = Math.min(videoThumbs.length, maxNewVideos);
            console.log(`[AutoMetaImage-DL] 🎬 Detectadas ${videosFound} thumbnail(s) de vídeo`);
            
            if (videosFound >= maxNewVideos) {
                console.log(`[AutoMetaImage-DL] ✓ ${videosFound} vídeos prontos! Seguindo para próximo prompt.`);
                return videosFound;
            }
        }
    }

    console.log(`[AutoMetaImage-DL] ⏱ Tempo limite atingido (${maxWaitTime/1000}s)`);
    console.log(`[AutoMetaImage-DL] ℹ️ ${videosFound} vídeo(s) detectado(s). Seguindo para próximo prompt.`);
    return videosFound;
}

async function downloadImagesOnly(imagesToProcess, prompt) {
    console.log(`[AutoMetaImage-DL] >>> Baixando ${imagesToProcess.length} imagem(ns)...`);
    
    if (shouldStopDownload) return;
    
    scrollToTopDownload();
    await sleepDownload(2000);

    let downloadedCount = 0;
    const timestamp = new Date().getTime();
    const cleanPrompt = prompt.substring(0, 30).replace(/[^a-z0-9]/gi, '_');

    for (let j = 0; j < imagesToProcess.length; j++) {
        if (shouldStopDownload) break;
        
        const img = imagesToProcess[j];
        const imgSrc = img.src;
        
        console.log(`[AutoMetaImage-DL] >>> Baixando ${j + 1}/${imagesToProcess.length}`);
        
        try {
            const response = await fetch(imgSrc);
            const blob = await response.blob();
            
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.style.display = 'none';
            a.href = url;
            a.download = `meta_image_${cleanPrompt}_${timestamp}_${j + 1}.jpg`;
            
            document.body.appendChild(a);
            a.click();
            
            window.URL.revokeObjectURL(url);
            document.body.removeChild(a);
            
            downloadedCount++;
            updateProcessedImagesHistoryDownload(imgSrc);
            
            console.log(`[AutoMetaImage-DL] ✓ Download ${j + 1} concluído!`);
            
            if (j < imagesToProcess.length - 1) {
                for (let elapsed = 0; elapsed < 2000; elapsed += 500) {
                    if (shouldStopDownload) break;
                    await sleepDownload(500);
                }
            }
            
        } catch (error) {
            console.error(`[AutoMetaImage-DL] ✗ Erro no download ${j + 1}:`, error);
        }
    }

    console.log(`[AutoMetaImage-DL] ✓ Concluído: ${downloadedCount}/${imagesToProcess.length} baixadas`);
    
    chrome.storage.local.set({ 
        processedImagesArrayDownload: Array.from(processedImagesDownload),
        isInitializedDownload: true
    });
}

function sleepDownload(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

if (document.readyState === 'loading') {
    window.addEventListener('DOMContentLoaded', initOnPageLoadDownload);
} else {
    initOnPageLoadDownload();
}

async function initOnPageLoadDownload() {
    console.log('[AutoMetaImage-DL] Página carregada!');
    await sleepDownload(3000);
    
    chrome.storage.local.get(['isInitializedDownload'], async (result) => {
        if (!result.isInitializedDownload) {
            console.log('[AutoMetaImage-DL] Primeira carga, inicializando...');
            await initializeImageHistoryDownload();
        } else {
            chrome.storage.local.get(['processedImagesArrayDownload'], (result) => {
                if (result.processedImagesArrayDownload) {
                    processedImagesDownload = new Set(result.processedImagesArrayDownload);
                    isInitializedDownload = true;
                    console.log(`[AutoMetaImage-DL] Carregadas ${processedImagesDownload.size} imagens do histórico`);
                }
            });
        }
    });
}

// Adicionar uma dica visual quando a extensão carrega
const extensionLoadedNotice = document.createElement('div');
extensionLoadedNotice.style.position = 'fixed';
extensionLoadedNotice.style.bottom = '20px';
extensionLoadedNotice.style.right = '20px';
extensionLoadedNotice.style.padding = '10px 15px';
extensionLoadedNotice.style.backgroundColor = 'rgba(0, 0, 0, 0.7)';
extensionLoadedNotice.style.color = 'white';
extensionLoadedNotice.style.borderRadius = '5px';
extensionLoadedNotice.style.zIndex = '9999';
extensionLoadedNotice.style.fontFamily = 'Arial, sans-serif';
extensionLoadedNotice.style.fontSize = '14px';
extensionLoadedNotice.textContent = '✅ Image Downloader ativo';
document.body.appendChild(extensionLoadedNotice);

setTimeout(() => {
    extensionLoadedNotice.style.opacity = '0';
    extensionLoadedNotice.style.transition = 'opacity 1s ease-out';
    setTimeout(() => extensionLoadedNotice.remove(), 1000);
}, 3000);

console.log('[AutoMetaImage-DL] Script pronto!');
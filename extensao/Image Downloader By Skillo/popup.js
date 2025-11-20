// popup.js - Auto Meta Image

document.addEventListener('DOMContentLoaded', () => {
    const promptsTextarea = document.getElementById('prompts');
    const startButton = document.getElementById('startButton');
    const clearButton = document.getElementById('clearButton');
    const statusDiv = document.getElementById('status');
    const progressDiv = document.getElementById('progress');
    const progressText = document.getElementById('progressText');
    const progressFill = document.getElementById('progressFill');
    const progressDetails = document.getElementById('progressDetails');

    let isAutomationRunning = false;

    // Detectar e mostrar site atual
    chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
        const url = tabs[0].url;
        let siteName = '';
        
        if (url.includes('meta.ai')) {
            siteName = '🌐 Meta AI';
        } else if (url.includes('labs.google')) {
            siteName = '🎭 Whisk (Google)';
        } else if (url.includes('piclumen.com')) {
            siteName = '✨ Piclumen';
        }
        
        if (siteName) {
            showStatus(`Site detectado: ${siteName}`, 'info');
        } else {
            showStatus('⚠️ Abra um dos sites suportados: Meta AI, Whisk ou Piclumen', 'error');
        }
    });

    // Carrega os prompts salvos
    chrome.storage.local.get(['savedPrompts'], (result) => {
        if (result.savedPrompts) {
            promptsTextarea.value = result.savedPrompts;
        }
    });

    // Verifica se há uma automação em andamento
    chrome.storage.local.get(['automationInProgress', 'currentProgress'], (result) => {
        if (result.automationInProgress && result.currentProgress) {
            isAutomationRunning = true;
            startButton.disabled = true;
            startButton.textContent = 'Processando...';
            progressDiv.classList.add('show');
            updateProgress(result.currentProgress);
            showStatus('Automação em andamento...', 'processing');
            
            clearButton.textContent = 'Parar Automação';
            clearButton.classList.add('stop-mode');
        }
    });

    // Salva o conteúdo da textarea automaticamente
    promptsTextarea.addEventListener('input', () => {
        chrome.storage.local.set({ savedPrompts: promptsTextarea.value });
    });

    // Escuta atualizações de progresso do content script
    chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
        if (request.action === "updateImageProgress") {
            updateProgress(request.data);
            chrome.storage.local.set({ 
                currentProgress: request.data,
                automationInProgress: request.data.status !== 'completed'
            });
        }
    });

    // Botão Iniciar - CORRIGIDO para todos os sites
    startButton.addEventListener('click', () => {
        const prompts = promptsTextarea.value.split('\n').filter(p => p.trim() !== '');
        
        if (prompts.length === 0) {
            showStatus('Por favor, insira pelo menos um prompt!', 'error');
            return;
        }

        chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
            const url = tabs[0].url;
            const supportedSites = [
                'meta.ai',
                'labs.google',
                'piclumen.com'  // Aceita tanto piclumen.com quanto www.piclumen.com
            ];
            
            const isSupported = supportedSites.some(site => url.includes(site));
            
            if (!isSupported) {
                showStatus('Por favor, abra um dos sites suportados: Meta AI, Whisk ou Piclumen!', 'error');
                return;
            }

            isAutomationRunning = true;
            chrome.storage.local.set({ 
                automationInProgress: true,
                shouldStop: false,
                currentProgress: {
                    current: 0,
                    total: prompts.length,
                    status: 'processing',
                    details: 'Iniciando...'
                }
            });

            startButton.disabled = true;
            startButton.textContent = 'Processando...';
            
            clearButton.textContent = 'Parar Automação';
            clearButton.classList.add('stop-mode');
            
            progressDiv.classList.add('show');
            progressText.textContent = 'Iniciando automação...';
            progressFill.style.width = '0%';
            progressFill.textContent = '0%';
            progressDetails.textContent = '';
            
            showStatus(`Iniciando com ${prompts.length} prompt(s)...`, 'processing');
            
            // CORRIGIDO: action mudado para "startImageDownload"
            chrome.tabs.sendMessage(tabs[0].id, {
                action: "startImageDownload",
                prompts: prompts
            }, (response) => {
                if (chrome.runtime.lastError) {
                    showStatus('Erro: Recarregue a página do Meta AI', 'error');
                    resetButton();
                    chrome.storage.local.set({ automationInProgress: false });
                    console.error('[Popup] Erro ao enviar mensagem:', chrome.runtime.lastError);
                } else {
                    console.log('[Popup] Mensagem enviada com sucesso:', response);
                }
            });
        });
    });
    
    // Botão Limpar / Parar - CORRIGIDO
    clearButton.addEventListener('click', () => {
        if (isAutomationRunning) {
            if (confirm('Deseja realmente parar a automação?')) {
                chrome.storage.local.set({ shouldStop: true });
                
                chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
                    if (tabs[0]) {
                        // CORRIGIDO: action mudado para "stopImageDownload"
                        chrome.tabs.sendMessage(tabs[0].id, {
                            action: "stopImageDownload"
                        });
                    }
                });
                
                showStatus('Parando automação...', 'info');
                
                setTimeout(() => {
                    resetButton();
                    progressDiv.classList.remove('show');
                    showStatus('Automação interrompida!', 'error');
                    
                    chrome.storage.local.set({ 
                        automationInProgress: false,
                        currentProgress: null,
                        shouldStop: false
                    });
                }, 2000);
            }
        } else {
            if (confirm('Deseja limpar todos os prompts salvos?')) {
                promptsTextarea.value = '';
                chrome.storage.local.remove('savedPrompts');
                showStatus('Prompts limpos com sucesso!', 'success');
            }
        }
    });

    // Função para atualizar o progresso
    function updateProgress(data) {
        const { current, total, status, details, imagesGenerated } = data;
        
        if (status === 'completed') {
            isAutomationRunning = false;
            progressText.textContent = '✓ Automação concluída!';
            progressFill.style.width = '100%';
            progressFill.textContent = '100%';
            progressDetails.textContent = `Total: ${total} prompt(s) processados`;
            showStatus('Automação concluída! Imagens criadas e baixadas com sucesso.', 'success');
            resetButton();
            
            chrome.storage.local.set({ 
                automationInProgress: false,
                currentProgress: null,
                shouldStop: false
            });
            
            setTimeout(() => {
                progressDiv.classList.remove('show');
            }, 5000);
            
        } else if (status === 'processing') {
            const percentage = Math.round((current / total) * 100);
            progressText.textContent = `Criando imagens - Prompt ${current}/${total}`;
            progressFill.style.width = `${percentage}%`;
            progressFill.textContent = `${percentage}%`;
            
            if (details) {
                progressDetails.textContent = details;
            }
            
            if (imagesGenerated !== undefined) {
                progressDetails.textContent = `${imagesGenerated} imagem(ns) criada(s) e baixada(s)`;
            }
            
        } else if (status === 'waiting') {
            const percentage = Math.round((current / total) * 100);
            progressText.textContent = `Aguardando... (${current}/${total})`;
            progressFill.style.width = `${percentage}%`;
            progressFill.textContent = `${percentage}%`;
            progressDetails.textContent = details || '';
        } else if (status === 'stopped') {
            isAutomationRunning = false;
            progressText.textContent = '⏹ Automação interrompida';
            progressDetails.textContent = `Parado no prompt ${current}/${total}`;
            showStatus('Automação interrompida pelo usuário', 'error');
            resetButton();
        }
    }

    // Função para resetar o botão
    function resetButton() {
        isAutomationRunning = false;
        startButton.disabled = false;
        startButton.textContent = 'Iniciar Download';
        
        clearButton.textContent = 'Limpar';
        clearButton.classList.remove('stop-mode');
    }

    // Função para mostrar status
    function showStatus(message, type) {
        statusDiv.textContent = message;
        statusDiv.className = type;
        statusDiv.style.display = 'block';
        
        if (type === 'success' || type === 'error') {
            setTimeout(() => {
                if (type !== 'processing') {
                    statusDiv.style.display = 'none';
                }
            }, 3000);
        }
    }
});
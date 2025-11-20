// background.js - Auto Meta Image

chrome.runtime.onInstalled.addListener(() => {
    console.log('[AutoMetaImage-DL] Extensão instalada com sucesso!');
});

chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.action === "keepAliveDownload") {
        sendResponse({ status: "alive" });
    }
    
    if (request.action === "updateImageProgress") {
        chrome.storage.local.set({ 
            currentProgress: request.data,
            automationInProgress: request.data.status !== 'completed'
        });
        
        chrome.runtime.sendMessage(request).catch(() => {
            console.log('[AutoMetaImage-DL] Progresso salvo (popup fechado)');
        });
    }
    
    return true;
});
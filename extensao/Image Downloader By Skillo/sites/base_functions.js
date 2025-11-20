// base_functions.js - Funções compartilhadas entre todos os sites

class ImageDownloaderBase {
    constructor(siteName) {
        this.siteName = siteName;
        this.processedImages = new Set();
        this.isInitialized = false;
        this.shouldStop = false;
        this.MAX_HISTORY = 10;
        
        console.log(`[${this.siteName}] Content script carregado!`);
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    scrollToTop() {
        console.log(`[${this.siteName}] Rolando para o topo...`);
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    }

    async initializeImageHistory(selector) {
        if (!this.isInitialized) {
            console.log(`[${this.siteName}] Inicializando histórico de imagens...`);
            await this.sleep(2000);
            
            this.scrollToTop();
            await this.sleep(2000);
            
            const existingImages = document.querySelectorAll(selector);
            console.log(`[${this.siteName}] Encontradas ${existingImages.length} imagens existentes`);
            
            const imagesToAdd = Math.min(existingImages.length, this.MAX_HISTORY);
            
            for (let i = 0; i < imagesToAdd; i++) {
                const imgSrc = existingImages[i].src;
                this.processedImages.add(imgSrc);
            }
            
            console.log(`[${this.siteName}] Histórico inicializado com ${this.processedImages.size} imagens`);
            this.isInitialized = true;
            
            chrome.storage.local.set({ 
                [`${this.siteName}_processedImages`]: Array.from(this.processedImages),
                [`${this.siteName}_isInitialized`]: true
            });
        }
    }

    updateProcessedImagesHistory(newImageUrl) {
        this.processedImages.add(newImageUrl);
        
        if (this.processedImages.size > this.MAX_HISTORY) {
            const imagesArray = Array.from(this.processedImages);
            this.processedImages.delete(imagesArray[0]);
        }
        
        console.log(`[${this.siteName}] Histórico atualizado: ${this.processedImages.size} imagens`);
    }

    async downloadImages(imagesToProcess, prompt) {
        console.log(`[${this.siteName}] >>> Baixando ${imagesToProcess.length} imagem(ns)...`);
        
        if (this.shouldStop) return 0;
        
        this.scrollToTop();
        await this.sleep(2000);

        let downloadedCount = 0;
        const timestamp = new Date().getTime();
        const cleanPrompt = prompt.substring(0, 30).replace(/[^a-z0-9]/gi, '_');

        for (let j = 0; j < imagesToProcess.length; j++) {
            if (this.shouldStop) break;
            
            const img = imagesToProcess[j];
            const imgSrc = img.src;
            
            console.log(`[${this.siteName}] >>> Baixando ${j + 1}/${imagesToProcess.length}`);
            
            try {
                const response = await fetch(imgSrc);
                const blob = await response.blob();
                
                const url = window.URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.style.display = 'none';
                a.href = url;
                a.download = `${this.siteName.toLowerCase()}_${cleanPrompt}_${timestamp}_${j + 1}.jpg`;
                
                document.body.appendChild(a);
                a.click();
                
                window.URL.revokeObjectURL(url);
                document.body.removeChild(a);
                
                downloadedCount++;
                this.updateProcessedImagesHistory(imgSrc);
                
                console.log(`[${this.siteName}] ✓ Download ${j + 1} concluído!`);
                
                if (j < imagesToProcess.length - 1) {
                    await this.sleep(2000);
                }
                
            } catch (error) {
                console.error(`[${this.siteName}] ✗ Erro no download ${j + 1}:`, error);
            }
        }

        console.log(`[${this.siteName}] ✓ Concluído: ${downloadedCount}/${imagesToProcess.length} baixadas`);
        
        chrome.storage.local.set({ 
            [`${this.siteName}_processedImages`]: Array.from(this.processedImages)
        });

        return downloadedCount;
    }

    sendProgressUpdate(data) {
        chrome.runtime.sendMessage({
            action: "updateImageProgress",
            data: data
        }).catch(() => {
            console.log(`[${this.siteName}] Progresso salvo (popup fechado)`);
        });
    }

    showNotification(message) {
        const notice = document.createElement('div');
        notice.style.cssText = `
            position: fixed;
            bottom: 20px;
            right: 20px;
            padding: 15px 20px;
            background: rgba(0, 0, 0, 0.85);
            color: white;
            border-radius: 8px;
            z-index: 999999;
            font-family: Arial, sans-serif;
            font-size: 14px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
            border-left: 4px solid #FF0000;
        `;
        notice.textContent = `✅ ${message}`;
        document.body.appendChild(notice);

        setTimeout(() => {
            notice.style.opacity = '0';
            notice.style.transition = 'opacity 1s ease-out';
            setTimeout(() => notice.remove(), 1000);
        }, 3000);
    }
}

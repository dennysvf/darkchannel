# 🔧 Troubleshooting - Resolução de Problemas

Guia completo para resolver problemas comuns da extensão.

## 🚨 Problemas Comuns

### 1. Extensão Não Aparece na Barra de Ferramentas

**Sintomas:**
- Ícone da extensão não aparece após instalação

**Soluções:**
```
✅ Verificar se o "Modo desenvolvedor" está ativo
   1. Abra chrome://extensions/
   2. Ative a chave no canto superior direito

✅ Recarregar a extensão
   1. Em chrome://extensions/
   2. Clique no ícone de reload na extensão

✅ Fixar extensão na barra
   1. Clique no ícone de puzzle 🧩
   2. Encontre "Multi-Site Image Downloader"
   3. Clique no ícone de pin 📌
```

---

### 2. Botão "Iniciar Download" Está Desabilitado

**Sintomas:**
- Botão cinza e não clicável

**Causas e Soluções:**

#### Causa 1: Site Não Suportado
```
❌ Você não está em um dos sites suportados

✅ Solução: Abra um destes sites:
   - https://www.meta.ai/
   - https://aitestkitchen.withgoogle.com/tools/image-fx
   - https://labs.google/fx/tools/whisk
   - https://piclumen.com/
```

#### Causa 2: Página Não Carregada
```
❌ A página ainda está carregando

✅ Solução: Aguarde a página carregar completamente
```

#### Causa 3: Extensão Não Injetada
```
❌ Content script não foi injetado

✅ Solução: Recarregue a página (F5 ou Ctrl+R)
```

---

### 3. Nenhuma Imagem É Baixada

**Sintomas:**
- Automação roda mas nenhum arquivo é baixado

**Diagnóstico:**
```javascript
// Abra o Console (F12) e execute:
chrome.storage.local.get(null, (data) => console.log(data));
```

**Soluções:**

#### Solução 1: Permitir Downloads Múltiplos
```
1. Quando aparecer notificação do Chrome
2. Clique em "Permitir"
3. Ou configure manualmente:
   - Abra chrome://settings/content/automaticDownloads
   - Adicione o site à lista de permissões
```

#### Solução 2: Verificar Bloqueador de Pop-ups
```
1. Clique no ícone de bloqueio 🔒 na barra de endereço
2. Permita pop-ups e redirecionamentos
3. Recarregue a página
```

#### Solução 3: CORS/Proteção de Download
```
❌ Alguns sites têm proteção CORS

✅ Tente:
   1. Abrir a imagem em nova aba
   2. Clicar com botão direito → Salvar imagem
   3. Se não funcionar, o site bloqueia downloads programáticos
```

---

### 4. Imagens Baixadas Estão Corrompidas

**Sintomas:**
- Arquivos baixados não abrem ou aparecem quebrados

**Soluções:**

#### Verificar Formato
```javascript
// No console do DevTools:
const img = document.querySelector('img[src*="generated"]');
console.log('Tipo:', img.src.split(',')[0]);
```

#### Ajustar Download
```javascript
// Se necessário, modificar em content_*.js:
const blob = await response.blob();
const url = window.URL.createObjectURL(blob);

// Trocar extensão se necessário:
a.download = `imagem_${timestamp}.png`;  // ou .jpg, .webp
```

---

### 5. Automação Para no Meio

**Sintomas:**
- Automação inicia mas para antes de terminar

**Causas e Soluções:**

#### Causa 1: Timeout Curto
```javascript
// Aumentar tempo de espera em content_*.js:

const maxWaitTime = 60000;  // Era 45000
const checkInterval = 5000;  // Era 3000
```

#### Causa 2: Elemento Não Encontrado
```
✅ Verificar no Console:
   - Procure por "[NomeSite] ✗ não encontrado"
   - O seletor CSS pode ter mudado no site
```

#### Causa 3: Site Mudou Layout
```
✅ Atualizar seletores:
   1. Abra DevTools (F12)
   2. Use a ferramenta de seleção (Ctrl+Shift+C)
   3. Clique no elemento
   4. Copie o seletor CSS
   5. Atualize em content_*.js
```

---

### 6. Barra de Progresso Não Atualiza

**Sintomas:**
- Barra fica em 0% ou não se move

**Soluções:**

#### Verificar Comunicação
```javascript
// No console do popup (clique com direito na extensão → Inspecionar popup):
chrome.runtime.onMessage.addListener((msg) => {
    console.log('Mensagem recebida:', msg);
});
```

#### Reabrir Popup
```
1. Feche o popup da extensão
2. Aguarde 2 segundos
3. Abra novamente
```

---

### 7. Baixa Imagens Antigas/Duplicadas

**Sintomas:**
- Baixa imagens de prompts anteriores

**Soluções:**

#### Limpar Histórico
```javascript
// Execute no Console:
chrome.storage.local.clear();
location.reload();
```

#### Ajustar Filtro de Duplicatas
```javascript
// Em content_*.js, melhorar filtro:
newImagesFound = Array.from(allImages).filter(img => 
    !processedImages.has(img.src) &&
    img.src &&
    img.complete &&
    img.naturalWidth > 200 &&
    img.naturalHeight > 200 &&
    // Adicionar timestamp check:
    new Date(img.src.match(/\d{13}/)?.[0]) > Date.now() - 60000
);
```

---

### 8. Site Específico Não Funciona

#### Meta AI
```
⚠️ Problemas Conhecidos:
   - Pode demorar para carregar prompts longos
   - Vídeos: extensão aguarda mas não baixa

✅ Soluções:
   - Use prompts mais curtos (<200 caracteres)
   - Para vídeos: baixe manualmente após geração
```

#### ImageFX
```
⚠️ Problemas Conhecidos:
   - Requer login com conta Google
   - Pode ter limite de gerações diárias

✅ Soluções:
   - Faça login antes de usar extensão
   - Verifique se não atingiu limite do site
```

#### Whisk
```
⚠️ Problemas Conhecidos:
   - Geração pode ser mais lenta
   - Às vezes gera menos de 4 imagens

✅ Soluções:
   - Aumente maxWaitTime para 90000
   - Aceite menos imagens por prompt
```

#### Piclumen
```
⚠️ Problemas Conhecidos:
   - Formato de URL pode variar
   - Pode usar blob URLs

✅ Soluções:
   - Adicione 'img[src*="blob:"]' aos seletores
   - Aguarde 5s extras após geração
```

---

## 🔍 Ferramentas de Debug

### 1. Console do Content Script
```javascript
// Verificar se script está rodando:
console.log('[Debug] Content script ativo');

// Ver imagens detectadas:
console.log('[Debug] Imagens:', 
    document.querySelectorAll('img').length
);

// Ver histórico:
chrome.storage.local.get(null, console.log);
```

### 2. Console do Popup
```
1. Clique com botão direito no ícone da extensão
2. Selecione "Inspecionar popup"
3. Vá para aba Console
4. Veja logs e erros
```

### 3. Monitorar Mensagens
```javascript
// Adicione temporariamente em content_*.js:
chrome.runtime.onMessage.addListener((msg, sender, sendResponse) => {
    console.log('[DEBUG] Mensagem recebida:', msg);
    console.log('[DEBUG] Sender:', sender);
    // ... resto do código
});
```

### 4. Verificar Permissões
```javascript
// No console:
chrome.permissions.getAll((perms) => {
    console.log('Permissões:', perms);
});
```

---

## 📊 Logs Importantes

### Logs Normais (Funcionando)
```
[SiteNome] Content script carregado!
[SiteNome] Página carregada!
[SiteNome] ✓ Caixa de texto encontrada
[SiteNome] ✓ Botão encontrado, clicando...
[SiteNome] Check 3s: 4 imagens encontradas
[SiteNome] 4 nova(s) imagem(ns) detectada(s)
[SiteNome] >>> Baixando 4 imagem(ns)...
[SiteNome] ✓ Download 1 concluído!
```

### Logs de Erro (Problemas)
```
[SiteNome] ✗ Caixa de texto não encontrada!
[SiteNome] ✗ Botão de gerar não encontrado!
[SiteNome] ⚠ Nenhuma imagem nova gerada
[SiteNome] ✗ Erro no download: NetworkError
```

---

## 🛠️ Correções Avançadas

### Reset Completo da Extensão
```javascript
// 1. Limpar storage
chrome.storage.local.clear();

// 2. Remover extensão
// chrome://extensions/ → Remover

// 3. Fechar Chrome completamente

// 4. Reabrir e reinstalar extensão
```

### Verificar Conflitos com Outras Extensões
```
1. Desabilite outras extensões temporariamente
2. Teste se funciona
3. Reative uma por uma para identificar conflito
```

### Modo Incógnito
```
Testar em modo anônimo:
1. Ctrl+Shift+N
2. Vá para chrome://extensions/
3. Ative "Permitir no modo anônimo" na extensão
4. Teste a automação
```

---

## 📞 Ainda Com Problemas?

### Informações para Reportar
Quando reportar um problema, inclua:

```
1. Site que estava usando: [Meta AI / ImageFX / Whisk / Piclumen]
2. Navegador e versão: [Chrome 120.0.0.0]
3. Sistema operacional: [Windows 10 / macOS / Linux]
4. O que aconteceu: [Descrição detalhada]
5. O que era esperado: [Comportamento correto]
6. Logs do console: [Copie os logs relevantes]
7. Screenshot: [Se possível]
```

### Onde Reportar
- **Canal CLTube:** [YouTube](https://www.youtube.com/@cltube-canaisdark)
- **Grupo WhatsApp:** [Entrar](https://chat.whatsapp.com/HHbb9e4QuKPGNdwKgOiz86)

---

## 📚 Recursos Úteis

### Links de Referência
- [Chrome Extension APIs](https://developer.chrome.com/docs/extensions/reference/)
- [DevTools Guide](https://developer.chrome.com/docs/devtools/)
- [JavaScript Fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API)

### Comandos Úteis do Chrome
```
chrome://extensions/          → Gerenciar extensões
chrome://downloads/           → Ver downloads
chrome://settings/content/    → Configurações de conteúdo
chrome://inspect/#extensions  → Inspecionar extensões
```

---

**Última atualização:** 2024  
**Contribua:** Se encontrar novos problemas e soluções, por favor reporte!

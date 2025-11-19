# 📥 Guia Rápido: Importar Workflow SSML + OpenVoice

## Passo 1: Acessar N8N
```
http://localhost:5678
```

## Passo 2: Importar Workflow
1. Clique no menu (☰) no canto superior esquerdo
2. Clique em **"Import from File"**
3. Selecione: `workflows/ssml-openvoice-audiobook.json`
4. Clique em **"Import"**

## Passo 3: Ativar Workflow
1. Abra o workflow importado
2. Clique no botão **"Active"** no canto superior direito
3. Aguarde confirmação

## Passo 4: Testar
```powershell
curl -X POST http://localhost:5678/webhook/audiobook `
  -H "Content-Type: application/json" `
  -d '{"text": "Olá mundo", "chapter_title": "Teste"}'
```

✅ Pronto! O webhook estará disponível em:
`http://localhost:5678/webhook/audiobook`

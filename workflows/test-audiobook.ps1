# Script de teste para o workflow SSML + OpenVoice (PowerShell)
# Autor: DarkChannel Stack
# Data: 2025-11-09

Write-Host "`n🎙️ Testando Workflow: SSML + OpenVoice" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# URL do webhook N8N
$WebhookUrl = "http://localhost:5678/webhook/audiobook"

# Teste 1: Audiolivro Simples
Write-Host "📖 TESTE 1: Audiolivro Simples" -ForegroundColor Yellow
Write-Host "------------------------------" -ForegroundColor Yellow
$body1 = @{
    text = "Era uma vez, em um reino distante, um jovem príncipe chamado Pedro. Ele era muito corajoso e destemido."
    chapter_title = "Capítulo 1: O Príncipe Corajoso"
} | ConvertTo-Json

Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $body1 -ContentType "application/json" | ConvertTo-Json -Depth 10
Write-Host ""

# Teste 2: Com SSML Avançado
Write-Host "🎭 TESTE 2: SSML Avançado (Prosódia)" -ForegroundColor Yellow
Write-Host "------------------------------------" -ForegroundColor Yellow
$body2 = @{
    text = '<prosody rate="slow" pitch="-2">Era uma vez, em um reino distante,</prosody><break time="1s"/>um jovem príncipe chamado <phoneme alphabet="ipa" ph="ˈpedɾu">Pedro</phoneme>.<break time="1.5s"/><prosody rate="fast" pitch="+1">Ele era muito corajoso!</prosody>'
    chapter_title = "Capítulo 1: O Início"
} | ConvertTo-Json

Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $body2 -ContentType "application/json" | ConvertTo-Json -Depth 10
Write-Host ""

# Teste 3: Diálogo
Write-Host "💬 TESTE 3: Diálogo Dramatizado" -ForegroundColor Yellow
Write-Host "-------------------------------" -ForegroundColor Yellow
$body3 = @{
    text = '<prosody rate="0.9">João olhou para Maria e disse:</prosody><break time="0.5s"/><prosody rate="slow" pitch="-2">"Precisamos conversar sobre o que aconteceu."</prosody><break time="1s"/><prosody rate="1.1" pitch="+1">"Eu sei", Maria respondeu nervosamente.</prosody>'
    chapter_title = "Capítulo 5: A Conversa"
} | ConvertTo-Json

Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $body3 -ContentType "application/json" | ConvertTo-Json -Depth 10
Write-Host ""

# Teste 4: Narração de Notícias
Write-Host "📰 TESTE 4: Narração de Notícias" -ForegroundColor Yellow
Write-Host "--------------------------------" -ForegroundColor Yellow
$body4 = @{
    text = '<prosody rate="1.1">Bom dia! Estas são as principais notícias de hoje.</prosody><break time="1s"/><prosody rate="1.0">Primeira notícia: O mercado financeiro apresentou alta de 2% hoje.</prosody><break time="0.5s"/><prosody rate="1.0">Segunda notícia: Previsão do tempo indica chuvas para o fim de semana.</prosody>'
    chapter_title = "Notícias - 09/11/2025"
} | ConvertTo-Json

Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $body4 -ContentType "application/json" | ConvertTo-Json -Depth 10
Write-Host ""

# Teste 5: Audiolivro Complexo
Write-Host "📚 TESTE 5: Audiolivro Complexo (Múltiplas Emoções)" -ForegroundColor Yellow
Write-Host "---------------------------------------------------" -ForegroundColor Yellow
$body5 = @{
    text = '<prosody rate="0.9">Capítulo Três: A Descoberta</prosody><break time="2.5s"/><prosody rate="slow" pitch="-1">A noite estava escura e silenciosa.</prosody><break time="1s"/>Pedro caminhava pelas ruas desertas, quando de repente...<break time="1.5s"/><prosody rate="fast" pitch="+2"><emphasis level="strong">Um grito ecoou pela cidade!</emphasis></prosody><break time="2s"/><prosody rate="0.8" pitch="-2">"O que foi aquilo?", ele pensou, com o coração acelerado.</prosody>'
    chapter_title = "Capítulo 3: A Descoberta"
} | ConvertTo-Json

Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $body5 -ContentType "application/json" | ConvertTo-Json -Depth 10
Write-Host ""

Write-Host "✅ Todos os testes concluídos!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Resumo:" -ForegroundColor Cyan
Write-Host "  - 5 testes executados"
Write-Host "  - Verifique os logs do N8N para detalhes"
Write-Host "  - Áudios gerados em: /tmp/audiobook_*.mp3"
Write-Host ""

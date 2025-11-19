# Teste do Webhook do Workflow SSML + OpenVoice
Write-Host "`n🧪 TESTANDO WORKFLOW NO N8N`n" -ForegroundColor Cyan

# Preparar payload
$body = @{
    text = "Era uma vez um príncipe corajoso."
    chapter_title = "Capítulo 1"
} | ConvertTo-Json

Write-Host "📤 Enviando para webhook..." -ForegroundColor Yellow
Write-Host "URL: http://localhost:5678/webhook/audiobook" -ForegroundColor Gray
Write-Host "Payload:" -ForegroundColor Gray
Write-Host $body -ForegroundColor DarkGray
Write-Host ""

try {
    $result = Invoke-RestMethod -Uri "http://localhost:5678/webhook/audiobook" `
        -Method Post `
        -Body $body `
        -ContentType "application/json" `
        -ErrorAction Stop
    
    Write-Host "✅ SUCESSO!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 Resposta:" -ForegroundColor Cyan
    Write-Host ($result | ConvertTo-Json -Depth 5) -ForegroundColor White
    Write-Host ""
    
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $errorBody = $_.ErrorDetails.Message
    
    Write-Host "❌ ERRO!" -ForegroundColor Red
    Write-Host "Status Code: $statusCode" -ForegroundColor Yellow
    
    if ($errorBody) {
        Write-Host "Detalhes do erro:" -ForegroundColor Yellow
        try {
            $errorJson = $errorBody | ConvertFrom-Json
            Write-Host ($errorJson | ConvertTo-Json -Depth 10) -ForegroundColor Red
        } catch {
            Write-Host $errorBody -ForegroundColor Red
        }
    } else {
        Write-Host "Mensagem: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "💡 Possíveis causas:" -ForegroundColor Yellow
    Write-Host "   1. Workflow não está ativo no N8N" -ForegroundColor Gray
    Write-Host "   2. Webhook path incorreto" -ForegroundColor Gray
    Write-Host "   3. Erro no código do workflow" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📋 Verifique:" -ForegroundColor Yellow
    Write-Host "   - N8N: http://localhost:5678" -ForegroundColor Gray
    Write-Host "   - Workflow importado: ssml-openvoice-fixed.json" -ForegroundColor Gray
    Write-Host "   - Workflow ativo (botão Active)" -ForegroundColor Gray
}

Write-Host ""

Write-Host "`nTestando Workflow N8N`n" -ForegroundColor Cyan

$body = @{
    text = "Era uma vez um principe corajoso."
    chapter_title = "Capitulo 1"
} | ConvertTo-Json

Write-Host "Enviando para: http://localhost:5678/webhook/audiobook"
Write-Host ""

try {
    $result = Invoke-RestMethod -Uri "http://localhost:5678/webhook/audiobook" -Method Post -Body $body -ContentType "application/json"
    Write-Host "SUCESSO!" -ForegroundColor Green
    Write-Host ($result | ConvertTo-Json -Depth 5)
} catch {
    Write-Host "ERRO!" -ForegroundColor Red
    Write-Host $_.Exception.Message
    if ($_.ErrorDetails.Message) {
        Write-Host $_.ErrorDetails.Message
    }
}

Write-Host ""

# Download OpenVoice V2 Models

Write-Host "`n📥 Baixando modelos OpenVoice V2...`n" -ForegroundColor Cyan
Write-Host "⚠️  Isso pode demorar alguns minutos (~2GB)`n" -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod `
        -Uri "http://localhost:8000/download-models" `
        -Method POST `
        -Body '{"version":"v2"}' `
        -ContentType "application/json" `
        -TimeoutSec 600
    
    Write-Host "`n✅ Modelos baixados com sucesso!`n" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 5 | Write-Host
    
} catch {
    Write-Host "`n❌ Erro ao baixar modelos!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "`nDetalhes: $responseBody" -ForegroundColor Yellow
    }
}

Write-Host ""

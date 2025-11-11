# Test script para Kokoro /tts-to-s3

Write-Host "`n🧪 Testando Kokoro /tts-to-s3`n" -ForegroundColor Cyan

$jobId = [guid]::NewGuid().ToString()

Write-Host "Job ID: $jobId`n" -ForegroundColor Yellow

$body = @{
    text = "Olá! Este é um teste do Kokoro com MinIO."
    job_id = $jobId
    chunk_index = 0
    voice = "af_sarah"
    speed = 1.0
    lang = "pt-br"
} | ConvertTo-Json

Write-Host "Enviando requisição...`n" -ForegroundColor Gray

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8881/tts-to-s3" `
        -Method POST `
        -Body $body `
        -ContentType "application/json"
    
    Write-Host "✅ Sucesso!`n" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 5 | Write-Host
    
    Write-Host "`n📦 Verificar no MinIO:" -ForegroundColor Yellow
    Write-Host "  URL: http://localhost:9001" -ForegroundColor Gray
    Write-Host "  Bucket: $($response.bucket)" -ForegroundColor Gray
    Write-Host "  Key: $($response.s3_key)" -ForegroundColor Gray
    
    if ($response.download_url) {
        Write-Host "`n🔗 Link Direto (válido por 1 hora):" -ForegroundColor Cyan
        Write-Host $response.download_url -ForegroundColor White
    }
    
    Write-Host "`n🎵 Este arquivo TEM áudio real (voz Kokoro)!" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Erro!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""

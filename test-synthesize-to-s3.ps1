# Test script para /synthesize-to-s3

Write-Host "`n🧪 Testando OpenVoice /synthesize-to-s3`n" -ForegroundColor Cyan

$jobId = [guid]::NewGuid().ToString()

Write-Host "Job ID: $jobId`n" -ForegroundColor Yellow

$body = @{
    text = "Agora temos voz de referência! VocÊ tem dúvidas?"
    job_id = $jobId
    chunk_index = 0
    language = "pt-BR"
    speed = 1.0
    pitch = 0
} | ConvertTo-Json

Write-Host "Enviando requisição...`n" -ForegroundColor Gray

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8000/synthesize-to-s3" `
        -Method POST `
        -Body $body `
        -ContentType "application/json"
    
    Write-Host "`n✅ Sucesso!`n" -ForegroundColor Green
    
    Write-Host "📄 Response:" -ForegroundColor Cyan
    Write-Host "  Success: $($response.success)" -ForegroundColor Gray
    Write-Host "  Job ID: $($response.job_id)" -ForegroundColor Gray
    Write-Host "  Bucket: $($response.bucket)" -ForegroundColor Gray
    Write-Host "  S3 Key: $($response.s3_key)" -ForegroundColor Gray
    Write-Host "  Chunk Index: $($response.chunk_index)" -ForegroundColor Gray
    
    if ($response.download_url) {
        Write-Host "`n🔗 Download URL (válida por $($response.download_expires_in)s):" -ForegroundColor Yellow
        Write-Host "  $($response.download_url)`n" -ForegroundColor Green
        
        Write-Host "💡 Copie e cole no navegador para baixar o áudio!`n" -ForegroundColor Cyan
    }
    
    Write-Host "📦 Verificar no MinIO UI:" -ForegroundColor Yellow
    Write-Host "  URL: http://localhost:9001" -ForegroundColor Gray
    Write-Host "  Bucket: $($response.bucket)" -ForegroundColor Gray
    Write-Host "  Key: $($response.s3_key)" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Erro!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""

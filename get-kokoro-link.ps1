# Gerar link de download do último teste

param(
    [string]$JobId = "90d88170-d653-4ab1-995a-19d9f4c4f8fd",
    [int]$ChunkIndex = 0
)

Write-Host "`n🔗 Gerando link de download...`n" -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8881/download-url/$JobId/$ChunkIndex"
    
    Write-Host "✅ Link gerado!`n" -ForegroundColor Green
    
    Write-Host "📊 Informações:" -ForegroundColor Yellow
    Write-Host "  Job ID: $($response.job_id)" -ForegroundColor Gray
    Write-Host "  Chunk: $($response.chunk_index)" -ForegroundColor Gray
    Write-Host "  Expira em: $($response.expires_in) segundos (1 hora)`n" -ForegroundColor Gray
    
    Write-Host "🔗 Link de Download (válido por 1 hora):`n" -ForegroundColor Cyan
    Write-Host $response.download_url -ForegroundColor White
    
    Write-Host "`n💡 Copie e cole no navegador para baixar!`n" -ForegroundColor Yellow
    
} catch {
    Write-Host "❌ Erro: $_" -ForegroundColor Red
}

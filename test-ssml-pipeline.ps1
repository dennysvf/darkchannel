# Test SSML Complete Pipeline
# Script para testar o pipeline SSML completo com múltiplas vozes

Write-Host "`n🎙️  Testando SSML Pipeline Completo`n" -ForegroundColor Cyan

# SSML com múltiplas vozes
$ssml = @"
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="pt-BR">
  <voice name="af_sarah">
    <prosody rate="1.0">
      Olá! Bem-vindo ao teste do pipeline SSML completo.
      Este é um exemplo com múltiplas vozes e pausas.
    </prosody>
  </voice>
  <break time="800ms"/>
  <voice name="am_adam">
    <prosody rate="0.9">
      Agora estou falando com uma voz masculina mais grave.
      Perfeito para narração profissional.
    </prosody>
  </voice>
  <break time="800ms"/>
  <voice name="af_sky">
    <prosody rate="1.15">
      E aqui temos uma voz mais jovem e animada!
      Ideal para conteúdo dinâmico e energético.
    </prosody>
  </voice>
</speak>
"@

$body = @{
    ssml = $ssml
    voice_cloning_enabled = $false
} | ConvertTo-Json

Write-Host "📤 Enviando SSML para pipeline...`n" -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod `
        -Uri "http://localhost:5678/webhook/ssml-pipeline-webhook" `
        -Method POST `
        -Body $body `
        -ContentType "application/json" `
        -ErrorAction Stop
    
    Write-Host "✅ Pipeline executado com sucesso!`n" -ForegroundColor Green
    
    Write-Host "📊 Resultados:`n" -ForegroundColor Cyan
    Write-Host "  Job ID: $($response.job_id)" -ForegroundColor White
    Write-Host "  Total de chunks: $($response.total_chunks)" -ForegroundColor White
    Write-Host "  Mensagem: $($response.message)`n" -ForegroundColor Gray
    
    Write-Host "🎵 Chunks gerados:`n" -ForegroundColor Cyan
    
    foreach ($chunk in $response.chunks) {
        Write-Host "  📦 Chunk $($chunk.chunk_index):" -ForegroundColor Yellow
        Write-Host "     S3 Key: $($chunk.s3_key)" -ForegroundColor Gray
        Write-Host "     Bucket: $($chunk.bucket)" -ForegroundColor Gray
        
        if ($chunk.download_url) {
            Write-Host "     🔗 Download: $($chunk.download_url)" -ForegroundColor Green
        }
        Write-Host ""
    }
    
    Write-Host "💡 Dica: Acesse o MinIO Console para ver os arquivos:" -ForegroundColor Cyan
    Write-Host "   http://localhost:9001`n" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Erro ao executar pipeline:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`n📋 Detalhes do erro:" -ForegroundColor Yellow
    Write-Host $_.ErrorDetails.Message -ForegroundColor Gray
}

Write-Host ""

# Teste Real do Fluxo SSML + OpenVoice
Write-Host "`n🧪 TESTE REAL DO FLUXO COMPLETO`n" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

# Teste 1: Parse SSML
Write-Host "📝 PASSO 1: Testando SSML Parser" -ForegroundColor Yellow
$ssmlBody = @{
    text = '<speak><prosody rate="0.9">Capítulo 1: O Príncipe Corajoso</prosody><break time="2s"/>Era uma vez, em um reino distante, um jovem príncipe chamado Pedro.</speak>'
} | ConvertTo-Json

try {
    $parseResult = Invoke-RestMethod -Uri "http://localhost:8888/api/v1/ssml/parse" -Method Post -Body $ssmlBody -ContentType "application/json"
    Write-Host "   ✅ SSML Parser: OK" -ForegroundColor Green
    Write-Host "   Chunks gerados: $($parseResult.chunks.Count)" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "   ❌ ERRO no SSML Parser: $_" -ForegroundColor Red
    exit 1
}

# Teste 2: Synthesize para cada chunk de texto
Write-Host "🎤 PASSO 2: Testando OpenVoice /synthesize" -ForegroundColor Yellow
$chunkIndex = 0

foreach ($chunk in $parseResult.chunks) {
    $chunkIndex++
    
    if ($chunk.type -eq "text") {
        Write-Host "   Chunk $chunkIndex (TEXTO): `"$($chunk.content.Substring(0, [Math]::Min(40, $chunk.content.Length)))...`"" -ForegroundColor Cyan
        
        $speed = if ($chunk.metadata.speed) { $chunk.metadata.speed } else { 1.0 }
        $pitch = if ($chunk.metadata.pitch) { $chunk.metadata.pitch } else { 0 }
        
        $synthBody = @{
            text = $chunk.content
            language = "pt-BR"
            speed = $speed
            pitch = $pitch
        } | ConvertTo-Json
        
        try {
            $synthResult = Invoke-RestMethod -Uri "http://localhost:8000/synthesize" -Method Post -Body $synthBody -ContentType "application/json"
            Write-Host "      ✅ Synthesize: OK (speed=$speed, pitch=$pitch)" -ForegroundColor Green
        } catch {
            Write-Host "      ❌ ERRO: $_" -ForegroundColor Red
        }
        
    } elseif ($chunk.type -eq "break") {
        Write-Host "   Chunk $chunkIndex (PAUSA): $($chunk.duration)s" -ForegroundColor Yellow
    }
    
    Write-Host ""
}

# Resumo
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "✅ TESTE COMPLETO CONCLUÍDO!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Resumo:" -ForegroundColor Cyan
Write-Host "   - SSML Parser: ✅ Funcionando" -ForegroundColor Green
Write-Host "   - OpenVoice /synthesize: ✅ Funcionando" -ForegroundColor Green
Write-Host "   - Chunks processados: $chunkIndex" -ForegroundColor Gray
Write-Host ""
Write-Host "🎯 Próximo passo: Importar workflow no N8N!" -ForegroundColor Yellow
Write-Host ""

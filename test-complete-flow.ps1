# Teste Completo do Fluxo SSML + OpenVoice (Simulação)
# Este script simula o que o workflow N8N faria

Write-Host "`n🎙️ SIMULAÇÃO DO FLUXO COMPLETO: SSML + OpenVoice`n" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

# Entrada do usuário (simulando webhook)
$input_text = "Era uma vez, em um reino distante, um jovem príncipe chamado Pedro. Ele era muito corajoso e destemido."
$chapter_title = "Capítulo 1: O Príncipe Corajoso"

Write-Host "📥 ENTRADA:" -ForegroundColor Yellow
Write-Host "   Texto: $input_text"
Write-Host "   Capítulo: $chapter_title"
Write-Host ""

# Passo 1: Preparar SSML
Write-Host "🔧 PASSO 1: Preparar SSML" -ForegroundColor Green
$ssml = "<speak><prosody rate=`"0.9`">$chapter_title</prosody><break time=`"2s`"/>$input_text</speak>"
Write-Host "   SSML gerado: $($ssml.Substring(0, 80))..." -ForegroundColor Gray
Write-Host ""

# Passo 2: Parse SSML
Write-Host "🔍 PASSO 2: Parse SSML (Service)" -ForegroundColor Green
$parseBody = @{ text = $ssml } | ConvertTo-Json
$parseResult = Invoke-RestMethod -Uri "http://localhost:8888/api/v1/ssml/parse" -Method Post -Body $parseBody -ContentType "application/json"

Write-Host "   ✅ Chunks gerados: $($parseResult.chunks.Count)" -ForegroundColor Gray
Write-Host "   ✅ Total de pausas: $($parseResult.total_breaks)" -ForegroundColor Gray
Write-Host "   ✅ Duração das pausas: $($parseResult.total_duration)s" -ForegroundColor Gray
Write-Host ""

# Passo 3: Processar cada chunk
Write-Host "⚙️  PASSO 3: Processar Chunks" -ForegroundColor Green
$audioChunks = @()
$chunkIndex = 0

foreach ($chunk in $parseResult.chunks) {
    $chunkIndex++
    
    if ($chunk.type -eq "text") {
        Write-Host "   📝 Chunk $chunkIndex (TEXTO): `"$($chunk.content.Substring(0, [Math]::Min(40, $chunk.content.Length)))...`"" -ForegroundColor Cyan
        
        # Extrair metadados
        $speed = if ($chunk.metadata.speed) { $chunk.metadata.speed } else { 1.0 }
        $pitch = if ($chunk.metadata.pitch) { $chunk.metadata.pitch } else { 0 }
        
        Write-Host "      - Speed: $speed" -ForegroundColor Gray
        Write-Host "      - Pitch: $pitch" -ForegroundColor Gray
        
        # Simular chamada ao OpenVoice (não vamos fazer a chamada real para não gerar áudio agora)
        Write-Host "      🎤 Enviaria para OpenVoice: http://localhost:8000/synthesize" -ForegroundColor Gray
        Write-Host "         Parâmetros: text=`"..`", language=pt-BR, speed=$speed, pitch=$pitch" -ForegroundColor DarkGray
        
        $audioChunks += @{
            index = $chunkIndex
            type = "audio"
            text = $chunk.content
            speed = $speed
            pitch = $pitch
            estimated_duration = [Math]::Round($chunk.content.Length / 15.0, 2)  # ~15 chars/sec
        }
        
    } elseif ($chunk.type -eq "break") {
        Write-Host "   ⏸️  Chunk $chunkIndex (PAUSA): $($chunk.duration)s" -ForegroundColor Yellow
        
        $audioChunks += @{
            index = $chunkIndex
            type = "silence"
            duration = $chunk.duration
        }
    }
    
    Write-Host ""
}

# Passo 4: Resumo
Write-Host "📊 PASSO 4: Resumo do Processamento" -ForegroundColor Green
Write-Host "   Total de chunks: $($audioChunks.Count)" -ForegroundColor Gray
Write-Host "   Chunks de áudio: $($audioChunks | Where-Object { $_.type -eq 'audio' } | Measure-Object | Select-Object -ExpandProperty Count)" -ForegroundColor Gray
Write-Host "   Chunks de silêncio: $($audioChunks | Where-Object { $_.type -eq 'silence' } | Measure-Object | Select-Object -ExpandProperty Count)" -ForegroundColor Gray

$totalDuration = ($audioChunks | ForEach-Object { 
    if ($_.type -eq 'audio') { $_.estimated_duration } else { $_.duration }
} | Measure-Object -Sum).Sum

Write-Host "   Duração estimada total: $([Math]::Round($totalDuration, 2))s" -ForegroundColor Gray
Write-Host ""

# Passo 5: Resultado Final (simulado)
Write-Host "✅ RESULTADO FINAL (Simulado)" -ForegroundColor Green
$result = @{
    success = $true
    chapter_title = $chapter_title
    total_chunks = $audioChunks.Count
    audio_chunks = ($audioChunks | Where-Object { $_.type -eq 'audio' }).Count
    silence_chunks = ($audioChunks | Where-Object { $_.type -eq 'silence' }).Count
    estimated_duration = [Math]::Round($totalDuration, 2)
    message = "Audiolivro processado com sucesso!"
    chunks_detail = $audioChunks
}

Write-Host ($result | ConvertTo-Json -Depth 5)
Write-Host ""

Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "🎉 SIMULAÇÃO CONCLUÍDA COM SUCESSO!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Próximos Passos:" -ForegroundColor Yellow
Write-Host "   1. Importe o workflow no N8N: workflows/ssml-openvoice-audiobook.json"
Write-Host "   2. Ative o workflow no N8N"
Write-Host "   3. Teste com: curl -X POST http://localhost:5678/webhook/audiobook ..."
Write-Host ""

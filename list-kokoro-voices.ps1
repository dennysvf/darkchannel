# List All Kokoro Voices
# Script para listar todas as vozes geradas organizadas

Write-Host "`n📚 Catálogo Completo - Vozes Kokoro`n" -ForegroundColor Cyan

$refDir = "references-kokoro"

if (-not (Test-Path $refDir)) {
    Write-Host "❌ Biblioteca não encontrada!" -ForegroundColor Red
    Write-Host "Execute primeiro: .\generate-all-kokoro-voices.ps1`n" -ForegroundColor Yellow
    exit 1
}

$ages = @("crianca", "jovem", "adulto", "idoso")
$ageEmojis = @{
    "crianca" = "👶"
    "jovem" = "🧑"
    "adulto" = "👤"
    "idoso" = "👴"
}

foreach ($age in $ages) {
    $agePath = "$refDir/$age"
    
    if (-not (Test-Path $agePath)) {
        continue
    }
    
    $emoji = $ageEmojis[$age]
    $ageTitle = $age.ToUpper()
    
    Write-Host "`n$emoji $ageTitle" -ForegroundColor Yellow
    Write-Host ("=" * 80) -ForegroundColor Gray
    
    $voices = Get-ChildItem -Path $agePath -Filter "*.wav" | Sort-Object Name
    
    if ($voices.Count -eq 0) {
        Write-Host "  (Nenhuma voz nesta categoria)`n" -ForegroundColor Gray
        continue
    }
    
    Write-Host ""
    
    foreach ($voice in $voices) {
        # Extrair informações do nome do arquivo
        # Formato: idade_codigo-voz_Nome-Voz.wav
        $parts = $voice.BaseName -split "_"
        
        if ($parts.Count -ge 3) {
            $voiceCode = $parts[1]
            $voiceName = $parts[2] -replace "-", " "
            
            $size = $voice.Length / 1KB
            $duration = "~" + [math]::Round($size / 30, 1) + "s"
            
            # Determinar gênero pelo código
            $genderEmoji = if ($voiceCode -match "^[ab]f") { "👩" } else { "👨" }
            
            Write-Host "  $genderEmoji " -NoNewline -ForegroundColor Cyan
            Write-Host "$voiceName" -NoNewline -ForegroundColor White
            Write-Host " [$voiceCode]" -NoNewline -ForegroundColor Gray
            Write-Host " - $([math]::Round($size, 1)) KB ($duration)" -ForegroundColor DarkGray
        }
    }
}

# Estatísticas gerais
Write-Host "`n`n📊 Estatísticas Gerais" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Gray

$allVoices = Get-ChildItem -Path $refDir -Filter "*.wav" -Recurse
$totalSize = ($allVoices | Measure-Object -Property Length -Sum).Sum / 1MB

Write-Host "`n  Total de arquivos: $($allVoices.Count)" -ForegroundColor Green
Write-Host "  Tamanho total: $([math]::Round($totalSize, 2)) MB" -ForegroundColor Green

# Contar por idade
Write-Host "`n  Distribuição por idade:" -ForegroundColor Yellow
foreach ($age in $ages) {
    $ageFiles = Get-ChildItem -Path "$refDir/$age" -Filter "*.wav" -ErrorAction SilentlyContinue
    if ($ageFiles) {
        $emoji = $ageEmojis[$age]
        Write-Host "    $emoji $age : $($ageFiles.Count) vozes" -ForegroundColor Gray
    }
}

Write-Host "`n💡 Dicas:`n" -ForegroundColor Cyan
Write-Host "  - Vozes 'af_' são femininas americanas" -ForegroundColor Gray
Write-Host "  - Vozes 'am_' são masculinas americanas" -ForegroundColor Gray
Write-Host "  - Vozes 'bf_' são femininas britânicas" -ForegroundColor Gray
Write-Host "  - Vozes 'bm_' são masculinas britânicas" -ForegroundColor Gray
Write-Host "  - Velocidade varia por idade (criança mais rápida, idoso mais lento)`n" -ForegroundColor Gray

Write-Host ""

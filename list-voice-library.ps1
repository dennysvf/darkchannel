# List Voice Library
# Script para listar todas as vozes disponíveis na biblioteca

Write-Host "`n📚 Catálogo de Vozes - Biblioteca Completa`n" -ForegroundColor Cyan

$refDir = "references"

if (-not (Test-Path $refDir)) {
    Write-Host "❌ Biblioteca não encontrada!" -ForegroundColor Red
    Write-Host "Execute primeiro: .\generate-voice-library.ps1`n" -ForegroundColor Yellow
    exit 1
}

$categories = Get-ChildItem -Path $refDir -Directory | Sort-Object Name

foreach ($category in $categories) {
    $categoryName = $category.Name.ToUpper()
    $emoji = switch ($category.Name) {
        "adultos" { "👤" }
        "jovens" { "🧑" }
        "criancas" { "👶" }
        "idosos" { "👴" }
        "personagens" { "🎭" }
        "especiais" { "⭐" }
        default { "🎤" }
    }
    
    Write-Host "`n$emoji $categoryName" -ForegroundColor Yellow
    Write-Host ("=" * 60) -ForegroundColor Gray
    
    $voices = Get-ChildItem -Path $category.FullName -Filter "*.wav" | Sort-Object Name
    
    if ($voices.Count -eq 0) {
        Write-Host "  (Nenhuma voz nesta categoria)`n" -ForegroundColor Gray
        continue
    }
    
    foreach ($voice in $voices) {
        $name = $voice.BaseName
        $size = $voice.Length / 1KB
        $duration = "~" + [math]::Round($size / 30, 1) + "s"  # Estimativa
        
        Write-Host "  🎙️  " -NoNewline -ForegroundColor Cyan
        Write-Host "$name" -NoNewline -ForegroundColor White
        Write-Host " ($([math]::Round($size, 1)) KB, $duration)" -ForegroundColor Gray
    }
    
    Write-Host ""
}

# Estatísticas gerais
Write-Host "`n📊 Estatísticas Gerais`n" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Gray

$allVoices = Get-ChildItem -Path $refDir -Filter "*.wav" -Recurse
$totalSize = ($allVoices | Measure-Object -Property Length -Sum).Sum / 1MB
$totalDuration = [math]::Round($totalSize / 0.03, 0)  # Estimativa em segundos

Write-Host "  Total de vozes: $($allVoices.Count)" -ForegroundColor Green
Write-Host "  Tamanho total: $([math]::Round($totalSize, 2)) MB" -ForegroundColor Green
Write-Host "  Duração estimada: ~$totalDuration segundos (~$([math]::Round($totalDuration/60, 1)) minutos)" -ForegroundColor Green

Write-Host "`n💡 Dicas de Uso:`n" -ForegroundColor Cyan
Write-Host "  - Use vozes de 'adultos' para conteúdo profissional" -ForegroundColor Gray
Write-Host "  - Use vozes de 'jovens' para conteúdo dinâmico" -ForegroundColor Gray
Write-Host "  - Use vozes de 'criancas' para conteúdo infantil" -ForegroundColor Gray
Write-Host "  - Use vozes de 'personagens' para storytelling" -ForegroundColor Gray
Write-Host "  - Use vozes de 'especiais' para casos específicos`n" -ForegroundColor Gray

Write-Host ""

# Download Brazilian Portuguese Voice Samples
# Script para baixar samples de voz em português do Brasil

Write-Host "`n🎤 Download de Samples de Voz - Português do Brasil`n" -ForegroundColor Cyan

# Criar diretórios
$refDir = "references"
$cetucDir = "$refDir/cetuc-samples"

New-Item -ItemType Directory -Force -Path $refDir | Out-Null
New-Item -ItemType Directory -Force -Path $cetucDir | Out-Null

Write-Host "📁 Diretórios criados:`n" -ForegroundColor Green
Write-Host "  - $refDir" -ForegroundColor Gray
Write-Host "  - $cetucDir`n" -ForegroundColor Gray

# Opção 1: Gerar samples com Kokoro (sempre funciona)
Write-Host "🎙️  Opção 1: Gerando samples com Kokoro TTS...`n" -ForegroundColor Yellow

$voices = @{
    "feminina-profissional" = "af_sarah"
    "feminina-suave" = "af_nicole"
    "masculina-grave" = "am_adam"
    "masculina-energica" = "am_michael"
}

$sampleText = @"
Olá! Meu nome é uma voz brasileira de alta qualidade.
Este é um exemplo de como eu falo naturalmente em português do Brasil.
Posso ler textos longos ou curtos, com diferentes emoções e estilos.
Minha pronúncia é clara e natural, perfeita para síntese de voz.
Espero que você goste da minha voz e da qualidade do áudio!
"@

foreach ($name in $voices.Keys) {
    $voice = $voices[$name]
    $outputFile = "$refDir/$name.wav"
    
    Write-Host "  Gerando: $name ($voice)..." -ForegroundColor Gray
    
    try {
        $body = @{
            model = "kokoro"
            input = $sampleText
            voice = $voice
            lang_code = "pt"
            response_format = "wav"
            speed = 1.0
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod `
            -Uri "http://localhost:8880/v1/audio/speech" `
            -Method POST `
            -Body $body `
            -ContentType "application/json" `
            -OutFile $outputFile
        
        $size = (Get-Item $outputFile).Length / 1KB
        Write-Host "    ✅ Salvo: $outputFile ($([math]::Round($size, 2)) KB)" -ForegroundColor Green
        
    } catch {
        Write-Host "    ❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n📊 Resumo:`n" -ForegroundColor Cyan

$files = Get-ChildItem -Path $refDir -Filter "*.wav"
$totalSize = ($files | Measure-Object -Property Length -Sum).Sum / 1MB

Write-Host "  Total de arquivos: $($files.Count)" -ForegroundColor Green
Write-Host "  Tamanho total: $([math]::Round($totalSize, 2)) MB" -ForegroundColor Green

Write-Host "`n📂 Arquivos criados:`n" -ForegroundColor Yellow
$files | ForEach-Object {
    $size = $_.Length / 1KB
    Write-Host "  - $($_.Name) ($([math]::Round($size, 2)) KB)" -ForegroundColor Gray
}

Write-Host "`n💡 Próximos passos:`n" -ForegroundColor Cyan
Write-Host "  1. Copiar para container OpenVoice:" -ForegroundColor White
Write-Host "     docker cp references/ openvoice:/app/references/`n" -ForegroundColor Gray
Write-Host "  2. Testar clonagem de voz:" -ForegroundColor White
Write-Host "     .\test-voice-cloning.ps1`n" -ForegroundColor Gray

Write-Host "✅ Concluído!`n" -ForegroundColor Green

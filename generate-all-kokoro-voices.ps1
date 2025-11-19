# Generate All Kokoro Voices with Age Variations
# Script para gerar TODAS as vozes do Kokoro em diferentes idades

Write-Host "`n🎤 Gerando TODAS as Vozes do Kokoro - Variações de Idade`n" -ForegroundColor Cyan

# Criar estrutura de diretórios
$refDir = "references-kokoro"
$ages = @("crianca", "jovem", "adulto", "idoso")

Write-Host "📁 Criando estrutura...`n" -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $refDir | Out-Null
foreach ($age in $ages) {
    New-Item -ItemType Directory -Force -Path "$refDir/$age" | Out-Null
}

# TODAS as vozes do Kokoro - 13 vozes
$kokoroVoices = @(
    # Femininas Americanas (5)
    @{ code = "af"; name = "Base-Feminina"; gender = "F" },
    @{ code = "af_sarah"; name = "Sarah"; gender = "F" },
    @{ code = "af_nicole"; name = "Nicole"; gender = "F" },
    @{ code = "af_sky"; name = "Sky"; gender = "F" },
    @{ code = "af_bella"; name = "Bella"; gender = "F" },
    
    # Masculinas Americanas (4)
    @{ code = "am"; name = "Base-Masculina"; gender = "M" },
    @{ code = "am_adam"; name = "Adam"; gender = "M" },
    @{ code = "am_michael"; name = "Michael"; gender = "M" },
    @{ code = "am_eric"; name = "Eric"; gender = "M" },
    
    # Femininas Britânicas (2)
    @{ code = "bf"; name = "Base-Feminina-UK"; gender = "F" },
    @{ code = "bf_emma"; name = "Emma-UK"; gender = "F" },
    
    # Masculinas Britânicas (2)
    @{ code = "bm"; name = "Base-Masculina-UK"; gender = "M" },
    @{ code = "bm_george"; name = "George-UK"; gender = "M" }
)

# Configurações de idade (velocidade e texto)
$ageConfigs = @{
    "crianca" = @{
        speed = 1.35
        text = "Oi! Eu adoro brincar e aprender coisas novas! Vamos ser amigos? Eu gosto muito de desenhar e brincar!"
        emoji = "👶"
    }
    "jovem" = @{
        speed = 1.15
        text = "E aí, tudo bem? Eu sou bem animado e gosto de coisas legais! Vamos fazer algo divertido juntos!"
        emoji = "🧑"
    }
    "adulto" = @{
        speed = 1.0
        text = "Olá! Sou uma voz profissional e clara. Perfeito para apresentações, conteúdo corporativo e narração."
        emoji = "👤"
    }
    "idoso" = @{
        speed = 0.82
        text = "Olá, meu querido. Já vivi muitas histórias e tenho muito a ensinar. Deixe-me contar sobre minha experiência."
        emoji = "👴"
    }
}

Write-Host "🎙️  Gerando $($kokoroVoices.Count) vozes x $($ages.Count) idades = $($kokoroVoices.Count * $ages.Count) arquivos...`n" -ForegroundColor Cyan

$successCount = 0
$errorCount = 0
$totalFiles = $kokoroVoices.Count * $ages.Count

$currentFile = 0

foreach ($voice in $kokoroVoices) {
    foreach ($age in $ages) {
        $currentFile++
        $ageConfig = $ageConfigs[$age]
        
        # Nome do arquivo: idade_voz_nome.wav
        # Ex: adulto_af-sarah_Sarah.wav
        $voiceCode = $voice.code -replace "_", "-"
        $voiceName = $voice.name -replace " ", "-"
        $fileName = "${age}_${voiceCode}_${voiceName}.wav"
        $outputFile = "$refDir/$age/$fileName"
        
        $emoji = $ageConfig.emoji
        $genderEmoji = if ($voice.gender -eq "F") { "👩" } else { "👨" }
        
        Write-Host "  [$currentFile/$totalFiles] $emoji $genderEmoji $($voice.name) ($age)" -ForegroundColor Gray -NoNewline
        
        try {
            $body = @{
                model = "kokoro"
                input = $ageConfig.text
                voice = $voice.code
                response_format = "wav"
                speed = $ageConfig.speed
                lang_code = "pt-br"
            } | ConvertTo-Json
            
            $response = Invoke-WebRequest `
                -Uri "http://localhost:8880/v1/audio/speech" `
                -Method POST `
                -Body $body `
                -ContentType "application/json" `
                -ErrorAction Stop
            
            [System.IO.File]::WriteAllBytes($outputFile, $response.Content)
            
            $size = (Get-Item $outputFile).Length / 1KB
            Write-Host " ✅ $([math]::Round($size, 1)) KB" -ForegroundColor Green
            $successCount++
            
        } catch {
            Write-Host " ❌" -ForegroundColor Red
            $errorCount++
        }
    }
}

Write-Host "`n📊 Resumo da Geração:`n" -ForegroundColor Cyan

Write-Host "  ✅ Sucesso: $successCount arquivos" -ForegroundColor Green
if ($errorCount -gt 0) {
    Write-Host "  ❌ Erros: $errorCount arquivos" -ForegroundColor Red
}

# Calcular tamanho total
$allFiles = Get-ChildItem -Path $refDir -Filter "*.wav" -Recurse
$totalSize = ($allFiles | Measure-Object -Property Length -Sum).Sum / 1MB

Write-Host "  📦 Tamanho total: $([math]::Round($totalSize, 2)) MB`n" -ForegroundColor Cyan

# Estatísticas por idade
Write-Host "📂 Arquivos por Idade:`n" -ForegroundColor Yellow

foreach ($age in $ages) {
    $ageFiles = Get-ChildItem -Path "$refDir/$age" -Filter "*.wav" -ErrorAction SilentlyContinue
    if ($ageFiles) {
        $ageSize = ($ageFiles | Measure-Object -Property Length -Sum).Sum / 1KB
        $emoji = $ageConfigs[$age].emoji
        Write-Host "  $emoji $age : $($ageFiles.Count) vozes ($([math]::Round($ageSize, 1)) KB)" -ForegroundColor Gray
    }
}

Write-Host "`n📋 Estrutura dos Arquivos:`n" -ForegroundColor Cyan
Write-Host "  Formato: idade_codigo-voz_Nome-Voz.wav" -ForegroundColor Gray
Write-Host "  Exemplo: adulto_af-sarah_Sarah.wav" -ForegroundColor Gray
Write-Host "  Exemplo: crianca_am-michael_Michael.wav`n" -ForegroundColor Gray

Write-Host "💡 Próximos Passos:`n" -ForegroundColor Cyan
Write-Host "  1. Ouvir e selecionar melhores vozes:" -ForegroundColor White
Write-Host "     Explorar: references-kokoro/`n" -ForegroundColor Gray
Write-Host "  2. Copiar selecionadas para OpenVoice:" -ForegroundColor White
Write-Host "     docker cp references-kokoro/ openvoice:/app/references/`n" -ForegroundColor Gray
Write-Host "  3. Listar todas as vozes:" -ForegroundColor White
Write-Host "     .\list-kokoro-voices.ps1`n" -ForegroundColor Gray

Write-Host "✅ Biblioteca completa criada!`n" -ForegroundColor Green

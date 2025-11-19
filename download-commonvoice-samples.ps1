# Download Common Voice Portuguese Brazil Samples
# Script para baixar samples reais de voz do Mozilla Common Voice

Write-Host "`n🎤 Download de Samples - Mozilla Common Voice (PT-BR)`n" -ForegroundColor Cyan

# Criar diretórios
$refDir = "references"
$cvDir = "$refDir/commonvoice"

New-Item -ItemType Directory -Force -Path $refDir | Out-Null
New-Item -ItemType Directory -Force -Path $cvDir | Out-Null

Write-Host "📁 Diretórios criados`n" -ForegroundColor Green

# URLs de samples do Common Voice (exemplos públicos)
# Nota: Estes são exemplos. Para produção, baixe o dataset completo do Common Voice
$samples = @(
    @{
        name = "masculina-jovem"
        url = "https://mozilla-common-voice-datasets.s3.dualstack.us-west-2.amazonaws.com/cv-corpus-12.0-2022-12-07/pt/clips/common_voice_pt_19000001.mp3"
        description = "Voz masculina jovem"
    },
    @{
        name = "feminina-adulta"
        url = "https://mozilla-common-voice-datasets.s3.dualstack.us-west-2.amazonaws.com/cv-corpus-12.0-2022-12-07/pt/clips/common_voice_pt_19000002.mp3"
        description = "Voz feminina adulta"
    }
)

Write-Host "⚠️  IMPORTANTE:`n" -ForegroundColor Yellow
Write-Host "  O Common Voice requer download do dataset completo." -ForegroundColor Gray
Write-Host "  Este script é um exemplo de como baixar samples.`n" -ForegroundColor Gray

Write-Host "📥 Alternativa: Usar Kokoro para gerar samples de alta qualidade`n" -ForegroundColor Cyan
Write-Host "  Execute: .\download-voice-samples.ps1`n" -ForegroundColor Green

Write-Host "💡 Para baixar Common Voice completo:`n" -ForegroundColor Cyan
Write-Host "  1. Acesse: https://commonvoice.mozilla.org/pt/datasets" -ForegroundColor Gray
Write-Host "  2. Faça login com conta Mozilla" -ForegroundColor Gray
Write-Host "  3. Baixe o dataset pt (Portuguese)" -ForegroundColor Gray
Write-Host "  4. Extraia e selecione melhores samples`n" -ForegroundColor Gray

Write-Host "🎙️  Recomendação: Use Kokoro (mais rápido e confiável)`n" -ForegroundColor Green

Write-Host ""

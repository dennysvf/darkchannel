# Test Voice Cloning with OpenVoice
# Script para testar clonagem de voz com samples de referência

Write-Host "`n🧪 Testando Clonagem de Voz - OpenVoice`n" -ForegroundColor Cyan

# Verificar se existem samples
if (-not (Test-Path "references/*.wav")) {
    Write-Host "❌ Nenhum sample encontrado!" -ForegroundColor Red
    Write-Host "Execute primeiro: .\download-voice-samples.ps1`n" -ForegroundColor Yellow
    exit 1
}

# Listar samples disponíveis
Write-Host "📂 Samples disponíveis:`n" -ForegroundColor Yellow
$samples = Get-ChildItem -Path "references" -Filter "*.wav"
$i = 1
foreach ($sample in $samples) {
    Write-Host "  $i. $($sample.Name)" -ForegroundColor Gray
    $i++
}

# Selecionar sample (usar primeiro por padrão)
$selectedSample = $samples[0]
Write-Host "`n🎤 Usando: $($selectedSample.Name)`n" -ForegroundColor Green

# Texto para sintetizar
$testText = "Olá! Esta é uma demonstração de clonagem de voz usando OpenVoice. A voz que você está ouvindo foi clonada a partir de uma amostra de referência em português do Brasil."

Write-Host "📝 Texto: $testText`n" -ForegroundColor Cyan

# Copiar sample para container (se ainda não foi copiado)
Write-Host "📦 Copiando sample para container...`n" -ForegroundColor Yellow
try {
    docker cp $selectedSample.FullName openvoice:/app/references/$($selectedSample.Name) 2>$null
    Write-Host "  ✅ Sample copiado!`n" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Aviso: $($_.Exception.Message)`n" -ForegroundColor Yellow
}

# Testar clonagem
Write-Host "🎙️  Iniciando clonagem de voz...`n" -ForegroundColor Cyan

try {
    # Preparar multipart form data
    $boundary = [System.Guid]::NewGuid().ToString()
    $LF = "`r`n"
    
    # Ler arquivo de áudio
    $audioBytes = [System.IO.File]::ReadAllBytes($selectedSample.FullName)
    
    # Construir body multipart
    $bodyLines = @(
        "--$boundary",
        "Content-Disposition: form-data; name=`"reference_audio`"; filename=`"$($selectedSample.Name)`"",
        "Content-Type: audio/wav",
        "",
        [System.Text.Encoding]::GetEncoding("iso-8859-1").GetString($audioBytes),
        "--$boundary",
        "Content-Disposition: form-data; name=`"text`"",
        "",
        $testText,
        "--$boundary",
        "Content-Disposition: form-data; name=`"language`"",
        "",
        "pt-br",
        "--$boundary",
        "Content-Disposition: form-data; name=`"speed`"",
        "",
        "1.0",
        "--$boundary--"
    ) -join $LF
    
    $response = Invoke-RestMethod `
        -Uri "http://localhost:8000/clone" `
        -Method POST `
        -ContentType "multipart/form-data; boundary=$boundary" `
        -Body ([System.Text.Encoding]::GetEncoding("iso-8859-1").GetBytes($bodyLines)) `
        -TimeoutSec 60
    
    Write-Host "✅ Clonagem concluída!`n" -ForegroundColor Green
    
    Write-Host "📄 Resultado:`n" -ForegroundColor Cyan
    Write-Host "  Request ID: $($response.request_id)" -ForegroundColor Gray
    Write-Host "  Arquivo de saída: $($response.output_audio)" -ForegroundColor Gray
    Write-Host "  Áudio de referência: $($response.reference_audio)" -ForegroundColor Gray
    
    if ($response.download_url) {
        Write-Host "`n🔗 Download URL:" -ForegroundColor Yellow
        Write-Host "  http://localhost:8000$($response.download_url)`n" -ForegroundColor Green
        
        Write-Host "💡 Copie e cole no navegador para ouvir!`n" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "❌ Erro na clonagem!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "`nDetalhes: $responseBody`n" -ForegroundColor Yellow
    }
}

Write-Host ""

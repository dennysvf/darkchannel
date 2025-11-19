# Download CETUC Dataset Samples
# Script para baixar samples reais de vozes brasileiras do dataset CETUC

Write-Host "`n🎤 Download CETUC Dataset - Vozes Brasileiras Reais`n" -ForegroundColor Cyan

# Verificar se Python está instalado
try {
    $pythonVersion = python --version 2>&1
    Write-Host "✅ Python encontrado: $pythonVersion`n" -ForegroundColor Green
} catch {
    Write-Host "❌ Python não encontrado!" -ForegroundColor Red
    Write-Host "Instale Python 3.9+ de: https://www.python.org/downloads/`n" -ForegroundColor Yellow
    exit 1
}

# Criar ambiente virtual
$venvPath = "venv-cetuc"
Write-Host "📦 Criando ambiente virtual...`n" -ForegroundColor Yellow

if (Test-Path $venvPath) {
    Write-Host "  ⚠️  Ambiente já existe, usando existente`n" -ForegroundColor Yellow
} else {
    python -m venv $venvPath
    Write-Host "  ✅ Ambiente criado`n" -ForegroundColor Green
}

# Ativar ambiente virtual
$activateScript = "$venvPath\Scripts\Activate.ps1"
Write-Host "🔧 Ativando ambiente virtual...`n" -ForegroundColor Yellow
& $activateScript

# Instalar DVC com suporte Google Drive
Write-Host "📥 Instalando DVC com Google Drive...`n" -ForegroundColor Yellow
Write-Host "  (Isso pode demorar alguns minutos)`n" -ForegroundColor Gray

pip install --upgrade pip | Out-Null
pip install "dvc[gdrive]" | Out-Null

Write-Host "  ✅ DVC instalado`n" -ForegroundColor Green

# Clonar repositório speech-datasets
$repoDir = "speech-datasets"
Write-Host "📂 Clonando repositório FalaBrasil...`n" -ForegroundColor Yellow

if (Test-Path $repoDir) {
    Write-Host "  ⚠️  Repositório já existe`n" -ForegroundColor Yellow
    Set-Location $repoDir
} else {
    git clone https://github.com/falabrasil/speech-datasets.git
    Set-Location $repoDir
    Write-Host "  ✅ Repositório clonado`n" -ForegroundColor Green
}

# Listar locutores disponíveis
Write-Host "`n📋 Locutores CETUC Disponíveis:`n" -ForegroundColor Cyan
Write-Host "Total: 101 locutores (50 homens, 51 mulheres)`n" -ForegroundColor Gray

# Selecionar alguns locutores interessantes
$selectedSpeakers = @(
    # Mulheres
    "Andrea_F003",           # Adulta
    "Mariana_F024",          # Jovem
    "IvoneAmitrano_F000",    # Madura
    "Gabriela_F034",         # Jovem
    "TerezaSpedo_F041",      # Idosa
    "SandraRocha_F011",      # Adulta
    
    # Homens
    "Paulinho_M000",         # Adulto
    "DanielRibeiro_M002",    # Jovem
    "Oswaldo_M012",          # Maduro
    "JeanCarlos_M019",       # Jovem
    "JoseIldo_M024",         # Idoso
    "HenriqueMafra_M046"     # Adulto
)

Write-Host "🎯 Locutores selecionados para download:`n" -ForegroundColor Yellow
$i = 1
foreach ($speaker in $selectedSpeakers) {
    $gender = if ($speaker -match "_F") { "👩 Feminina" } else { "👨 Masculina" }
    Write-Host "  $i. $speaker - $gender" -ForegroundColor Gray
    $i++
}

Write-Host "`n⚠️  IMPORTANTE:`n" -ForegroundColor Yellow
Write-Host "  - O download requer autenticação no Google Drive" -ForegroundColor Gray
Write-Host "  - Cada locutor tem ~150-200MB (1000 sentenças)" -ForegroundColor Gray
Write-Host "  - Total estimado: ~2-3GB para 12 locutores" -ForegroundColor Gray
Write-Host "  - Tempo estimado: 30-60 minutos`n" -ForegroundColor Gray

Write-Host "💡 Alternativa mais rápida:`n" -ForegroundColor Cyan
Write-Host "  Baixar apenas alguns arquivos de teste primeiro`n" -ForegroundColor Gray

# Perguntar se quer continuar
$response = Read-Host "`nDeseja continuar com o download? (s/n)"

if ($response -ne "s") {
    Write-Host "`n❌ Download cancelado`n" -ForegroundColor Red
    Set-Location ..
    exit 0
}

Write-Host "`n📥 Iniciando download do CETUC...`n" -ForegroundColor Cyan
Write-Host "⏳ Isso pode demorar. Aguarde...`n" -ForegroundColor Yellow

try {
    # Tentar baixar dataset público
    dvc pull -r public
    
    Write-Host "`n✅ Download concluído!`n" -ForegroundColor Green
    
    # Verificar o que foi baixado
    Write-Host "📊 Verificando arquivos baixados...`n" -ForegroundColor Cyan
    
    $cetucPath = "datasets/cetuc"
    if (Test-Path $cetucPath) {
        $speakers = Get-ChildItem -Path $cetucPath -Directory
        Write-Host "  Total de locutores baixados: $($speakers.Count)`n" -ForegroundColor Green
        
        # Copiar samples selecionados para pasta references
        $refDir = "../references/cetuc"
        New-Item -ItemType Directory -Force -Path $refDir | Out-Null
        
        Write-Host "📦 Copiando samples selecionados...`n" -ForegroundColor Yellow
        
        foreach ($speaker in $selectedSpeakers) {
            $speakerPath = "$cetucPath/$speaker"
            if (Test-Path $speakerPath) {
                # Copiar primeiros 10 arquivos de cada locutor
                $audioFiles = Get-ChildItem -Path $speakerPath -Filter "*.wav" | Select-Object -First 10
                
                $speakerRefDir = "$refDir/$speaker"
                New-Item -ItemType Directory -Force -Path $speakerRefDir | Out-Null
                
                foreach ($file in $audioFiles) {
                    Copy-Item $file.FullName -Destination $speakerRefDir
                }
                
                Write-Host "  ✅ $speaker - $($audioFiles.Count) arquivos" -ForegroundColor Green
            }
        }
        
        Write-Host "`n📂 Samples salvos em: $refDir`n" -ForegroundColor Cyan
        
    } else {
        Write-Host "  ⚠️  Diretório CETUC não encontrado`n" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "`n❌ Erro no download!`n" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`n💡 Possíveis causas:`n" -ForegroundColor Yellow
    Write-Host "  - Autenticação Google Drive necessária" -ForegroundColor Gray
    Write-Host "  - Conexão de internet instável" -ForegroundColor Gray
    Write-Host "  - Espaço em disco insuficiente`n" -ForegroundColor Gray
}

Set-Location ..

Write-Host "`n📋 Próximos passos:`n" -ForegroundColor Cyan
Write-Host "  1. Verificar samples em: references/cetuc/" -ForegroundColor Gray
Write-Host "  2. Copiar para container OpenVoice:" -ForegroundColor Gray
Write-Host "     docker cp references/cetuc/ openvoice:/app/references/" -ForegroundColor Gray
Write-Host "  3. Testar clonagem de voz:" -ForegroundColor Gray
Write-Host "     .\test-voice-cloning.ps1`n" -ForegroundColor Gray

Write-Host "✅ Script concluído!`n" -ForegroundColor Green

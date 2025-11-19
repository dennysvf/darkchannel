# Check OpenVoice Models Status

Write-Host "`n🔍 Verificando modelos OpenVoice...`n" -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod `
        -Uri "http://localhost:8000/status" `
        -Method GET `
        -TimeoutSec 10
    
    Write-Host "📊 Status do OpenVoice:`n" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 5 | Write-Host
    
    # Verificar arquivos no container
    Write-Host "`n📁 Arquivos no diretório de modelos:`n" -ForegroundColor Yellow
    
    $files = docker exec openvoice find /app/checkpoints_v2 -type f 2>$null
    
    if ($files) {
        $fileCount = ($files | Measure-Object).Count
        Write-Host "✅ Total de arquivos: $fileCount`n" -ForegroundColor Green
        
        # Mostrar primeiros 10 arquivos
        $files | Select-Object -First 10 | ForEach-Object {
            Write-Host "  $_" -ForegroundColor Gray
        }
        
        if ($fileCount -gt 10) {
            Write-Host "`n  ... e mais $($fileCount - 10) arquivos" -ForegroundColor Gray
        }
        
        # Tamanho total
        $size = docker exec openvoice du -sh /app/checkpoints_v2 2>$null
        Write-Host "`n📦 Tamanho total: $size`n" -ForegroundColor Cyan
        
    } else {
        Write-Host "❌ Nenhum arquivo encontrado!`n" -ForegroundColor Red
        Write-Host "Execute: .\download-openvoice-models.ps1`n" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "`n❌ Erro ao verificar status!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""

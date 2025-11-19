# Gerar URL de download do MinIO

param(
    [string]$JobId = "4fdf6073-73bf-495f-9b6d-51515b089711",
    [int]$ChunkIndex = 0
)

Write-Host "`n🔗 Gerando URL de download...`n" -ForegroundColor Cyan

$pythonScript = @"
import sys
sys.path.insert(0, 'src')

from minio import MinIOClient
import os

# Configurar credenciais
os.environ['MINIO_ENDPOINT'] = 'http://localhost:9000'
os.environ['MINIO_ACCESS_KEY'] = 'uovuCgq4VX9gIyFvua5K'
os.environ['MINIO_SECRET_KEY'] = 'ulhQu3Sw8cfXLakMfCLFyeIbQjJbQ7WlvrmOJtnE'

client = MinIOClient()

bucket = 'darkchannel-jobs'
s3_key = '$JobId/chunks/chunk-$($ChunkIndex.ToString('000')).wav'

# Verificar se existe
if client.object_exists(bucket, s3_key):
    print(f'✅ Arquivo encontrado: {s3_key}')
    
    # Gerar URL (válida por 1 hora)
    url = client.generate_presigned_url(bucket, s3_key, expiration=3600)
    print(f'\n🔗 URL de Download (válida por 1 hora):\n')
    print(url)
    print()
    
    # Metadados
    metadata = client.get_object_metadata(bucket, s3_key)
    if metadata:
        print(f'📊 Informações do arquivo:')
        print(f'   Tamanho: {metadata["size"]} bytes')
        print(f'   Tipo: {metadata["content_type"]}')
        print(f'   Última modificação: {metadata["last_modified"]}')
else:
    print(f'❌ Arquivo não encontrado: {s3_key}')
    print(f'   Bucket: {bucket}')
"@

# Executar Python
$pythonScript | python

Write-Host ""

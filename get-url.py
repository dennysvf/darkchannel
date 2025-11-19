#!/usr/bin/env python3
import sys
sys.path.insert(0, '/app')

from minio import MinIOClient
import os

# Configurar
os.environ['MINIO_ENDPOINT'] = 'http://minio:9000'
os.environ['MINIO_ACCESS_KEY'] = 'uovuCgq4VX9gIyFvua5K'
os.environ['MINIO_SECRET_KEY'] = 'ulhQu3Sw8cfXLakMfCLFyeIbQjJbQ7WlvrmOJtnE'

client = MinIOClient()

bucket = 'darkchannel-jobs'
s3_key = '4fdf6073-73bf-495f-9b6d-51515b089711/chunks/chunk-000.wav'

print('\n🔍 Verificando arquivo...\n')

if client.object_exists(bucket, s3_key):
    print(f'✅ Arquivo encontrado!')
    print(f'   Bucket: {bucket}')
    print(f'   Key: {s3_key}')
    
    # Metadados
    meta = client.get_object_metadata(bucket, s3_key)
    print(f'\n📊 Informações:')
    print(f'   Tamanho: {meta["size"]} bytes')
    print(f'   Tipo: {meta["content_type"]}')
    print(f'   Modificado: {meta["last_modified"]}')
    
    # URL
    url = client.generate_presigned_url(bucket, s3_key, expiration=3600)
    print(f'\n🔗 URL de Download (válida por 1 hora):')
    print(f'\n{url}\n')
else:
    print(f'❌ Arquivo não encontrado!')
    print(f'   Bucket: {bucket}')
    print(f'   Key: {s3_key}')

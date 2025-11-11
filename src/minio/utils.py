"""
Utility functions para MinIO
"""

import uuid
from typing import Tuple, Optional
from urllib.parse import urlparse


def generate_job_id() -> str:
    """
    Gera ID único para job
    
    Returns:
        UUID string
    """
    return str(uuid.uuid4())


def get_s3_url(bucket: str, key: str, endpoint: str = 'http://minio:9000') -> str:
    """
    Gera URL S3 completa
    
    Args:
        bucket: Nome do bucket
        key: Chave S3
        endpoint: Endpoint do MinIO
        
    Returns:
        URL S3 completa
    """
    return f"s3://{bucket}/{key}"


def parse_s3_url(s3_url: str) -> Optional[Tuple[str, str]]:
    """
    Parse URL S3 para extrair bucket e key
    
    Args:
        s3_url: URL no formato s3://bucket/key
        
    Returns:
        Tupla (bucket, key) ou None se inválido
    """
    try:
        parsed = urlparse(s3_url)
        
        if parsed.scheme != 's3':
            return None
        
        bucket = parsed.netloc
        key = parsed.path.lstrip('/')
        
        return (bucket, key)
    except:
        return None


def format_size(size_bytes: int) -> str:
    """
    Formata tamanho em bytes para formato legível
    
    Args:
        size_bytes: Tamanho em bytes
        
    Returns:
        String formatada (ex: "1.5 MB")
    """
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if size_bytes < 1024.0:
            return f"{size_bytes:.1f} {unit}"
        size_bytes /= 1024.0
    return f"{size_bytes:.1f} PB"


def sanitize_filename(filename: str) -> str:
    """
    Sanitiza nome de arquivo para uso em S3
    
    Args:
        filename: Nome do arquivo
        
    Returns:
        Nome sanitizado
    """
    # Remove caracteres inválidos
    invalid_chars = ['<', '>', ':', '"', '/', '\\', '|', '?', '*']
    for char in invalid_chars:
        filename = filename.replace(char, '_')
    
    # Remove espaços extras
    filename = ' '.join(filename.split())
    
    # Substitui espaços por hífens
    filename = filename.replace(' ', '-')
    
    return filename.lower()

"""
MinIO S3 Client Wrapper
Simplifica operações com MinIO usando boto3
"""

import os
import logging
from typing import Optional, Dict, Any
import boto3
from botocore.client import Config
from botocore.exceptions import ClientError

logger = logging.getLogger(__name__)


class MinIOClient:
    """Cliente S3 para MinIO com métodos simplificados"""
    
    def __init__(
        self,
        endpoint_url: Optional[str] = None,
        access_key: Optional[str] = None,
        secret_key: Optional[str] = None,
        region: str = 'us-east-1'
    ):
        """
        Inicializa cliente MinIO
        
        Args:
            endpoint_url: URL do MinIO (padrão: env MINIO_ENDPOINT)
            access_key: Access key (padrão: env MINIO_ACCESS_KEY)
            secret_key: Secret key (padrão: env MINIO_SECRET_KEY)
            region: Região S3 (padrão: us-east-1)
        """
        self.endpoint_url = endpoint_url or os.getenv('MINIO_ENDPOINT', 'http://minio:9000')
        self.access_key = access_key or os.getenv('MINIO_ACCESS_KEY', 'darkchannel-app')
        self.secret_key = secret_key or os.getenv('MINIO_SECRET_KEY', 'darkchannel-secret-key-123')
        
        self.s3_client = boto3.client(
            's3',
            endpoint_url=self.endpoint_url,
            aws_access_key_id=self.access_key,
            aws_secret_access_key=self.secret_key,
            config=Config(signature_version='s3v4'),
            region_name=region
        )
        
        logger.info(f"MinIO Client initialized: {self.endpoint_url}")
    
    def upload_file(
        self,
        file_path: str,
        bucket: str,
        key: str,
        metadata: Optional[Dict[str, str]] = None,
        content_type: Optional[str] = None
    ) -> bool:
        """
        Upload de arquivo para MinIO
        
        Args:
            file_path: Caminho do arquivo local
            bucket: Nome do bucket
            key: Chave S3 (caminho no bucket)
            metadata: Metadados opcionais
            content_type: Content-Type do arquivo
            
        Returns:
            True se sucesso, False caso contrário
        """
        try:
            extra_args = {}
            
            if metadata:
                extra_args['Metadata'] = metadata
            
            if content_type:
                extra_args['ContentType'] = content_type
            
            self.s3_client.upload_file(
                file_path,
                bucket,
                key,
                ExtraArgs=extra_args if extra_args else None
            )
            
            logger.info(f"Upload OK: s3://{bucket}/{key}")
            return True
            
        except ClientError as e:
            logger.error(f"Upload failed: {e}")
            return False
    
    def download_file(
        self,
        bucket: str,
        key: str,
        file_path: str
    ) -> bool:
        """
        Download de arquivo do MinIO
        
        Args:
            bucket: Nome do bucket
            key: Chave S3
            file_path: Caminho local para salvar
            
        Returns:
            True se sucesso, False caso contrário
        """
        try:
            self.s3_client.download_file(bucket, key, file_path)
            logger.info(f"Download OK: s3://{bucket}/{key} -> {file_path}")
            return True
            
        except ClientError as e:
            logger.error(f"Download failed: {e}")
            return False
    
    def upload_bytes(
        self,
        data: bytes,
        bucket: str,
        key: str,
        metadata: Optional[Dict[str, str]] = None,
        content_type: str = 'application/octet-stream'
    ) -> bool:
        """
        Upload de bytes para MinIO
        
        Args:
            data: Dados em bytes
            bucket: Nome do bucket
            key: Chave S3
            metadata: Metadados opcionais
            content_type: Content-Type
            
        Returns:
            True se sucesso, False caso contrário
        """
        try:
            extra_args = {'ContentType': content_type}
            
            if metadata:
                extra_args['Metadata'] = metadata
            
            self.s3_client.put_object(
                Bucket=bucket,
                Key=key,
                Body=data,
                **extra_args
            )
            
            logger.info(f"Upload bytes OK: s3://{bucket}/{key}")
            return True
            
        except ClientError as e:
            logger.error(f"Upload bytes failed: {e}")
            return False
    
    def download_bytes(
        self,
        bucket: str,
        key: str
    ) -> Optional[bytes]:
        """
        Download de bytes do MinIO
        
        Args:
            bucket: Nome do bucket
            key: Chave S3
            
        Returns:
            Bytes do arquivo ou None se erro
        """
        try:
            response = self.s3_client.get_object(Bucket=bucket, Key=key)
            data = response['Body'].read()
            logger.info(f"Download bytes OK: s3://{bucket}/{key}")
            return data
            
        except ClientError as e:
            logger.error(f"Download bytes failed: {e}")
            return None
    
    def list_objects(
        self,
        bucket: str,
        prefix: str = ''
    ) -> list:
        """
        Lista objetos em um bucket
        
        Args:
            bucket: Nome do bucket
            prefix: Prefixo para filtrar
            
        Returns:
            Lista de chaves
        """
        try:
            response = self.s3_client.list_objects_v2(
                Bucket=bucket,
                Prefix=prefix
            )
            
            if 'Contents' not in response:
                return []
            
            keys = [obj['Key'] for obj in response['Contents']]
            logger.info(f"Listed {len(keys)} objects in s3://{bucket}/{prefix}")
            return keys
            
        except ClientError as e:
            logger.error(f"List failed: {e}")
            return []
    
    def delete_object(
        self,
        bucket: str,
        key: str
    ) -> bool:
        """
        Deleta objeto do MinIO
        
        Args:
            bucket: Nome do bucket
            key: Chave S3
            
        Returns:
            True se sucesso, False caso contrário
        """
        try:
            self.s3_client.delete_object(Bucket=bucket, Key=key)
            logger.info(f"Delete OK: s3://{bucket}/{key}")
            return True
            
        except ClientError as e:
            logger.error(f"Delete failed: {e}")
            return False
    
    def generate_presigned_url(
        self,
        bucket: str,
        key: str,
        expiration: int = 3600
    ) -> Optional[str]:
        """
        Gera URL pré-assinada para download
        
        Args:
            bucket: Nome do bucket
            key: Chave S3
            expiration: Tempo de expiração em segundos (padrão: 1 hora)
            
        Returns:
            URL pré-assinada ou None se erro
        """
        try:
            url = self.s3_client.generate_presigned_url(
                'get_object',
                Params={'Bucket': bucket, 'Key': key},
                ExpiresIn=expiration
            )
            logger.info(f"Presigned URL generated: s3://{bucket}/{key}")
            return url
            
        except ClientError as e:
            logger.error(f"Presigned URL failed: {e}")
            return None
    
    def object_exists(
        self,
        bucket: str,
        key: str
    ) -> bool:
        """
        Verifica se objeto existe
        
        Args:
            bucket: Nome do bucket
            key: Chave S3
            
        Returns:
            True se existe, False caso contrário
        """
        try:
            self.s3_client.head_object(Bucket=bucket, Key=key)
            return True
        except ClientError:
            return False
    
    def get_object_metadata(
        self,
        bucket: str,
        key: str
    ) -> Optional[Dict[str, Any]]:
        """
        Obtém metadados de um objeto
        
        Args:
            bucket: Nome do bucket
            key: Chave S3
            
        Returns:
            Dicionário com metadados ou None se erro
        """
        try:
            response = self.s3_client.head_object(Bucket=bucket, Key=key)
            return {
                'size': response.get('ContentLength'),
                'last_modified': response.get('LastModified'),
                'content_type': response.get('ContentType'),
                'metadata': response.get('Metadata', {})
            }
        except ClientError as e:
            logger.error(f"Get metadata failed: {e}")
            return None

"""
Job Manager - Gestão de jobs no MinIO
Gerencia ciclo de vida de jobs de processamento de áudio
"""

import os
import json
import logging
from typing import Optional, Dict, Any, List
from datetime import datetime
from .client import MinIOClient
from .utils import generate_job_id

logger = logging.getLogger(__name__)


class JobManager:
    """Gerenciador de jobs no MinIO"""
    
    def __init__(self, minio_client: Optional[MinIOClient] = None):
        """
        Inicializa JobManager
        
        Args:
            minio_client: Cliente MinIO (cria novo se None)
        """
        self.client = minio_client or MinIOClient()
        self.bucket_jobs = os.getenv('MINIO_BUCKET_JOBS', 'darkchannel-jobs')
        self.bucket_output = os.getenv('MINIO_BUCKET_OUTPUT', 'darkchannel-output')
    
    def create_job(
        self,
        chapter_title: str,
        input_text: str,
        ssml: Optional[str] = None,
        metadata: Optional[Dict[str, Any]] = None
    ) -> str:
        """
        Cria novo job
        
        Args:
            chapter_title: Título do capítulo
            input_text: Texto de entrada
            ssml: SSML gerado (opcional)
            metadata: Metadados adicionais
            
        Returns:
            Job ID
        """
        job_id = generate_job_id()
        
        job_metadata = {
            'job_id': job_id,
            'status': 'pending',
            'created_at': datetime.utcnow().isoformat(),
            'chapter_title': chapter_title,
            'input_text': input_text,
            'ssml': ssml,
            'chunks': {
                'total': 0,
                'completed': 0,
                'failed': 0,
                'files': []
            }
        }
        
        if metadata:
            job_metadata.update(metadata)
        
        # Upload metadata
        metadata_key = f"{job_id}/metadata.json"
        metadata_json = json.dumps(job_metadata, indent=2, ensure_ascii=False)
        
        success = self.client.upload_bytes(
            metadata_json.encode('utf-8'),
            self.bucket_jobs,
            metadata_key,
            content_type='application/json'
        )
        
        if success:
            logger.info(f"Job created: {job_id}")
            return job_id
        else:
            raise Exception(f"Failed to create job {job_id}")
    
    def get_job_metadata(self, job_id: str) -> Optional[Dict[str, Any]]:
        """
        Recupera metadata do job
        
        Args:
            job_id: ID do job
            
        Returns:
            Dicionário com metadata ou None se não encontrado
        """
        metadata_key = f"{job_id}/metadata.json"
        
        data = self.client.download_bytes(self.bucket_jobs, metadata_key)
        
        if data:
            return json.loads(data.decode('utf-8'))
        return None
    
    def update_job_metadata(
        self,
        job_id: str,
        updates: Dict[str, Any]
    ) -> bool:
        """
        Atualiza metadata do job
        
        Args:
            job_id: ID do job
            updates: Dicionário com atualizações
            
        Returns:
            True se sucesso, False caso contrário
        """
        # Buscar metadata atual
        current_metadata = self.get_job_metadata(job_id)
        
        if not current_metadata:
            logger.error(f"Job not found: {job_id}")
            return False
        
        # Atualizar
        current_metadata.update(updates)
        current_metadata['updated_at'] = datetime.utcnow().isoformat()
        
        # Upload atualizado
        metadata_key = f"{job_id}/metadata.json"
        metadata_json = json.dumps(current_metadata, indent=2, ensure_ascii=False)
        
        return self.client.upload_bytes(
            metadata_json.encode('utf-8'),
            self.bucket_jobs,
            metadata_key,
            content_type='application/json'
        )
    
    def update_job_status(
        self,
        job_id: str,
        status: str,
        **kwargs
    ) -> bool:
        """
        Atualiza status do job
        
        Args:
            job_id: ID do job
            status: Novo status (pending, processing, completed, failed)
            **kwargs: Campos adicionais para atualizar
            
        Returns:
            True se sucesso, False caso contrário
        """
        updates = {'status': status}
        updates.update(kwargs)
        
        if status == 'completed':
            updates['completed_at'] = datetime.utcnow().isoformat()
        elif status == 'failed':
            updates['failed_at'] = datetime.utcnow().isoformat()
        
        return self.update_job_metadata(job_id, updates)
    
    def add_chunk(
        self,
        job_id: str,
        chunk_index: int,
        s3_key: str
    ) -> bool:
        """
        Adiciona chunk ao job
        
        Args:
            job_id: ID do job
            chunk_index: Índice do chunk
            s3_key: Chave S3 do chunk
            
        Returns:
            True se sucesso, False caso contrário
        """
        metadata = self.get_job_metadata(job_id)
        
        if not metadata:
            return False
        
        # Adicionar chunk
        metadata['chunks']['files'].append({
            'index': chunk_index,
            's3_key': s3_key,
            'uploaded_at': datetime.utcnow().isoformat()
        })
        metadata['chunks']['completed'] += 1
        
        return self.update_job_metadata(job_id, metadata)
    
    def upload_chunk(
        self,
        job_id: str,
        chunk_index: int,
        file_path: str,
        metadata: Optional[Dict[str, str]] = None
    ) -> Optional[str]:
        """
        Upload de chunk de áudio
        
        Args:
            job_id: ID do job
            chunk_index: Índice do chunk
            file_path: Caminho do arquivo
            metadata: Metadados opcionais
            
        Returns:
            Chave S3 do chunk ou None se erro
        """
        chunk_key = f"{job_id}/chunks/chunk-{chunk_index:03d}.wav"
        
        success = self.client.upload_file(
            file_path,
            self.bucket_jobs,
            chunk_key,
            metadata=metadata,
            content_type='audio/wav'
        )
        
        if success:
            self.add_chunk(job_id, chunk_index, chunk_key)
            return chunk_key
        
        return None
    
    def upload_final_audio(
        self,
        job_id: str,
        file_path: str,
        metadata: Optional[Dict[str, str]] = None
    ) -> Optional[str]:
        """
        Upload do áudio final
        
        Args:
            job_id: ID do job
            file_path: Caminho do arquivo
            metadata: Metadados opcionais
            
        Returns:
            Chave S3 do áudio final ou None se erro
        """
        final_key = f"{job_id}/final/audiobook.mp3"
        
        success = self.client.upload_file(
            file_path,
            self.bucket_jobs,
            final_key,
            metadata=metadata,
            content_type='audio/mpeg'
        )
        
        if success:
            # Atualizar metadata
            self.update_job_metadata(job_id, {
                'output': {
                    's3_key': final_key,
                    'uploaded_at': datetime.utcnow().isoformat()
                }
            })
            return final_key
        
        return None
    
    def list_chunks(self, job_id: str) -> List[str]:
        """
        Lista chunks de um job
        
        Args:
            job_id: ID do job
            
        Returns:
            Lista de chaves S3 dos chunks
        """
        prefix = f"{job_id}/chunks/"
        return self.client.list_objects(self.bucket_jobs, prefix)
    
    def generate_download_url(
        self,
        job_id: str,
        expiration: int = 3600
    ) -> Optional[str]:
        """
        Gera URL de download do áudio final
        
        Args:
            job_id: ID do job
            expiration: Tempo de expiração em segundos
            
        Returns:
            URL pré-assinada ou None se erro
        """
        final_key = f"{job_id}/final/audiobook.mp3"
        
        if not self.client.object_exists(self.bucket_jobs, final_key):
            logger.error(f"Final audio not found for job {job_id}")
            return None
        
        return self.client.generate_presigned_url(
            self.bucket_jobs,
            final_key,
            expiration
        )
    
    def copy_to_output(
        self,
        job_id: str,
        output_name: str
    ) -> bool:
        """
        Copia áudio final para bucket de output
        
        Args:
            job_id: ID do job
            output_name: Nome do arquivo no output
            
        Returns:
            True se sucesso, False caso contrário
        """
        source_key = f"{job_id}/final/audiobook.mp3"
        
        # Download temporário
        import tempfile
        with tempfile.NamedTemporaryFile(delete=False, suffix='.mp3') as tmp:
            tmp_path = tmp.name
        
        try:
            # Download
            if not self.client.download_file(self.bucket_jobs, source_key, tmp_path):
                return False
            
            # Upload para output
            date_prefix = datetime.utcnow().strftime('%Y-%m-%d')
            output_key = f"{date_prefix}/{output_name}"
            
            success = self.client.upload_file(
                tmp_path,
                self.bucket_output,
                output_key,
                content_type='audio/mpeg'
            )
            
            if success:
                logger.info(f"Copied to output: s3://{self.bucket_output}/{output_key}")
            
            return success
            
        finally:
            # Limpar arquivo temporário
            if os.path.exists(tmp_path):
                os.unlink(tmp_path)

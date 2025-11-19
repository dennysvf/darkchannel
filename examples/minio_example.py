"""
Exemplo de uso do MinIO Client e Job Manager
"""

import sys
import os

# Adicionar src ao path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from minio import MinIOClient, JobManager


def example_basic_operations():
    """Exemplo de operações básicas"""
    print("\n=== Operações Básicas ===\n")
    
    # Criar cliente
    client = MinIOClient()
    
    # Upload de arquivo
    print("1. Upload de arquivo...")
    # client.upload_file('test.txt', 'darkchannel-temp', 'test/test.txt')
    
    # Upload de bytes
    print("2. Upload de bytes...")
    data = b"Hello MinIO!"
    client.upload_bytes(data, 'darkchannel-temp', 'test/hello.txt')
    
    # Download de bytes
    print("3. Download de bytes...")
    downloaded = client.download_bytes('darkchannel-temp', 'test/hello.txt')
    print(f"   Downloaded: {downloaded.decode('utf-8')}")
    
    # Listar objetos
    print("4. Listar objetos...")
    objects = client.list_objects('darkchannel-temp', 'test/')
    print(f"   Found {len(objects)} objects")
    
    # Gerar URL pré-assinada
    print("5. Gerar URL pré-assinada...")
    url = client.generate_presigned_url('darkchannel-temp', 'test/hello.txt')
    print(f"   URL: {url[:80]}...")
    
    # Deletar objeto
    print("6. Deletar objeto...")
    client.delete_object('darkchannel-temp', 'test/hello.txt')
    print("   Deleted!")


def example_job_management():
    """Exemplo de gestão de jobs"""
    print("\n=== Gestão de Jobs ===\n")
    
    # Criar job manager
    job_manager = JobManager()
    
    # Criar novo job
    print("1. Criar novo job...")
    job_id = job_manager.create_job(
        chapter_title="Capítulo 1: O Início",
        input_text="Era uma vez, em um reino distante...",
        ssml="<speak>Era uma vez...</speak>"
    )
    print(f"   Job ID: {job_id}")
    
    # Buscar metadata
    print("\n2. Buscar metadata...")
    metadata = job_manager.get_job_metadata(job_id)
    print(f"   Status: {metadata['status']}")
    print(f"   Title: {metadata['chapter_title']}")
    
    # Atualizar status
    print("\n3. Atualizar status...")
    job_manager.update_job_status(job_id, 'processing')
    
    # Simular upload de chunks
    print("\n4. Simular upload de chunks...")
    for i in range(3):
        # Criar arquivo temporário
        import tempfile
        with tempfile.NamedTemporaryFile(delete=False, suffix='.wav') as tmp:
            tmp.write(b"fake audio data")
            tmp_path = tmp.name
        
        # Upload
        chunk_key = job_manager.upload_chunk(job_id, i, tmp_path)
        print(f"   Chunk {i}: {chunk_key}")
        
        # Limpar
        os.unlink(tmp_path)
    
    # Listar chunks
    print("\n5. Listar chunks...")
    chunks = job_manager.list_chunks(job_id)
    print(f"   Total chunks: {len(chunks)}")
    
    # Simular upload final
    print("\n6. Upload áudio final...")
    with tempfile.NamedTemporaryFile(delete=False, suffix='.mp3') as tmp:
        tmp.write(b"fake final audio")
        tmp_path = tmp.name
    
    final_key = job_manager.upload_final_audio(job_id, tmp_path)
    print(f"   Final: {final_key}")
    os.unlink(tmp_path)
    
    # Marcar como completo
    print("\n7. Marcar como completo...")
    job_manager.update_job_status(job_id, 'completed')
    
    # Gerar URL de download
    print("\n8. Gerar URL de download...")
    download_url = job_manager.generate_download_url(job_id)
    print(f"   URL: {download_url[:80]}...")
    
    # Copiar para output
    print("\n9. Copiar para output...")
    job_manager.copy_to_output(job_id, 'capitulo-1-o-inicio.mp3')
    
    print(f"\n✅ Job {job_id} processado com sucesso!")


if __name__ == '__main__':
    print("=" * 60)
    print("MinIO Client - Exemplos de Uso")
    print("=" * 60)
    
    try:
        example_basic_operations()
        example_job_management()
        
        print("\n" + "=" * 60)
        print("✅ Todos os exemplos executados com sucesso!")
        print("=" * 60 + "\n")
        
    except Exception as e:
        print(f"\n❌ Erro: {e}")
        import traceback
        traceback.print_exc()

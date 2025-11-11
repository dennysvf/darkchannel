#!/usr/bin/env python3
"""
Kokoro TTS Wrapper - Adiciona endpoint /tts-to-s3
Proxy para o Kokoro original + upload para MinIO
"""
from flask import Flask, request, jsonify
import requests
import os
import sys
import tempfile
import logging

# Adicionar src ao path
sys.path.insert(0, '/app')

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# MinIO client (lazy loading)
minio_client_instance = None

def get_minio_client():
    """Get or create MinIO client"""
    global minio_client_instance
    if minio_client_instance is None:
        try:
            from minio import MinIOClient
            minio_client_instance = MinIOClient()
            logger.info("✅ MinIO client initialized")
        except Exception as e:
            logger.warning(f"⚠️  MinIO not available: {e}")
    return minio_client_instance


# URL do Kokoro original
KOKORO_URL = os.getenv('KOKORO_INTERNAL_URL', 'http://kokoro-tts-cpu:8880')


@app.route('/health', methods=['GET'])
def health():
    """Health check"""
    return jsonify({'status': 'healthy', 'service': 'Kokoro Wrapper'}), 200


@app.route('/download-url/<job_id>/<int:chunk_index>', methods=['GET'])
def get_download_url(job_id, chunk_index):
    """
    Gera URL de download pré-assinada para um chunk
    
    GET /download-url/{job_id}/{chunk_index}
    
    Returns:
    {
        "download_url": "http://localhost:9000/...",
        "expires_in": 3600
    }
    """
    try:
        minio_client = get_minio_client()
        if not minio_client:
            return jsonify({'error': 'MinIO not available'}), 503
        
        bucket = os.getenv('MINIO_BUCKET_JOBS', 'darkchannel-jobs')
        s3_key = f"{job_id}/chunks/chunk-{chunk_index:03d}.wav"
        
        # Verificar se existe
        if not minio_client.object_exists(bucket, s3_key):
            return jsonify({'error': 'File not found'}), 404
        
        # Gerar URL (válida por 1 hora)
        url = minio_client.generate_presigned_url(bucket, s3_key, expiration=3600)
        
        # Substituir hostname interno por localhost
        url = url.replace('http://minio:9000', 'http://localhost:9000')
        
        return jsonify({
            'download_url': url,
            'expires_in': 3600,
            'job_id': job_id,
            'chunk_index': chunk_index,
            's3_key': s3_key
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Erro: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/tts', methods=['POST'])
def tts_proxy():
    """
    Proxy para o endpoint original do Kokoro
    """
    try:
        # Repassar request para Kokoro
        response = requests.post(
            f'{KOKORO_URL}/tts',
            json=request.json,
            headers={'Content-Type': 'application/json'}
        )
        
        return response.content, response.status_code, response.headers.items()
        
    except Exception as e:
        logger.error(f"❌ Erro no proxy: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/tts-to-s3', methods=['POST'])
def tts_to_s3():
    """
    Sintetiza com Kokoro e salva direto no MinIO
    
    Body:
    {
        "text": "texto para sintetizar",
        "job_id": "uuid-do-job",
        "chunk_index": 0,
        "voice": "af_sky",
        "speed": 1.0,
        "lang": "pt-br"
    }
    
    Returns:
    {
        "success": true,
        "s3_key": "job-id/chunks/chunk-000.wav",
        "bucket": "darkchannel-jobs",
        "s3_url": "s3://darkchannel-jobs/job-id/chunks/chunk-000.wav"
    }
    """
    try:
        data = request.json if request.is_json else {}
        text = data.get('text', '')
        job_id = data.get('job_id')
        chunk_index = data.get('chunk_index', 0)
        voice = data.get('voice', 'af_sky')
        speed = data.get('speed', 1.0)
        lang = data.get('lang', 'pt-br')
        
        # Validações
        if not text:
            return jsonify({'error': 'No text provided'}), 400
        
        if not job_id:
            return jsonify({'error': 'No job_id provided'}), 400
        
        # Verificar MinIO
        minio_client = get_minio_client()
        if not minio_client:
            return jsonify({'error': 'MinIO not available'}), 503
        
        logger.info(f"🎤 [{job_id}] Kokoro TTS to S3: chunk {chunk_index}")
        
        # Mapear lang para lang_code do Kokoro
        # pt-br -> p, en -> a, es -> e, fr -> f, etc
        lang_map = {
            'pt': 'p', 'pt-br': 'p',
            'en': 'a', 'en-us': 'a', 'en-gb': 'b',
            'es': 'e',
            'fr': 'f',
            'it': 'i',
            'hi': 'h',
            'ja': 'j',
            'zh': 'z'
        }
        lang_code = lang_map.get(lang.lower(), 'p')  # default pt-br
        
        # Chamar Kokoro para gerar áudio (OpenAI compatible endpoint)
        # Nota: Não enviar lang_code, deixar Kokoro detectar pelo texto
        kokoro_response = requests.post(
            f'{KOKORO_URL}/v1/audio/speech',
            json={
                'model': 'kokoro',
                'input': text,
                'voice': voice,
                'speed': speed,
                'response_format': 'wav'
                # stream é False por padrão
            },
            headers={'Content-Type': 'application/json'}
        )
        
        if kokoro_response.status_code != 200:
            return jsonify({
                'error': 'Kokoro TTS failed',
                'details': kokoro_response.text
            }), kokoro_response.status_code
        
        # Salvar áudio em arquivo temporário
        with tempfile.NamedTemporaryFile(suffix='.wav', delete=False) as tmp:
            tmp.write(kokoro_response.content)
            tmp_path = tmp.name
        
        # Upload para MinIO
        bucket = os.getenv('MINIO_BUCKET_JOBS', 'darkchannel-jobs')
        s3_key = f"{job_id}/chunks/chunk-{chunk_index:03d}.wav"
        
        # Metadata S3 só aceita ASCII
        import unicodedata
        text_ascii = unicodedata.normalize('NFKD', text[:100]).encode('ascii', 'ignore').decode('ascii')
        
        success = minio_client.upload_file(
            tmp_path,
            bucket,
            s3_key,
            metadata={
                'job_id': job_id,
                'chunk_index': str(chunk_index),
                'text': text_ascii,
                'voice': voice,
                'lang': lang
            },
            content_type='audio/wav'
        )
        
        # Limpar arquivo temporário
        os.unlink(tmp_path)
        
        if not success:
            return jsonify({'error': 'Failed to upload to MinIO'}), 500
        
        s3_url = f"s3://{bucket}/{s3_key}"
        
        # Gerar URL de download pré-assinada
        download_url = minio_client.generate_presigned_url(bucket, s3_key, expiration=3600)
        download_url = download_url.replace('http://minio:9000', 'http://localhost:9000')
        
        logger.info(f"✅ [{job_id}] Uploaded: {s3_url}")
        
        return jsonify({
            'success': True,
            's3_key': s3_key,
            'bucket': bucket,
            's3_url': s3_url,
            'download_url': download_url,
            'download_expires_in': 3600,
            'chunk_index': chunk_index,
            'job_id': job_id
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Erro: {e}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    logger.info("=" * 60)
    logger.info("🎤 Kokoro TTS Wrapper + MinIO")
    logger.info("=" * 60)
    logger.info("Endpoints disponíveis:")
    logger.info("  GET  /health                        - Health check")
    logger.info("  POST /tts                           - TTS original (proxy)")
    logger.info("  POST /tts-to-s3                     - TTS + MinIO upload")
    logger.info("  GET  /download-url/<job>/<chunk>   - Gerar link download")
    logger.info("=" * 60)
    
    # Iniciar servidor
    app.run(
        host='0.0.0.0',
        port=8881,
        debug=False
    )

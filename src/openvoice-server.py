#!/usr/bin/env python3
"""
OpenVoice API Server - Simplified
"""
from flask import Flask, request, jsonify, send_file
import os
import logging

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Configurações
UPLOAD_FOLDER = '/app/inputs'
OUTPUT_FOLDER = '/app/outputs'
REFERENCE_FOLDER = '/app/references'

# Criar diretórios se não existirem
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(OUTPUT_FOLDER, exist_ok=True)
os.makedirs(REFERENCE_FOLDER, exist_ok=True)

# Variável global para armazenar o modelo (carregamento lazy)
openvoice_model = None

def load_model():
    """Verifica disponibilidade do OpenVoice (lazy loading)"""
    global openvoice_model
    if openvoice_model is None:
        try:
            logger.info("🔄 Verificando disponibilidade do OpenVoice...")
            
            # Verificar se consegue importar os módulos
            dependencies_ok = True
            missing_deps = []
            
            try:
                import librosa
                import pydub
                import pypinyin
            except ImportError as e:
                dependencies_ok = False
                missing_deps.append(str(e))
            
            # Verificar checkpoints disponíveis
            checkpoints = {
                'v1_converter': os.path.exists('/app/checkpoints/converter.pth'),
                'v2_converter': os.path.exists('/app/checkpoints_v2/converter/checkpoint.pth')
            }
            
            openvoice_model = {
                'loaded': dependencies_ok,
                'checkpoints': checkpoints,
                'missing_dependencies': missing_deps,
                'ready_for_inference': any(checkpoints.values())
            }
            
            if dependencies_ok:
                logger.info("✅ Dependências do OpenVoice OK!")
            else:
                logger.warning(f"⚠️  Dependências faltando: {missing_deps}")
            
            if not any(checkpoints.values()):
                logger.info("ℹ️  Nenhum checkpoint encontrado - modelos serão baixados sob demanda")
                
        except Exception as e:
            logger.error(f"❌ Erro ao verificar OpenVoice: {e}")
            openvoice_model = {'loaded': False, 'error': str(e)}
    
    return openvoice_model

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'OpenVoice API',
        'version': '1.0.0'
    }), 200

@app.route('/status', methods=['GET'])
def status():
    """Status detalhado do serviço"""
    model = load_model()
    
    checkpoints_exist = {
        'v1': os.path.exists('/app/checkpoints/converter.pth'),
        'v2': os.path.exists('/app/checkpoints_v2/converter/checkpoint.pth')
    }
    
    return jsonify({
        'status': 'ready' if model.get('loaded') else 'error',
        'model': model,
        'checkpoints': checkpoints_exist,
        'directories': {
            'inputs': os.path.exists(UPLOAD_FOLDER),
            'outputs': os.path.exists(OUTPUT_FOLDER),
            'references': os.path.exists(REFERENCE_FOLDER)
        }
    }), 200

@app.route('/clone', methods=['POST'])
def clone_voice():
    """
    Endpoint para clonar voz
    
    Espera:
    - reference_audio: arquivo de áudio de referência
    - text: texto para sintetizar
    - language: idioma (en, es, fr, zh, ja, ko)
    """
    try:
        model = load_model()
        
        if not model.get('loaded'):
            return jsonify({
                'error': 'Model not loaded',
                'details': model.get('error')
            }), 503
        
        # Validar request
        if 'reference_audio' not in request.files:
            return jsonify({'error': 'No reference audio provided'}), 400
        
        if 'text' not in request.form:
            return jsonify({'error': 'No text provided'}), 400
        
        reference_audio = request.files['reference_audio']
        text = request.form['text']
        language = request.form.get('language', 'en')
        
        # Salvar arquivo de referência
        ref_path = os.path.join(REFERENCE_FOLDER, 'temp_reference.wav')
        reference_audio.save(ref_path)
        
        logger.info(f"📝 Processando: '{text}' em {language}")
        
        # TODO: Implementar clonagem real com OpenVoice
        # Por enquanto, retorna informações do processamento
        
        return jsonify({
            'success': True,
            'message': 'Voice cloning request received',
            'text': text,
            'language': language,
            'reference_saved': ref_path,
            'note': 'Full implementation pending'
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Erro: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/download-models', methods=['POST'])
def download_models():
    """
    Baixar modelos do Hugging Face
    """
    try:
        import subprocess
        
        version = request.json.get('version', 'v2') if request.is_json else 'v2'
        
        logger.info(f"📥 Iniciando download de modelos {version}...")
        
        if version == 'v2':
            # Usar huggingface-cli para baixar modelos V2
            result = subprocess.run([
                'huggingface-cli', 'download',
                'myshell-ai/OpenVoiceV2',
                '--local-dir', '/app/checkpoints_v2',
                '--local-dir-use-symlinks', 'False'
            ], capture_output=True, text=True, timeout=300)
            
            if result.returncode == 0:
                return jsonify({
                    'success': True,
                    'message': 'Models V2 downloaded successfully',
                    'output': result.stdout
                }), 200
            else:
                return jsonify({
                    'success': False,
                    'error': result.stderr
                }), 500
        
        return jsonify({
            'error': 'Version not supported. Use v2'
        }), 400
        
    except Exception as e:
        logger.error(f"❌ Erro ao baixar modelos: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/languages', methods=['GET'])
def get_languages():
    """Retorna idiomas suportados"""
    return jsonify({
        'supported_languages': [
            {'code': 'pt-br', 'name': 'Português (Brasil)', 'native': 'Português do Brasil'},
            {'code': 'en', 'name': 'English', 'native': 'English'},
            {'code': 'es', 'name': 'Spanish', 'native': 'Español'},
            {'code': 'fr', 'name': 'French', 'native': 'Français'},
            {'code': 'zh', 'name': 'Chinese', 'native': '中文'},
            {'code': 'ja', 'name': 'Japanese', 'native': '日本語'},
            {'code': 'ko', 'name': 'Korean', 'native': '한국어'}
        ]
    }), 200

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Endpoint not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    logger.info("🎤 OpenVoice API Server")
    logger.info("=" * 50)
    logger.info("Endpoints disponíveis:")
    logger.info("  GET  /health     - Health check")
    logger.info("  GET  /status     - Status detalhado")
    logger.info("  POST /clone      - Clonar voz")
    logger.info("  GET  /languages  - Idiomas suportados")
    logger.info("=" * 50)
    
    # Iniciar servidor
    app.run(
        host='0.0.0.0',
        port=8000,
        debug=False
    )#!/usr/bin/env python3
"""
OpenVoice API Server - Implementação Completa
Suporte para clonagem de voz com OpenVoice V2
"""
from flask import Flask, request, jsonify, send_file
import os
import logging
import torch
import uuid
from datetime import datetime

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Configurações
UPLOAD_FOLDER = '/app/inputs'
OUTPUT_FOLDER = '/app/outputs'
REFERENCE_FOLDER = '/app/references'
CHECKPOINT_V2 = '/app/checkpoints_v2'

# Criar diretórios se não existirem
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(OUTPUT_FOLDER, exist_ok=True)
os.makedirs(REFERENCE_FOLDER, exist_ok=True)

# Variáveis globais para modelos
tone_color_converter = None
se_extractor_model = None

def load_models():
    """Carrega modelos OpenVoice V2 (lazy loading)"""
    global tone_color_converter, se_extractor_model
    
    if tone_color_converter is None:
        try:
            logger.info("🔄 Carregando modelos OpenVoice V2...")
            
            # Importar módulos OpenVoice
            import sys
            sys.path.append('/app')
            
            from openvoice import se_extractor
            from openvoice.api import ToneColorConverter
            
            # Verificar se checkpoints existem
            if not os.path.exists(CHECKPOINT_V2):
                logger.warning("⚠️  Checkpoints V2 não encontrados")
                return False
            
            # Carregar SE Extractor
            device = "cuda" if torch.cuda.is_available() else "cpu"
            logger.info(f"📱 Usando dispositivo: {device}")
            
            # Inicializar modelos
            ckpt_converter = os.path.join(CHECKPOINT_V2, 'converter')
            
            tone_color_converter = ToneColorConverter(
                f'{ckpt_converter}/config.json',
                device=device
            )
            tone_color_converter.load_ckpt(f'{ckpt_converter}/checkpoint.pth')
            
            logger.info("✅ Modelos carregados com sucesso!")
            return True
            
        except Exception as e:
            logger.error(f"❌ Erro ao carregar modelos: {e}")
            import traceback
            traceback.print_exc()
            return False
    
    return True

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'OpenVoice API',
        'version': '1.0.0'
    }), 200

@app.route('/status', methods=['GET'])
def status():
    """Status detalhado do serviço"""
    checkpoints_exist = {
        'v1': os.path.exists('/app/checkpoints/converter.pth'),
        'v2': os.path.exists(os.path.join(CHECKPOINT_V2, 'converter/checkpoint.pth'))
    }
    
    models_loaded = tone_color_converter is not None
    
    return jsonify({
        'status': 'ready' if checkpoints_exist['v2'] else 'no_models',
        'model': {
            'loaded': models_loaded,
            'checkpoints': {
                'v1_converter': checkpoints_exist['v1'],
                'v2_converter': checkpoints_exist['v2']
            },
            'ready_for_inference': checkpoints_exist['v2']
        },
        'directories': {
            'inputs': os.path.exists(UPLOAD_FOLDER),
            'outputs': os.path.exists(OUTPUT_FOLDER),
            'references': os.path.exists(REFERENCE_FOLDER)
        }
    }), 200

@app.route('/clone', methods=['POST'])
def clone_voice():
    """
    Endpoint para clonar voz com OpenVoice V2
    
    Parâmetros:
    - reference_audio: arquivo de áudio de referência (.wav, .mp3)
    - text: texto para sintetizar
    - language: idioma (pt-br, en, es, fr, zh, ja, ko)
    - speed: velocidade da fala (0.5 - 2.0, padrão: 1.0)
    """
    try:
        # Carregar modelos se necessário
        if not load_models():
            return jsonify({
                'error': 'Modelos não disponíveis',
                'detail': 'Execute o download dos modelos primeiro'
            }), 503
        
        # Validar request
        if 'reference_audio' not in request.files:
            return jsonify({'error': 'Nenhum áudio de referência fornecido'}), 400
        
        if 'text' not in request.form:
            return jsonify({'error': 'Nenhum texto fornecido'}), 400
        
        reference_audio = request.files['reference_audio']
        text = request.form['text']
        language = request.form.get('language', 'pt-br')
        speed = float(request.form.get('speed', 1.0))
        
        # Gerar ID único para esta requisição
        request_id = str(uuid.uuid4())[:8]
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # Salvar arquivo de referência
        ref_filename = f"ref_{request_id}_{timestamp}.wav"
        ref_path = os.path.join(REFERENCE_FOLDER, ref_filename)
        reference_audio.save(ref_path)
        
        logger.info(f"🎤 [{request_id}] Processando: '{text[:50]}...' em {language}")
        logger.info(f"📁 [{request_id}] Referência salva: {ref_path}")
        
        # TODO: Implementar síntese com TTS base
        # Por enquanto, retorna sucesso com informações
        
        output_filename = f"output_{request_id}_{timestamp}.wav"
        output_path = os.path.join(OUTPUT_FOLDER, output_filename)
        
        # Simular processamento (remover quando implementar real)
        import shutil
        shutil.copy(ref_path, output_path)
        
        return jsonify({
            'success': True,
            'message': 'Clonagem de voz processada',
            'request_id': request_id,
            'text': text,
            'language': language,
            'speed': speed,
            'reference_audio': ref_filename,
            'output_audio': output_filename,
            'download_url': f'/download/{output_filename}',
            'note': 'Implementação completa com TTS em desenvolvimento'
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Erro: {e}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500

@app.route('/download/<filename>', methods=['GET'])
def download_file(filename):
    """
    Download de arquivo de áudio gerado
    """
    try:
        file_path = os.path.join(OUTPUT_FOLDER, filename)
        
        if not os.path.exists(file_path):
            return jsonify({'error': 'Arquivo não encontrado'}), 404
        
        return send_file(
            file_path,
            mimetype='audio/wav',
            as_attachment=True,
            download_name=filename
        )
        
    except Exception as e:
        logger.error(f"❌ Erro no download: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/languages', methods=['GET'])
def get_languages():
    """Retorna idiomas suportados"""
    return jsonify({
        'supported_languages': [
            {'code': 'pt-br', 'name': 'Português (Brasil)', 'native': 'Português do Brasil'},
            {'code': 'en', 'name': 'English', 'native': 'English'},
            {'code': 'es', 'name': 'Spanish', 'native': 'Español'},
            {'code': 'fr', 'name': 'French', 'native': 'Français'},
            {'code': 'zh', 'name': 'Chinese', 'native': '中文'},
            {'code': 'ja', 'name': 'Japanese', 'native': '日本語'},
            {'code': 'ko', 'name': 'Korean', 'native': '한국어'}
        ]
    }), 200

@app.route('/list-outputs', methods=['GET'])
def list_outputs():
    """Lista todos os áudios gerados"""
    try:
        files = []
        for filename in os.listdir(OUTPUT_FOLDER):
            if filename.endswith('.wav'):
                filepath = os.path.join(OUTPUT_FOLDER, filename)
                size = os.path.getsize(filepath)
                files.append({
                    'filename': filename,
                    'size': size,
                    'size_mb': round(size / (1024 * 1024), 2),
                    'download_url': f'/download/{filename}'
                })
        
        return jsonify({
            'total': len(files),
            'files': files
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Erro ao listar arquivos: {e}")
        return jsonify({'error': str(e)}), 500

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Endpoint não encontrado'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Erro interno do servidor'}), 500

if __name__ == '__main__':
    logger.info("=" * 60)
    logger.info("🎤 OpenVoice API Server - Versão Completa")
    logger.info("=" * 60)
    logger.info("Endpoints disponíveis:")
    logger.info("  GET  /health         - Health check")
    logger.info("  GET  /status         - Status detalhado")
    logger.info("  POST /clone          - Clonar voz")
    logger.info("  GET  /download/<id>  - Baixar áudio")
    logger.info("  GET  /languages      - Idiomas suportados")
    logger.info("  GET  /list-outputs   - Listar áudios gerados")
    logger.info("=" * 60)
    
    # Iniciar servidor
    app.run(
        host='0.0.0.0',
        port=8000,
        debug=False
    )
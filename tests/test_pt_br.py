#!/usr/bin/env python3
"""
Teste rápido da API OpenVoice em Português
"""
import requests
import json

BASE_URL = "http://localhost:8000"

def test_languages():
    """Testa idiomas - deve mostrar PT-BR"""
    print("=" * 60)
    print("🇧🇷 Testando Idiomas Suportados")
    print("=" * 60)
    
    response = requests.get(f"{BASE_URL}/languages")
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print("\n📋 Idiomas disponíveis:")
        for lang in data['supported_languages']:
            flag = "🇧🇷" if lang['code'] == 'pt-br' else "🌍"
            print(f"  {flag} {lang['code']:8} - {lang['name']:20} ({lang.get('native', '')})")
    
    print()

def test_status():
    """Verifica status do servidor"""
    print("=" * 60)
    print("🔍 Status do Servidor")
    print("=" * 60)
    
    response = requests.get(f"{BASE_URL}/status")
    
    if response.status_code == 200:
        data = response.json()
        print(f"Status: {data['status']}")
        print(f"Modelos carregados: {data['model']['loaded']}")
        print(f"Pronto para inferência: {data['model'].get('ready_for_inference', False)}")
        
        if data['model'].get('checkpoints'):
            print("\n📦 Checkpoints:")
            for key, value in data['model']['checkpoints'].items():
                status = "✅" if value else "❌"
                print(f"  {status} {key}: {value}")
    
    print()

def test_clone_simple():
    """Testa endpoint de clone (sem áudio real)"""
    print("=" * 60)
    print("🎤 Teste de Clone (sem áudio)")
    print("=" * 60)
    
    # Criar um arquivo de áudio fake para teste
    import io
    fake_audio = io.BytesIO(b"fake audio data")
    fake_audio.name = "test.wav"
    
    files = {
        'reference_audio': fake_audio
    }
    data = {
        'text': 'Olá! Este é um teste em português do Brasil.',
        'language': 'pt-br'
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/clone",
            files=files,
            data=data
        )
        
        print(f"Status: {response.status_code}")
        print("\n📄 Resposta:")
        print(json.dumps(response.json(), indent=2, ensure_ascii=False))
        
    except Exception as e:
        print(f"❌ Erro: {e}")
    
    print()

def main():
    print("\n")
    print("🇧🇷" * 30)
    print("   TESTE API OPENVOICE - PORTUGUÊS BRASIL")
    print("🇧🇷" * 30)
    print()
    
    try:
        # Teste 1: Idiomas
        test_languages()
        
        # Teste 2: Status
        test_status()
        
        # Teste 3: Clone (básico)
        test_clone_simple()
        
        print("=" * 60)
        print("✅ Testes concluídos!")
        print("=" * 60)
        print()
        
    except requests.exceptions.ConnectionError:
        print("❌ Erro: Não foi possível conectar ao servidor")
        print("   Verifique se o container está rodando:")
        print("   docker-compose -f docker-compose.simple.yml ps")
        print()
    except Exception as e:
        print(f"❌ Erro inesperado: {e}")
        print()

if __name__ == "__main__":
    main()
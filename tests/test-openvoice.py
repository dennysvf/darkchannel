#!/usr/bin/env python3
"""
Script de teste para OpenVoice API
"""
import requests
import json

BASE_URL = "http://localhost:8000"

def test_health():
    """Testa health check"""
    print("🔍 Testando Health Check...")
    response = requests.get(f"{BASE_URL}/health")
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")
    print()

def test_status():
    """Testa status detalhado"""
    print("🔍 Testando Status...")
    response = requests.get(f"{BASE_URL}/status")
    print(f"Status: {response.status_code}")
    print(json.dumps(response.json(), indent=2))
    print()

def test_languages():
    """Testa idiomas suportados"""
    print("🔍 Testando Idiomas...")
    response = requests.get(f"{BASE_URL}/languages")
    print(f"Status: {response.status_code}")
    print(json.dumps(response.json(), indent=2))
    print()

def test_clone_voice(reference_audio_path, text, language='pt-br'):
    """
    Testa clonagem de voz
    
    Args:
        reference_audio_path: Caminho para arquivo de áudio de referência
        text: Texto para sintetizar
        language: Idioma (pt-br, en, es, fr, zh, ja, ko)
    """
    print("🎤 Testando Voice Cloning...")
    
    try:
        with open(reference_audio_path, 'rb') as audio_file:
            files = {
                'reference_audio': audio_file
            }
            data = {
                'text': text,
                'language': language
            }
            
            response = requests.post(
                f"{BASE_URL}/clone",
                files=files,
                data=data
            )
            
            print(f"Status: {response.status_code}")
            print(json.dumps(response.json(), indent=2, ensure_ascii=False))
            print()
            
    except FileNotFoundError:
        print(f"❌ Arquivo não encontrado: {reference_audio_path}")
        print("ℹ️  Forneça um arquivo de áudio válido para testar")
        print()

if __name__ == "__main__":
    print("=" * 60)
    print("🧪 Testando OpenVoice API")
    print("=" * 60)
    print()
    
    # Testes básicos
    test_health()
    test_status()
    test_languages()
    
    # Teste de clonagem (opcional - requer arquivo de áudio)
    # Descomente e forneça um arquivo .wav de referência
    # test_clone_voice('reference.wav', 'Hello, this is a test!', 'en')
    
    print("=" * 60)
    print("✅ Testes concluídos!")
    print("=" * 60)
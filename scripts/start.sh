#!/bin/bash

echo "========================================"
echo " DarkChannel Stack - Iniciando..."
echo "========================================"
echo ""

# Verificar se Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo "[ERRO] Docker não está rodando!"
    echo "Por favor, inicie o Docker e tente novamente."
    exit 1
fi

echo "[OK] Docker está rodando"
echo ""

echo "Iniciando containers..."
docker-compose up -d

if [ $? -ne 0 ]; then
    echo ""
    echo "[ERRO] Falha ao iniciar os containers!"
    echo "Verifique os logs com: docker-compose logs"
    exit 1
fi

echo ""
echo "========================================"
echo " Stack iniciada com sucesso!"
echo "========================================"
echo ""
echo "Serviços disponíveis:"
echo "  - N8N:        http://localhost:5678"
echo "  - Kokoro TTS: http://localhost:8880"
echo "  - PostgreSQL: localhost:5432"
echo ""
echo "Aguarde ~30 segundos para os serviços iniciarem completamente."
echo ""
echo "Para ver os logs: docker-compose logs -f"
echo "Para parar: docker-compose down"
echo ""

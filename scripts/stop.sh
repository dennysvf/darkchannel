#!/bin/bash

echo "========================================"
echo " DarkChannel Stack - Parando..."
echo "========================================"
echo ""

docker-compose down

if [ $? -ne 0 ]; then
    echo ""
    echo "[ERRO] Falha ao parar os containers!"
    exit 1
fi

echo ""
echo "========================================"
echo " Stack parada com sucesso!"
echo "========================================"
echo ""
echo "Seus dados foram preservados."
echo "Para iniciar novamente, execute: ./start.sh"
echo ""

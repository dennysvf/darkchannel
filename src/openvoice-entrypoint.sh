#!/bin/bash
set -e

echo "🚀 Iniciando OpenVoice..."
echo "ℹ️  Modo: Servidor API sem modelos pré-carregados"
echo "ℹ️  Os modelos serão baixados sob demanda quando necessário"

# Criar diretórios se não existirem
mkdir -p /app/checkpoints
mkdir -p /app/checkpoints_v2
mkdir -p /app/inputs
mkdir -p /app/outputs
mkdir -p /app/references

echo "✅ Diretórios criados!"
echo "🎤 Iniciando servidor OpenVoice na porta 8000..."
echo ""

# Executar comando passado como argumento
exec "$@"
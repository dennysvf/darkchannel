#!/bin/bash
set -e

echo "Starting OpenVoice..."
echo "Mode: API Server without pre-loaded models"
echo "Models will be downloaded on demand"

# Create directories if they don't exist
mkdir -p /app/checkpoints
mkdir -p /app/checkpoints_v2
mkdir -p /app/inputs
mkdir -p /app/outputs
mkdir -p /app/references

echo "Directories created!"
echo "Starting OpenVoice server on port 8000..."
echo ""

# Execute command passed as argument
exec "$@"
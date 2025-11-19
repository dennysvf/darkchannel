#!/bin/bash

# Script de teste para o workflow SSML + OpenVoice
# Autor: DarkChannel Stack
# Data: 2025-11-09

echo "🎙️ Testando Workflow: SSML + OpenVoice"
echo "========================================"
echo ""

# URL do webhook N8N
WEBHOOK_URL="http://localhost:5678/webhook/audiobook"

# Teste 1: Audiolivro Simples
echo "📖 TESTE 1: Audiolivro Simples"
echo "------------------------------"
curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Era uma vez, em um reino distante, um jovem príncipe chamado Pedro. Ele era muito corajoso e destemido.",
    "chapter_title": "Capítulo 1: O Príncipe Corajoso"
  }' | jq '.'
echo ""
echo ""

# Teste 2: Com SSML Avançado
echo "🎭 TESTE 2: SSML Avançado (Prosódia)"
echo "------------------------------------"
curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "<prosody rate=\"slow\" pitch=\"-2\">Era uma vez, em um reino distante,</prosody><break time=\"1s\"/>um jovem príncipe chamado <phoneme alphabet=\"ipa\" ph=\"ˈpedɾu\">Pedro</phoneme>.<break time=\"1.5s\"/><prosody rate=\"fast\" pitch=\"+1\">Ele era muito corajoso!</prosody>",
    "chapter_title": "Capítulo 1: O Início"
  }' | jq '.'
echo ""
echo ""

# Teste 3: Diálogo
echo "💬 TESTE 3: Diálogo Dramatizado"
echo "-------------------------------"
curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "<prosody rate=\"0.9\">João olhou para Maria e disse:</prosody><break time=\"0.5s\"/><prosody rate=\"slow\" pitch=\"-2\">\"Precisamos conversar sobre o que aconteceu.\"</prosody><break time=\"1s\"/><prosody rate=\"1.1\" pitch=\"+1\">\"Eu sei\", Maria respondeu nervosamente.</prosody>",
    "chapter_title": "Capítulo 5: A Conversa"
  }' | jq '.'
echo ""
echo ""

# Teste 4: Narração de Notícias
echo "📰 TESTE 4: Narração de Notícias"
echo "--------------------------------"
curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "<prosody rate=\"1.1\">Bom dia! Estas são as principais notícias de hoje.</prosody><break time=\"1s\"/><prosody rate=\"1.0\">Primeira notícia: O mercado financeiro apresentou alta de 2% hoje.</prosody><break time=\"0.5s\"/><prosody rate=\"1.0\">Segunda notícia: Previsão do tempo indica chuvas para o fim de semana.</prosody>",
    "chapter_title": "Notícias - 09/11/2025"
  }' | jq '.'
echo ""
echo ""

# Teste 5: Audiolivro Complexo
echo "📚 TESTE 5: Audiolivro Complexo (Múltiplas Emoções)"
echo "---------------------------------------------------"
curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "<prosody rate=\"0.9\">Capítulo Três: A Descoberta</prosody><break time=\"2.5s\"/><prosody rate=\"slow\" pitch=\"-1\">A noite estava escura e silenciosa.</prosody><break time=\"1s\"/>Pedro caminhava pelas ruas desertas, quando de repente...<break time=\"1.5s\"/><prosody rate=\"fast\" pitch=\"+2\"><emphasis level=\"strong\">Um grito ecoou pela cidade!</emphasis></prosody><break time=\"2s\"/><prosody rate=\"0.8\" pitch=\"-2\">\"O que foi aquilo?\", ele pensou, com o coração acelerado.</prosody>",
    "chapter_title": "Capítulo 3: A Descoberta"
  }' | jq '.'
echo ""
echo ""

echo "✅ Todos os testes concluídos!"
echo ""
echo "📊 Resumo:"
echo "  - 5 testes executados"
echo "  - Verifique os logs do N8N para detalhes"
echo "  - Áudios gerados em: /tmp/audiobook_*.mp3"
echo ""

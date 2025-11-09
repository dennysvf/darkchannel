# ADR 001 — Escolha do OpenVoice sem GPU para narração de audiolivros

**Status**: Aceito  
**Data**: 2025-11-08  
**Decisores**: DarkChannel Team  

---

## Contexto

O projeto visa permitir que o autor narre o próprio livro, mas com aprimoramento de voz utilizando técnicas de clonagem e melhoria vocal. A solução precisa ser executável localmente, sem necessidade de GPU dedicada, e integrável em pipelines de automação e publicação (como geração de audiolivros, vídeos narrados e material multimídia).

Foram consideradas alternativas como **Kokoro**, **Bark**, **TTS do OpenAI**, e **coqui-ai/TTS**, mas todas apresentaram limitações de custo, emoção, ou dependência de GPU.

---

## Decisão

Optou-se pelo uso do **OpenVoice**, executando em ambiente **Docker sem GPU**.

### Motivos da escolha:

1. **Execução em CPU** — O modelo oferece suporte à execução eficiente sem necessidade de GPU, reduzindo custos de infraestrutura.

2. **Facilidade de implantação** — A imagem Docker é simples de configurar, podendo ser integrada a pipelines CI/CD ou rodar em VPSs de baixo custo.

3. **Alta qualidade vocal** — Mesmo em CPU, o OpenVoice entrega vozes naturais e com timbre expressivo, superiores a soluções puramente TTS.

4. **Suporte a clonagem de voz** — Permite capturar características únicas da voz do autor, preservando identidade vocal.

5. **Flexibilidade de controle** — Parâmetros ajustáveis (tom, velocidade, ritmo) permitem gerar variações sutis de emoção.

6. **Open Source e ativo** — Projeto mantido pela comunidade, com possibilidade de extensão e customização.

---

## Alternativas Consideradas

| Alternativa | Prós | Contras |
|-------------|------|---------|
| **Kokoro** | Instalação leve | Falta de emoção e personalização vocal |
| **Bark (Suno)** | Alta fidelidade e emoção | Exige GPU e tempo de processamento alto |
| **OpenAI TTS** | Qualidade premium e emoção natural | API paga e sem controle total local |
| **Coqui TTS** | Open-source e bom controle | Modelos pesados, dependência de GPU para melhor qualidade |

---

## Consequências

### Positivas:
- ✅ Permite rodar localmente sem custos de GPU
- ✅ Pode ser automatizado dentro de containers
- ✅ Escalável em infraestrutura modesta (ex: VPS ou cloud instance CPU-only)
- ✅ Integração nativa com N8N para workflows automatizados
- ✅ Clonagem de voz preserva identidade do autor

### Negativas:
- ⚠️ Tempo de processamento maior em relação a soluções com GPU
- ⚠️ Emoções ainda limitadas comparadas a modelos mais caros (ex: OpenAI ou ElevenLabs)
- ⚠️ Requer ajuste fino de parâmetros para obter melhor resultado

---

## Implementação Técnica

### Arquitetura da Stack

```
┌─────────────────┐
│      N8N        │ ← Orquestração de workflows
└────────┬────────┘
         │
         ├──────────► PostgreSQL (Dados)
         │
         ├──────────► Kokoro TTS (Voz sintética rápida)
         │
         └──────────► OpenVoice (Clonagem e aprimoramento)
```

### Container OpenVoice

O OpenVoice será executado como um serviço HTTP REST, permitindo:
- Upload de áudio de referência (voz do autor)
- Geração de áudio com voz clonada
- Ajuste de parâmetros (tom, velocidade, emoção)

### Integração com N8N

Workflows típicos:
1. **Narração de capítulo**: Texto → OpenVoice → Áudio MP3
2. **Clonagem de voz**: Áudio referência → Modelo treinado → Armazenamento
3. **Geração em lote**: Lista de textos → Processamento paralelo → Audiolivro completo

---

## Próximos Passos

- [x] Criar ADR documentando a decisão
- [ ] Adicionar OpenVoice ao docker-compose.simple.yml
- [ ] Criar Dockerfile otimizado para CPU
- [ ] Documentar API endpoints e parâmetros
- [ ] Criar workflows de exemplo no N8N
- [ ] Testar ajustes de prosódia e ritmo
- [ ] Integrar pipeline de geração automática de capítulos

---

## Referências

- **OpenVoice GitHub**: https://github.com/myshell-ai/OpenVoice
- **Paper**: Instant Voice Cloning with OpenVoice
- **Demo**: https://research.myshell.ai/open-voice

---

## Revisões

| Data | Autor | Mudança |
|------|-------|---------|
| 2025-11-08 | DarkChannel | Criação inicial do ADR |

---

**Decisão aprovada por**: DarkChannel Team  
**Implementação**: Em andamento

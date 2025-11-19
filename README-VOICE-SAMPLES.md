# 🎤 Guia de Voice Samples - CETUC Dataset

## 📋 Sobre o CETUC

O **CETUC (Centro de Estudos em Telecomunicações da PUC-Rio)** é um dos melhores datasets de voz em Português do Brasil disponíveis.

### Características:
- 👥 **101 locutores** (50 homens, 51 mulheres)
- 📝 **1.000 sentenças** por locutor
- ⏱️ **~143 horas** de áudio total
- 🎤 **Qualidade profissional** (16kHz, ambiente controlado)
- 🇧🇷 **Português do Brasil** nativo

---

## 🚀 Como Baixar

### Opção 1: Script Automatizado (Recomendado)

```powershell
.\download-cetuc-samples.ps1
```

Este script:
1. ✅ Instala DVC automaticamente
2. ✅ Clona o repositório FalaBrasil
3. ✅ Baixa samples selecionados
4. ✅ Organiza em categorias

### Opção 2: Manual

```bash
# 1. Criar ambiente Python
python -m venv venv-cetuc
.\venv-cetuc\Scripts\Activate.ps1

# 2. Instalar DVC
pip install "dvc[gdrive]"

# 3. Clonar repositório
git clone https://github.com/falabrasil/speech-datasets.git
cd speech-datasets

# 4. Baixar dataset
dvc pull -r public
```

---

## 👥 Locutores Selecionados

### Mulheres (6 vozes)

| Locutor | Idade Aprox. | Características | Uso Recomendado |
|---------|--------------|-----------------|-----------------|
| `Andrea_F003` | Adulta (30-40) | Profissional, clara | Corporativo, apresentações |
| `Mariana_F024` | Jovem (20-30) | Energética, moderna | Conteúdo jovem, redes sociais |
| `IvoneAmitrano_F000` | Madura (40-50) | Experiente, confiável | Documentários, educação |
| `Gabriela_F034` | Jovem (20-30) | Suave, amigável | Audiolivros, narrativas |
| `TerezaSpedo_F041` | Idosa (60+) | Sábia, acolhedora | Histórias, contos |
| `SandraRocha_F011` | Adulta (30-40) | Versátil, natural | Uso geral |

### Homens (6 vozes)

| Locutor | Idade Aprox. | Características | Uso Recomendado |
|---------|--------------|-----------------|-----------------|
| `Paulinho_M000` | Adulto (30-40) | Grave, autoritário | Notícias, documentários |
| `DanielRibeiro_M002` | Jovem (20-30) | Enérgico, dinâmico | Esportes, ação |
| `Oswaldo_M012` | Maduro (40-50) | Profundo, sério | Conteúdo formal |
| `JeanCarlos_M019` | Jovem (20-30) | Casual, amigável | Podcasts, conversas |
| `JoseIldo_M024` | Idoso (60+) | Sereno, experiente | Histórias, reflexões |
| `HenriqueMafra_M046` | Adulto (30-40) | Versátil, claro | Uso geral |

---

## 📦 Estrutura dos Arquivos

Após o download, os arquivos estarão organizados assim:

```
references/
└── cetuc/
    ├── Andrea_F003/
    │   ├── audio_001.wav
    │   ├── audio_002.wav
    │   └── ... (10 arquivos)
    ├── Paulinho_M000/
    │   ├── audio_001.wav
    │   └── ...
    └── ... (outros locutores)
```

---

## 🎯 Como Usar com OpenVoice

### 1. Copiar para Container

```powershell
docker cp references/cetuc/ openvoice:/app/references/
```

### 2. Testar Clonagem

```powershell
# Usar script de teste
.\test-voice-cloning.ps1

# Ou manualmente
curl -X POST http://localhost:8000/clone \
  -F "reference_audio=@references/cetuc/Andrea_F003/audio_001.wav" \
  -F "text=Olá! Esta é uma voz clonada do CETUC." \
  -F "language=pt-br"
```

### 3. Exemplo Python

```python
import requests

# Selecionar voz
reference_audio = "references/cetuc/Paulinho_M000/audio_001.wav"

url = "http://localhost:8000/clone"
files = {
    'reference_audio': open(reference_audio, 'rb')
}
data = {
    'text': 'Olá! Esta é uma demonstração de clonagem de voz.',
    'language': 'pt-br',
    'speed': 1.0
}

response = requests.post(url, files=files, data=data)
result = response.json()

print(f"✅ Voz clonada: {result['output_audio']}")
print(f"🔗 Download: {result['download_url']}")
```

---

## 💡 Dicas de Uso

### Seleção de Voz

1. **Corporativo/Profissional:** `Andrea_F003`, `Paulinho_M000`
2. **Jovem/Moderno:** `Mariana_F024`, `DanielRibeiro_M002`
3. **Narrativas/Histórias:** `Gabriela_F034`, `TerezaSpedo_F041`
4. **Documentários:** `IvoneAmitrano_F000`, `Oswaldo_M012`
5. **Casual/Podcasts:** `SandraRocha_F011`, `JeanCarlos_M019`

### Qualidade do Áudio de Referência

✅ **Bom:**
- Usar arquivos originais do CETUC (16kHz, limpos)
- Sentenças completas (3-5 segundos)
- Múltiplos arquivos para melhor resultado

❌ **Evitar:**
- Arquivos com ruído
- Trechos muito curtos (<1 segundo)
- Áudio comprimido demais

---

## 📊 Tamanhos e Tempos

| Item | Tamanho | Tempo Estimado |
|------|---------|----------------|
| 1 locutor completo | ~150-200MB | 5-10 min |
| 12 locutores selecionados | ~2-3GB | 30-60 min |
| Dataset completo (101) | ~50-100GB | 3-6 horas |

---

## 🔧 Troubleshooting

### Erro: "Authentication required"

```bash
# Configurar credenciais Google Drive
dvc remote modify public gdrive_use_service_account false
dvc pull -r public
# Seguir instruções de autenticação no navegador
```

### Erro: "Disk space"

- Libere pelo menos 5GB de espaço
- Ou baixe apenas alguns locutores específicos

### Download muito lento

- Use conexão estável
- Baixe em horários de menor tráfego
- Considere baixar em lotes menores

---

## 📚 Referências

- **Dataset:** [FalaBrasil Speech Datasets](https://github.com/falabrasil/speech-datasets)
- **Paper:** [CETUC Dataset Description](https://ppgcc.propesp.ufpa.br/)
- **DVC:** [Data Version Control](https://dvc.org/)

---

## 🎯 Próximos Passos

1. ✅ Baixar samples do CETUC
2. ✅ Testar clonagem com diferentes vozes
3. ✅ Criar biblioteca personalizada
4. 🚀 Integrar com workflow N8N

---

**Criado para DarkChannel Stack** 🎯  
**Versão**: 1.0.0  
**Data**: 09/11/2025

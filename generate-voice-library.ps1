# Generate Voice Library with Kokoro TTS
# Script para gerar biblioteca diversificada de vozes em português do Brasil

Write-Host "`n🎤 Gerando Biblioteca de Vozes - Kokoro TTS`n" -ForegroundColor Cyan

# Criar estrutura de diretórios
$refDir = "references"
$categories = @("adultos", "jovens", "criancas", "idosos", "personagens", "especiais")

Write-Host "📁 Criando estrutura de diretórios...`n" -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $refDir | Out-Null
foreach ($cat in $categories) {
    New-Item -ItemType Directory -Force -Path "$refDir/$cat" | Out-Null
}

# Biblioteca completa de vozes
$voiceLibrary = @(
    # === ADULTOS ===
    @{
        category = "adultos"
        name = "feminina-profissional"
        voice = "af_sarah"
        speed = 1.0
        description = "Mulher adulta, profissional, clara"
        text = "Olá! Sou uma profissional experiente. Minha voz é clara e confiável, perfeita para apresentações e conteúdo corporativo."
    },
    @{
        category = "adultos"
        name = "feminina-suave"
        voice = "af_nicole"
        speed = 0.95
        description = "Mulher adulta, suave, amigável"
        text = "Oi! Eu tenho uma voz suave e acolhedora. Gosto de contar histórias e fazer as pessoas se sentirem confortáveis."
    },
    @{
        category = "adultos"
        name = "feminina-expressiva"
        voice = "af_bella"
        speed = 1.0
        description = "Mulher adulta, calorosa, expressiva"
        text = "Olá queridos! Minha voz é calorosa e cheia de emoção. Perfeita para histórias e podcasts envolventes."
    },
    @{
        category = "adultos"
        name = "masculina-grave"
        voice = "am_adam"
        speed = 0.9
        description = "Homem adulto, grave, autoritário"
        text = "Bom dia. Minha voz é profunda e autoritária. Ideal para documentários, notícias e conteúdo sério."
    },
    @{
        category = "adultos"
        name = "masculina-energica"
        voice = "am_michael"
        speed = 1.05
        description = "Homem adulto, enérgico, dinâmico"
        text = "E aí, pessoal! Sou cheio de energia e entusiasmo! Perfeito para esportes, ação e conteúdo dinâmico!"
    },
    @{
        category = "adultos"
        name = "masculina-calma"
        voice = "am_eric"
        speed = 0.9
        description = "Homem adulto, calmo, confiável"
        text = "Olá. Minha voz é calma e tranquilizadora. Ideal para meditação, relaxamento e conteúdo reflexivo."
    },
    
    # === JOVENS ===
    @{
        category = "jovens"
        name = "jovem-feminina-animada"
        voice = "af_sky"
        speed = 1.15
        description = "Jovem mulher, animada, energética"
        text = "Oi gente! Eu sou super animada e adoro conversar! Vamos fazer algo divertido juntos! Vai ser incrível!"
    },
    @{
        category = "jovens"
        name = "jovem-feminina-moderna"
        voice = "af_bella"
        speed = 1.1
        description = "Jovem mulher, moderna, descolada"
        text = "E aí, tudo bem? Eu sou bem descolada e gosto de coisas modernas. Bora criar conteúdo massa!"
    },
    @{
        category = "jovens"
        name = "jovem-masculino-casual"
        voice = "am_michael"
        speed = 1.15
        description = "Jovem homem, casual, amigável"
        text = "Fala galera! Sou bem tranquilo e gosto de bater papo. Vamos trocar uma ideia legal aqui!"
    },
    @{
        category = "jovens"
        name = "jovem-masculino-gamer"
        voice = "am_adam"
        speed = 1.2
        description = "Jovem homem, gamer, empolgado"
        text = "Salve, pessoal! Preparados para a gameplay? Vamos dominar esse jogo juntos! Partiu!"
    },
    
    # === CRIANÇAS (simuladas com vozes agudas e rápidas) ===
    @{
        category = "criancas"
        name = "crianca-feminina-alegre"
        voice = "af_sky"
        speed = 1.35
        description = "Menina, alegre, curiosa"
        text = "Oi! Eu adoro brincar e aprender coisas novas! Vamos ser amigos? Eu gosto muito de desenhar!"
    },
    @{
        category = "criancas"
        name = "crianca-feminina-timida"
        voice = "af_nicole"
        speed = 1.3
        description = "Menina, tímida, doce"
        text = "Olá... eu sou um pouquinho tímida, mas gosto muito de histórias e desenhos. Você também gosta?"
    },
    @{
        category = "criancas"
        name = "crianca-masculina-arteiro"
        voice = "am_michael"
        speed = 1.4
        description = "Menino, arteiro, travesso"
        text = "Opa! Eu sou super arteiro e adoro fazer bagunça! Vamos brincar de pega-pega? Corre!"
    },
    @{
        category = "criancas"
        name = "crianca-masculina-estudioso"
        voice = "am_adam"
        speed = 1.32
        description = "Menino, estudioso, inteligente"
        text = "Olá! Eu gosto muito de estudar e aprender coisas novas. Você sabia que os dinossauros..."
    },
    
    # === IDOSOS ===
    @{
        category = "idosos"
        name = "idosa-sabedoria"
        voice = "af_sarah"
        speed = 0.82
        description = "Senhora, sábia, experiente"
        text = "Olá, meu querido. Já vivi muitas histórias e tenho muito a ensinar. Deixe-me contar sobre os velhos tempos."
    },
    @{
        category = "idosos"
        name = "idosa-carinhosa"
        voice = "af_nicole"
        speed = 0.78
        description = "Vovó, carinhosa, acolhedora"
        text = "Oi, meu amor! Vovó está aqui para te dar um abraço e contar uma história bem bonita. Vem cá!"
    },
    @{
        category = "idosos"
        name = "idoso-sereno"
        voice = "am_adam"
        speed = 0.8
        description = "Senhor, sereno, reflexivo"
        text = "Bom dia, jovem. Com a idade vem a serenidade. Permita-me compartilhar minha experiência de vida."
    },
    @{
        category = "idosos"
        name = "idoso-contador-historias"
        voice = "am_eric"
        speed = 0.85
        description = "Vovô, contador de histórias"
        text = "Ah, meus netos! Venham cá que o vovô vai contar uma história de quando eu era jovem como vocês."
    },
    
    # === PERSONAGENS ===
    @{
        category = "personagens"
        name = "heroi-corajoso"
        voice = "am_adam"
        speed = 1.0
        description = "Herói, corajoso, determinado"
        text = "Não tema! Eu estou aqui para proteger a todos! A justiça sempre prevalecerá!"
    },
    @{
        category = "personagens"
        name = "vilao-misterioso"
        voice = "am_adam"
        speed = 0.85
        description = "Vilão, misterioso, sombrio"
        text = "Ah, então você descobriu meu plano secreto. Mas já é tarde demais para me deter."
    },
    @{
        category = "personagens"
        name = "princesa-elegante"
        voice = "af_sarah"
        speed = 0.95
        description = "Princesa, elegante, refinada"
        text = "Saudações, meu povo. É uma honra estar aqui hoje para celebrar este momento especial."
    },
    @{
        category = "personagens"
        name = "guerreira-forte"
        voice = "af_sky"
        speed = 1.1
        description = "Guerreira, forte, destemida"
        text = "Preparem-se para a batalha! Não recuaremos diante de nenhum desafio! Avante!"
    },
    @{
        category = "personagens"
        name = "robo-futurista"
        voice = "am_michael"
        speed = 1.0
        description = "Robô, mecânico, futurista"
        text = "Sistema inicializado. Processando comandos. Pronto para executar as tarefas designadas."
    },
    @{
        category = "personagens"
        name = "fada-magica"
        voice = "af_sky"
        speed = 1.2
        description = "Fada, mágica, encantadora"
        text = "Abracadabra! Com um toque de magia, tudo pode se transformar! Acredite nos seus sonhos!"
    },
    
    # === ESPECIAIS ===
    @{
        category = "especiais"
        name = "narrador-documentario"
        voice = "am_adam"
        speed = 0.92
        description = "Narrador, documentário, sério"
        text = "Na vastidão do universo, existem mistérios que a humanidade ainda não conseguiu desvendar completamente."
    },
    @{
        category = "especiais"
        name = "apresentador-tv"
        voice = "am_michael"
        speed = 1.05
        description = "Apresentador, TV, carismático"
        text = "Boa noite, Brasil! Sejam muito bem-vindos ao nosso programa! Hoje temos grandes novidades!"
    },
    @{
        category = "especiais"
        name = "locutora-radio"
        voice = "af_sarah"
        speed = 1.0
        description = "Locutora, rádio, profissional"
        text = "Você está ouvindo a melhor programação musical da cidade. Fique ligado que vem mais música boa por aí!"
    },
    @{
        category = "especiais"
        name = "professor-didatico"
        voice = "am_eric"
        speed = 0.95
        description = "Professor, didático, paciente"
        text = "Vamos aprender juntos hoje. Prestem atenção porque este conteúdo é muito importante para o seu desenvolvimento."
    },
    @{
        category = "especiais"
        name = "vendedor-animado"
        voice = "am_michael"
        speed = 1.15
        description = "Vendedor, animado, persuasivo"
        text = "Aproveite esta oferta incrível! É por tempo limitado! Não perca essa oportunidade única!"
    },
    @{
        category = "especiais"
        name = "meditacao-zen"
        voice = "af_nicole"
        speed = 0.75
        description = "Meditação, zen, tranquila"
        text = "Respire fundo... inspire paz... expire tensão... sinta seu corpo relaxar completamente... tranquilidade."
    }
)

Write-Host "🎙️  Gerando $($voiceLibrary.Count) vozes diferentes...`n" -ForegroundColor Cyan

$successCount = 0
$errorCount = 0

foreach ($voiceConfig in $voiceLibrary) {
    $outputFile = "$refDir/$($voiceConfig.category)/$($voiceConfig.name).wav"
    
    Write-Host "  Gerando: $($voiceConfig.name)" -ForegroundColor Gray -NoNewline
    
    try {
        # Garantir que usa português do Brasil
        $body = @{
            model = "kokoro"
            input = $voiceConfig.text
            voice = $voiceConfig.voice
            response_format = "wav"
            speed = $voiceConfig.speed
            lang_code = "pt-br"
        } | ConvertTo-Json
        
        # Fazer request e salvar bytes diretamente
        $response = Invoke-WebRequest `
            -Uri "http://localhost:8880/v1/audio/speech" `
            -Method POST `
            -Body $body `
            -ContentType "application/json" `
            -ErrorAction Stop
        
        # Salvar conteúdo binário
        [System.IO.File]::WriteAllBytes($outputFile, $response.Content)
        
        $size = (Get-Item $outputFile).Length / 1KB
        Write-Host " ✅ ($([math]::Round($size, 1)) KB)" -ForegroundColor Green
        $successCount++
        
    } catch {
        Write-Host " ❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
        $errorCount++
    }
}

Write-Host "`n📊 Resumo da Geração:`n" -ForegroundColor Cyan

Write-Host "  ✅ Sucesso: $successCount vozes" -ForegroundColor Green
if ($errorCount -gt 0) {
    Write-Host "  ❌ Erros: $errorCount vozes" -ForegroundColor Red
}

# Calcular tamanho total
$allFiles = Get-ChildItem -Path $refDir -Filter "*.wav" -Recurse
$totalSize = ($allFiles | Measure-Object -Property Length -Sum).Sum / 1MB

Write-Host "  📦 Tamanho total: $([math]::Round($totalSize, 2)) MB`n" -ForegroundColor Cyan

# Mostrar estatísticas por categoria
Write-Host "📂 Vozes por Categoria:`n" -ForegroundColor Yellow

foreach ($cat in $categories) {
    $catFiles = Get-ChildItem -Path "$refDir/$cat" -Filter "*.wav" -ErrorAction SilentlyContinue
    if ($catFiles) {
        $catSize = ($catFiles | Measure-Object -Property Length -Sum).Sum / 1KB
        Write-Host "  $cat : $($catFiles.Count) vozes ($([math]::Round($catSize, 1)) KB)" -ForegroundColor Gray
    }
}

Write-Host "`n💡 Próximos Passos:`n" -ForegroundColor Cyan
Write-Host "  1. Copiar para container OpenVoice:" -ForegroundColor White
Write-Host "     docker cp references/ openvoice:/app/references/`n" -ForegroundColor Gray
Write-Host "  2. Testar clonagem:" -ForegroundColor White
Write-Host "     .\test-voice-cloning.ps1`n" -ForegroundColor Gray
Write-Host "  3. Ver catálogo completo:" -ForegroundColor White
Write-Host "     .\list-voice-library.ps1`n" -ForegroundColor Gray

Write-Host "✅ Biblioteca de vozes criada com sucesso!`n" -ForegroundColor Green

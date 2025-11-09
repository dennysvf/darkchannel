@echo off
echo ========================================
echo  DarkChannel Stack - Iniciando...
echo ========================================
echo.

REM Verificar se Docker está rodando
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERRO] Docker Desktop nao esta rodando!
    echo Por favor, abra o Docker Desktop e tente novamente.
    pause
    exit /b 1
)

echo [OK] Docker Desktop esta rodando
echo.

echo Iniciando containers...
docker-compose up -d

if errorlevel 1 (
    echo.
    echo [ERRO] Falha ao iniciar os containers!
    echo Verifique os logs com: docker-compose logs
    pause
    exit /b 1
)

echo.
echo ========================================
echo  Stack iniciada com sucesso!
echo ========================================
echo.
echo Servicos disponiveis:
echo   - N8N:        http://localhost:5678
echo   - Kokoro TTS: http://localhost:8880
echo   - PostgreSQL: localhost:5432
echo.
echo Aguarde ~30 segundos para os servicos iniciarem completamente.
echo.
echo Para ver os logs: docker-compose logs -f
echo Para parar: docker-compose down
echo.
pause

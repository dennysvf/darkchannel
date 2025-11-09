@echo off
echo ========================================
echo  DarkChannel Stack - Parando...
echo ========================================
echo.

docker-compose down

if errorlevel 1 (
    echo.
    echo [ERRO] Falha ao parar os containers!
    pause
    exit /b 1
)

echo.
echo ========================================
echo  Stack parada com sucesso!
echo ========================================
echo.
echo Seus dados foram preservados.
echo Para iniciar novamente, execute: start.bat
echo.
pause

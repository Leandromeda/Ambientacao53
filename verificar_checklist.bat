@echo off
setlocal

:: ==============================================================================
:: SENAI Sao Paulo Skills - Ciclo 2026-2028
:: Ocupacao #53 - Computacao em Nuvem
:: Verificador Automatizado do Checklist de Instalacao (22 Itens)
:: Autor: Prof. Esp. Leandro Gaudio Rosa (https://www.linkedin.com/in/leandro-gr/)
:: ==============================================================================

chcp 65001 >nul 2>&1
title Auditoria de Estacao - SENAI Skills #53 - Prof. Leandro Gaudio Rosa

where powershell.exe >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERRO] O PowerShell nao foi encontrado no PATH do sistema.
    pause
    exit /b 1
)

:: Executar script PowerShell diretamente via -File
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0verificar_checklist.ps1" %*

:: Se passado -Auto nos argumentos, encerra direto; caso contrario, mantem janela aberta
echo %* | findstr /I "\-Auto" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo.
    echo Pressione qualquer tecla para encerrar...
    pause >nul
)

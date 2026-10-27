@echo off
setlocal

:: ==============================================================================
:: SENAI Sao Paulo Skills - Ciclo 2026-2028
:: Ocupacao #53 - Computacao em Nuvem
:: Utilitario para Exclusao de Relatorios
:: Autor: Prof. Esp. Leandro Gaudio Rosa (https://www.linkedin.com/in/leandro-gr/)
:: GitHub: https://github.com/Leandromeda/
:: ==============================================================================

chcp 65001 >nul 2>&1
title Excluir Relatorios - SENAI Skills #53 - Prof. Leandro Gaudio Rosa

cd /d "%~dp0"

echo.
echo ================================================================================
echo       SENAI Sao Paulo Skills - Ocupacao #53 - Computacao em Nuvem
echo                   EXCLUSAO AUTOMATIZADA DE RELATORIOS
echo ================================================================================
echo   Autor : Prof. Esp. Leandro Gaudio Rosa (https://www.linkedin.com/in/leandro-gr/)
echo   GitHub: Leandromeda (https://github.com/Leandromeda/)
echo --------------------------------------------------------------------------------
echo.

:: Contar relatorios existentes
set count=0
for %%F in (relatorio_*.pdf relatorio_*.json relatorio_*.html) do (
    if exist "%%~fF" (
        set /a count+=1
    )
)

if %count% equ 0 (
    echo [*] Nenhum relatorio [PDF, JSON ou HTML] encontrado nesta pasta.
    echo.
    goto :FIM
)

echo [*] Relatorios identificados nesta pasta:
echo.
for %%F in (relatorio_*.pdf relatorio_*.json relatorio_*.html) do (
    if exist "%%~fF" (
        echo     [-] %%~nxF  [%%~zF bytes]
    )
)
echo.
echo --------------------------------------------------------------------------------
echo   Total de relatorios localizados: %count%
echo --------------------------------------------------------------------------------
echo.

:: Verificar parametro /y ou -y
set FORCE=0
if /i "%~1"=="/y" set FORCE=1
if /i "%~1"=="-y" set FORCE=1
if /i "%~1"=="/force" set FORCE=1
if /i "%~1"=="--force" set FORCE=1

if "%FORCE%"=="1" goto :CONFIRMAR_EXCLUSAO

set /p CONFIRMA="Deseja realmente excluir permanentemente os relatorios listados? (S/N) [Padrao: N]: "
if /i not "%CONFIRMA%"=="S" (
    echo.
    echo [!] Operacao cancelada pelo usuario. Nenhum relatorio foi excluido.
    echo.
    goto :FIM
)

:CONFIRMAR_EXCLUSAO
echo.
echo [*] Excluindo relatorios...
set deleted=0
for %%F in (relatorio_*.pdf relatorio_*.json relatorio_*.html) do (
    if exist "%%~fF" (
        del /f /q "%%~fF" >nul 2>&1
        if not exist "%%~fF" (
            set /a deleted+=1
            echo     [OK] Removido com sucesso: %%~nxF
        ) else (
            echo     [ERRO] Falha ao remover: %%~nxF - em uso ou protegido
        )
    )
)

echo.
echo ================================================================================
echo [OK] Exclusao concluida! Total de relatorios removidos: %deleted% de %count%
echo ================================================================================
echo.

:FIM
if "%FORCE%"=="0" (
    echo Pressione qualquer tecla para encerrar...
    pause >nul
)

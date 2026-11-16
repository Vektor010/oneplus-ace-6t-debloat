@echo off
chcp 65001 >nul
cd /d "%~dp0"
title OnePlus Ace 6T / ColorOS 16 Clone Debloat Master

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0OnePlus_Ace6T_Clone_Debloat.ps1" %*

if %errorlevel% neq 0 (
    echo.
    echo [!] Скрипт завершил работу (код возврата %errorlevel%).
    pause
)

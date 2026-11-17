@echo off
chcp 65001 >nul

title OnePlus Ace 6T / ColorOS 16 Clone Debloat Master
cd /d "%~dp0"

if not exist "%~dp0OnePlus_Ace6T_Clone_Debloat.ps1" (
    echo.
    echo [-] ОШИБКА: Файл OnePlus_Ace6T_Clone_Debloat.ps1 не найден!
    echo Убедитесь, что архив полностью распакован в отдельную папку.
    echo.
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0OnePlus_Ace6T_Clone_Debloat.ps1" %*

if %errorlevel% neq 0 (
    echo.
    echo [!] Скрипт завершил работу. Код возврата: %errorlevel%
    pause
)
@echo off
chcp 65001 >nul

title AceDebloat - OnePlus Ace 6T (ColorOS 16/17) Toolkit
cd /d "%~dp0"

if not exist "%~dp0OnePlus_Ace6T_Clone_Debloat.ps1" (
    echo.
    echo [-] ERROR: OnePlus_Ace6T_Clone_Debloat.ps1 not found!
    echo     Please extract the full archive into a folder before running.
    echo     Пожалуйста, полностью распакуйте архив перед запуском.
    echo.
    pause
    exit /b 1
)

set "PS_EXE=powershell.exe"
where powershell.exe >nul 2>&1
if %errorlevel% neq 0 (
    if exist "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" (
        set "PS_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
    )
)

"%PS_EXE%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0OnePlus_Ace6T_Clone_Debloat.ps1" %*
set "EXIT_CODE=%errorlevel%"

if %EXIT_CODE% neq 0 (
    echo.
    echo [!] Process finished with exit code: %EXIT_CODE%
    pause
)
exit /b %EXIT_CODE%

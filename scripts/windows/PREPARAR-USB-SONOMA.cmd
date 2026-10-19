@echo off
chcp 65001 >nul
title Preparar pendrive para macOS Sonoma (OCSONOMA)
cd /d "%~dp0"

net session >nul 2>&1
if not "%errorlevel%"=="0" (
  echo Solicitando permisos de administrador...
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

where python >nul 2>&1
if not "%errorlevel%"=="0" (
  echo.
  echo ERROR: no se encuentra Python en el PATH.
  echo Instala Python o avisa al asistente.
  echo.
  pause
  exit /b 1
)

set PYTHONUTF8=1
set PYTHONIOENCODING=utf-8
python "%~dp0preparar_usb_sonoma.py"

echo.
pause

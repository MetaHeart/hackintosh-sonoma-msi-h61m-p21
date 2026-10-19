@echo off
chcp 65001 >nul
title Instalar OpenCore en el disco interno
net session >nul 2>&1
if %errorlevel% neq 0 (
  echo Solicitando permisos de administrador...
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs" >nul 2>&1
  exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0instalar_arranque_interno.ps1"

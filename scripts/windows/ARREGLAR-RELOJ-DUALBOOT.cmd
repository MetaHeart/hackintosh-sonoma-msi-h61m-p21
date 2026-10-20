@echo off
setlocal
title Arreglar reloj dual-boot (Windows + macOS Hackintosh)

net session >nul 2>&1
if not "%errorlevel%"=="0" (
    echo Se necesitan permisos de administrador. Solicitandolos...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo ================================================================
echo  ARREGLO DEL RELOJ PARA ARRANQUE DUAL WINDOWS + macOS
echo ================================================================
echo.
echo  Causa: macOS guarda la hora de la BIOS en UTC y Windows la
echo  interpreta como hora local. Por eso, al pasar de macOS a
echo  Windows, la hora aparece cambiada (y luego NTP la corrige).
echo.
echo  Con este cambio, Windows tambien tratara la BIOS como UTC y
echo  los dos sistemas mostraran siempre la misma hora.
echo.
pause

echo.
echo [1/4] Configurando RealTimeIsUniversal=1...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /t REG_DWORD /d 1 /f >nul
if errorlevel 1 (echo     ERROR: no se pudo escribir en el registro.) else (echo     OK.)

echo [2/4] Desactivando el Inicio rapido (recomendado en doble arranque)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 0 /f >nul
if errorlevel 1 (echo     ERROR: no se pudo desactivar el inicio rapido.) else (echo     OK.)

echo [3/4] Servicio de hora en automatico y resincronizando...
sc config w32time start= auto >nul
net start w32time >nul 2>&1
w32tm /resync >nul 2>&1
if errorlevel 1 (echo     Aviso: no se pudo resincronizar ahora. Windows lo hara solo.) else (echo     OK.)

echo [4/4] Comprobacion:
echo.
echo     Zona horaria configurada:
tzutil /g
echo.
echo     Valor del registro:
reg query "HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal | findstr /i RealTime
echo.
echo ================================================================
echo  HECHO. Reinicia Windows para aplicarlo del todo.
echo.
echo  - Si la zona horaria mostrada no es la tuya, cambiala en:
echo    Ajustes ^> Hora e idioma ^> Fecha y hora
echo  - Si tras reiniciar la hora baila unos minutos, vuelve a
echo    ejecutar este archivo o usa "Sincronizar ahora".
echo  - macOS no necesita ningun cambio: siempre usa UTC.
echo ================================================================
echo.
pause

@echo off
setlocal EnableExtensions
title Riot Vanguard: diagnostico y reparacion

net session >nul 2>&1
if not "%errorlevel%"=="0" (
    echo Se necesitan permisos de administrador. Solicitandolos...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo ================================================================
echo  RIOT VANGUARD: DIAGNOSTICO Y REPARACION
echo ================================================================
echo.
echo  Estado de los servicios:
echo.
sc query vgc
echo.
sc query vgk
echo.
if exist "C:\Riot Games\VALORANT\live\VALORANT.exe" (
    echo  Valorant: instalado.
) else (
    echo  Valorant: no encontrado en C:\Riot Games.
    echo  Vanguard solo lo usa Valorant; si no lo juegas, lo mejor
    echo  es desinstalarlo.
)
echo.
echo  Opciones:
echo    [1] Reparar: poner el servicio vgc en Automatico e iniciarlo.
echo    [2] Reinstalar: desinstalar Vanguard y reinstalarlo junto
echo        con Valorant desde Riot Client.
echo    [3] Desinstalar Vanguard (si ya no juegas a Valorant).
echo    [0] Salir sin hacer nada.
echo.
choice /c 1230 /n /m "Elige una opcion [1/2/3/0]: "
if errorlevel 4 goto :fin
if errorlevel 3 goto :desinstalar
if errorlevel 2 goto :reinstalar
if errorlevel 1 goto :reparar

:reparar
echo.
echo  Poniendo vgc en Automatico e intentando iniciarlo...
sc config vgc start= auto >nul
net start vgc
if errorlevel 1 (
    echo.
    echo  No se pudo iniciar vgc. El error "Funcion incorrecta" (1)
    echo  indica una instalacion danada: usa la opcion 2 o 3.
) else (
    echo.
    echo  vgc iniciado correctamente. Comprueba el icono de la bandeja.
)
goto :fin

:reinstalar
echo.
echo  Abriendo el desinstalador de Vanguard...
if exist "C:\Program Files\Riot Vanguard\uninstall.exe" (
    start "" "C:\Program Files\Riot Vanguard\uninstall.exe"
    echo.
    echo  1. Termina el desinstalador y REINICIA Windows.
    echo  2. Abre Riot Client y elige VALORANT ^> Instalar.
    echo  3. Cuando lo pida, reinicia otra vez. Vanguard se
    echo     instalara nuevo junto con el juego.
) else (
    echo  No se encontro C:\Program Files\Riot Vanguard\uninstall.exe.
    echo  Puede que Vanguard ya no este instalado.
)
goto :fin

:desinstalar
echo.
echo  Abriendo el desinstalador de Vanguard...
if exist "C:\Program Files\Riot Vanguard\uninstall.exe" (
    start "" "C:\Program Files\Riot Vanguard\uninstall.exe"
    echo.
    echo  Cuando termine, REINICIA Windows. El icono desaparecera.
) else (
    echo  No se encontro el desinstalador. Puede que Vanguard ya no
    echo  este instalado.
)
goto :fin

:fin
echo.
pause

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
echo  Vanguard es obligatorio para VALORANT y para League of
echo  Legends (Riot lo exige al entrar en partida). TFT no lo usa.
echo.
echo  Estado de los servicios:
echo.
sc query vgc
echo.
sc query vgk
echo.
set "VALORANT=C:\Riot Games\VALORANT\live\VALORANT.exe"
set "LEAGUE=C:\Riot Games\League of Legends\LeagueClient.exe"
set "GAME="
if exist "%VALORANT%" set "GAME=VALORANT"
if exist "%LEAGUE%" if defined GAME (set "GAME=%GAME% y League of Legends") else set "GAME=League of Legends"
if defined GAME (
    echo  Juego^(s^) detectado^(s^): %GAME%.
) else (
    echo  No se encontro VALORANT ni League of Legends en C:\Riot Games.
)
echo.
echo  Opciones:
echo    [1] Reparar: poner el servicio vgc en Automatico e iniciarlo.
echo    [2] Reinstalar: desinstalar Vanguard y dejar que Riot Client
echo        o el juego lo instalen de nuevo al abrirlos.
echo    [3] Desinstalar Vanguard (solo si no juegas a ningun juego
echo        que lo requiera).
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
    echo  2. Abre Riot Client o el juego (League of Legends o
    echo     VALORANT). Vanguard se descargara e instalara solo.
    echo  3. Reinicia otra vez si el juego lo pide.
) else (
    echo  No se encontro C:\Program Files\Riot Vanguard\uninstall.exe.
    echo  Puede que Vanguard ya no este instalado.
)
goto :fin

:desinstalar
echo.
echo  AVISO: si juegas a League of Legends o VALORANT, no uses esta
echo  opcion: los dos necesitan Vanguard para entrar en partida.
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

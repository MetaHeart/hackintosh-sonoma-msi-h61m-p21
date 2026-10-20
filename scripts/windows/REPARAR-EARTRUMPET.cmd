@echo off
setlocal
title Reparar EarTrumpet (error de licencia CLiP)

echo ================================================================
echo  REPARAR EARTRUMPET
echo  Error tipico: "El id. de dispositivo de la licencia CLiP no
echo  coincide con el id. de dispositivo de la licencia de dispositivo
echo  enlazado" (o codigo 0xc0ea000a al instalar desde la Store).
echo ================================================================
echo.
echo  Causa habitual: la licencia de Microsoft Store quedo invalidada
echo  (por ejemplo, tras un desajuste de hora entre macOS y Windows).
echo  Si aun no lo has hecho, ejecuta antes ARREGLAR-RELOJ-DUALBOOT.cmd.
echo.
echo  Este script va a:
echo   1) Cerrar EarTrumpet.
echo   2) Desinstalar la version actual.
echo   3) Reinstalar desde Microsoft Store y, si falla, desde el
echo      catalogo comunitario de winget (paquete de GitHub, sin
echo      licencia de Store).
echo.
echo  Si prefieres probar antes algo mas suave: pulsa Ctrl+C, ejecuta
echo  WSReset.exe (Win+R), abre la Store, inicia sesion y vuelve a
echo  intentarlo. Si sigue fallando, ejecuta este archivo.
echo.
pause

echo Cerrando EarTrumpet...
taskkill /f /im EarTrumpet.exe >nul 2>&1

echo Desinstalando la version actual...
powershell -NoProfile -Command "Get-AppxPackage *EarTrumpet* | Remove-AppxPackage" 2>nul

echo.
echo [1/2] Intentando instalar desde Microsoft Store...
winget install --id 9NBLGGH516XP --source msstore --accept-package-agreements --accept-source-agreements
if not errorlevel 1 goto :ok

echo.
echo La Store ha fallado. Probando el origen comunitario de winget...
winget install --id File-New-Project.EarTrumpet --source winget --accept-package-agreements --accept-source-agreements
if not errorlevel 1 goto :ok

echo.
echo No se pudo instalar por ninguna de las dos vias.
echo Abriendo la pagina de EarTrumpet en Microsoft Store...
start "" "ms-windows-store://pdp/?productid=9NBLGGH516XP"
echo.
echo Prueba a instalarlo desde la pagina que se acaba de abrir.
echo Si la Store sigue fallando:
echo  - Comprueba la hora y la zona horaria.
echo  - Ejecuta WSReset.exe (Win+R) y reinicia Windows.
echo  - Abre la Store, inicia sesion y en Biblioteca pulsa
echo    "Obtener actualizaciones".
goto :fin

:ok
echo.
echo EarTrumpet instalado correctamente.
echo Abrelo desde Inicio. Si usaste el origen winget, actualizalo con:
echo   winget upgrade --id File-New-Project.EarTrumpet

:fin
echo.
pause

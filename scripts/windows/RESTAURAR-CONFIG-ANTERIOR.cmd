@echo off
chcp 65001 >nul
title Restaurar configuracion anterior (emergencia)
setlocal
set USB=%~d0
if not exist "%USB%\EFI\OC" (
  echo ERROR: este archivo debe ejecutarse desde la RAIZ del pendrive OCSONOMA.
  echo (Doble clic desde el pendrive, no desde el escritorio.)
  pause
  exit /b 1
)
if not exist "%USB%\EXTRAS\config-fase2-antes-bt.plist" (
  echo ERROR: no encuentro el respaldo EXTRAS\config-fase2-antes-bt.plist en este pendrive.
  pause
  exit /b 1
)
copy /y "%USB%\EFI\OC\config.plist" "%USB%\EXTRAS\config-nueva-antes-de-restaurar.plist" >nul
copy /y "%USB%\EXTRAS\config-fase2-antes-bt.plist" "%USB%\EFI\OC\config.plist" >nul
echo.
echo LISTO: se ha restaurado la configuracion anterior del pendrive.
echo Reinicia y arranca desde el pendrive (F11) para comprobar.
echo.
pause

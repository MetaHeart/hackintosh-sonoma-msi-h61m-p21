#!/bin/bash
# Restaura la configuracion FASE 1 en el pendrive OCSONOMA.
# Uso: doble clic sobre este archivo estando en macOS (debe estar en la raiz del pendrive).

set -u
cd "$(dirname "$0")" || { echo "No pude entrar a la carpeta del script."; read -r -p "Pulsa Enter para salir..."; exit 1; }

echo "==================================================="
echo " VOLVER A LA CONFIGURACION FASE 1"
echo "==================================================="
echo

if [ -f "EXTRAS/config-fase1-backup.plist" ]; then
  cp -f "EXTRAS/config-fase1-backup.plist" "EFI/OC/config.plist"
  sync
  echo "LISTO: restaurada la FASE 1 (copia de EXTRAS)."
elif [ -f "EFI/OC/config-fase1.plist" ]; then
  cp -f "EFI/OC/config-fase1.plist" "EFI/OC/config.plist"
  sync
  echo "LISTO: restaurada la FASE 1."
else
  echo "ERROR: no encuentro ninguna copia de la configuracion FASE 1."
fi
echo
read -r -p "Pulsa Enter para salir..."

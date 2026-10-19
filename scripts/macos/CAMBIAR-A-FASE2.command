#!/bin/bash
# Pasa el pendrive OCSONOMA a la configuracion FASE 2 (tras aplicar el root patch).
# Uso: doble clic sobre este archivo estando en macOS (debe estar en la raiz del pendrive).

set -u
cd "$(dirname "$0")" || { echo "No pude entrar a la carpeta del script."; read -r -p "Pulsa Enter para salir..."; exit 1; }

echo "==================================================="
echo " CAMBIAR EL PENDRIVE OCSONOMA A CONFIGURACION FASE 2"
echo "==================================================="
echo

if [ ! -f "EFI/OC/config.plist" ] || [ ! -f "config-fase2.plist" ]; then
  echo "ERROR: no encuentro 'EFI/OC/config.plist' o 'config-fase2.plist'."
  echo "Comprueba que este script esta en la RAIZ del pendrive OCSONOMA."
  read -r -p "Pulsa Enter para salir..."
  exit 1
fi

# Guardar la configuracion actual (fase 1) por si hay que volver atras
mkdir -p EXTRAS
cp -f "EFI/OC/config.plist" "EXTRAS/config-fase1-backup.plist"
cp -f "EFI/OC/config.plist" "EFI/OC/config-fase1.plist"

# Activar la configuracion fase 2
cp -f "config-fase2.plist" "EFI/OC/config.plist"
sync

echo "LISTO: el pendrive ahora usa la configuracion FASE 2."
echo "(Para volver atras usa VOLVER-A-FASE1.command)"
echo
read -r -p "Pulsa Enter para salir..."

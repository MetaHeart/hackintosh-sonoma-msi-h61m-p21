#!/bin/bash
# Copia la carpeta EFI del pendrive a la particion EFI (zona de arranque)
# del disco INTERNO donde esta instalado macOS, para poder arrancar sin pendrive.
# Uso: doble clic sobre este archivo en macOS (pedira la contrasena del usuario).

set -u

echo "==================================================="
echo " COPIAR EFI AL DISCO INTERNO (arrancar sin pendrive)"
echo "==================================================="
echo

USB_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ ! -d "$USB_DIR/EFI/OC" ]; then
  echo "ERROR: este script debe ejecutarse desde la RAIZ del pendrive OCSONOMA."
  read -r -p "Pulsa Enter para salir..."
  exit 1
fi

WHOLE=$(diskutil info -plist / | awk '/<key>ParentWholeDisk<\/key>/{getline; gsub(/.*<string>|<\/string>.*/,""); gsub(/[ \t\r]/,""); print; exit}')
if [ -z "$WHOLE" ]; then
  echo "ERROR: no pude detectar el disco donde esta instalado macOS."
  read -r -p "Pulsa Enter para salir..."
  exit 1
fi
ESP="${WHOLE}s1"

echo "Disco con macOS : $WHOLE"
echo "Particion EFI   : $ESP"
echo
echo "Ahora se pedira la contrasena de tu usuario de macOS."
echo "(Al escribirla no se ve nada en pantalla: es normal.)"
echo

sudo -v || { echo "Cancelado."; read -r -p "Pulsa Enter para salir..."; exit 1; }

echo "Montando la particion EFI..."
sudo diskutil mount "$ESP" >/dev/null 2>&1
if [ ! -d "/Volumes/EFI" ]; then
  echo "ERROR: no pude montar $ESP."
  echo "Alternativa: abre 'Utilidad de Discos', monta la particion EFI a mano y repite este script."
  read -r -p "Pulsa Enter para salir..."
  exit 1
fi

echo "Copiando la carpeta EFI ..."
sudo ditto "$USB_DIR/EFI" "/Volumes/EFI/EFI"
echo
echo "Contenido de la EFI interna:"
ls -l "/Volumes/EFI/EFI"
echo
ls -l "/Volumes/EFI/EFI/OC" 2>/dev/null | head -20
echo

sudo diskutil unmount "$ESP" >/dev/null 2>&1 || sudo diskutil unmount force "$ESP" >/dev/null 2>&1

echo "LISTO: la EFI esta copiada en el disco interno."
echo
echo "SIGUIENTE:"
echo " 1) Reinicia con el pendrive puesto."
echo " 2) Pulsa F11 y elige la entrada UEFI del disco ST500LT012 (disco interno)."
echo " 3) Si arranca bien (menu de OpenCore), entra al BIOS y pon esa entrada como 1a opcion."
read -r -p "Pulsa Enter para salir..."

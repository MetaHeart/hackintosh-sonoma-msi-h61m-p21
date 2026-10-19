#!/bin/bash
# ============================================================
#  APLICAR-AJUSTES-SONOMA.command
#
#  Aplica SOLO dos ajustes seguros y recomendados:
#    1) Desactiva las actualizaciones automaticas de macOS.
#    2) Desactiva la suspension del disco duro.
#
#  NO toca el EFI, ni OpenCore, ni OCLP, ni FileVault, ni discos.
#  No instala nada. Se puede revertir desde Ajustes del Sistema.
#
#  USO: doble clic en macOS (o bash /Volumes/OCSONOMA/APLICAR-AJUSTES-SONOMA.command)
# ============================================================

set -u

echo ""
echo "=================================================="
echo "  AJUSTES RECOMENDADOS PARA macOS SONOMA"
echo "=================================================="
echo ""
echo "Se van a aplicar:"
echo "  1) Actualizaciones automaticas de macOS: OFF"
echo "     (buscar, descargar e instalar)"
echo "  2) Suspension del disco duro: OFF"
echo "     (evita esperas de 5-10 segundos al usar el HDD)"
echo ""
echo "NO se toca: EFI, OpenCore, OCLP, FileVault, discos, kexts."
echo "Se puede revertir desde Ajustes del Sistema."
echo ""
read -r -p "Escribe S y Enter para aplicar (otra tecla cancela): " resp
case "$resp" in
  S|s) ;;
  *) echo "Cancelado. No se ha cambiado nada."; read -r -p "Pulsa Enter para cerrar..."; exit 0 ;;
esac

if ! sudo -v; then
  echo "No se pudo obtener permiso de administrador. Saliendo."
  read -r -p "Pulsa Enter para cerrar..."
  exit 1
fi

# --- localizar donde guardar el registro ----------------------
SALIDA=""
for v in "/Volumes/OCSONOMA" "/Volumes/OCSONOMA 1" "/Volumes/OCSONOMA 2"; do
  if [ -d "$v" ]; then
    SALIDA="$v/AJUSTES-SONOMA-$(date +%Y%m%d-%H%M%S).txt"
    break
  fi
done
if [ -z "$SALIDA" ]; then
  SALIDA="$HOME/Desktop/AJUSTES-SONOMA-$(date +%Y%m%d-%H%M%S).txt"
fi

{
echo "================================================================"
echo " AJUSTES APLICADOS - $(date)"
echo "================================================================"
echo ""
echo "--- ANTES: actualizaciones ---"
sudo defaults read /Library/Preferences/com.apple.SoftwareUpdate 2>&1
echo ""
echo "--- ANTES: energia ---"
pmset -g 2>&1
echo ""
} > "$SALIDA" 2>&1

# Actualizaciones automaticas: sistema
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool false
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool false
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool false
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool false
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall -bool false

# Actualizaciones automaticas: usuario
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool false
defaults write com.apple.SoftwareUpdate AutomaticDownload -bool false
defaults write com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool false
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -bool false
defaults write com.apple.SoftwareUpdate ConfigDataInstall -bool false

# Compatibilidad con el antiguo programador de softwareupdate
sudo softwareupdate --schedule off 2>&1

# Evitar que el HDD se suspenda (spin-down / spin-up)
sudo pmset -a disksleep 0

{
echo ""
echo "--- DESPUES: actualizaciones (sistema) ---"
sudo defaults read /Library/Preferences/com.apple.SoftwareUpdate 2>&1
echo ""
echo "--- DESPUES: actualizaciones (usuario) ---"
defaults read com.apple.SoftwareUpdate 2>&1
echo ""
echo "--- DESPUES: energia ---"
pmset -g 2>&1
echo ""
echo "Para revertir las actualizaciones automaticas:"
echo "  Ajustes del Sistema > General > Actualizacion de software >"
echo "  Actualizaciones automaticas."
echo ""
echo "Para volver a permitir la suspension del disco:"
echo "  sudo pmset -a disksleep 10"
echo ""
} >> "$SALIDA" 2>&1

echo ""
echo "=================================================="
echo "  AJUSTES APLICADOS"
echo "=================================================="
echo ""
echo "Registro guardado en:"
echo "  $SALIDA"
echo ""
echo "Comprobacion rapida:"
pmset -g | grep -E 'disksleep|sleep' 2>/dev/null
echo ""
echo "No hace falta reiniciar. Los ajustes ya estan activos."
echo "Si quieres, ahora puedes ejecutar DIAGNOSTICO-SONOMA.command."
echo ""
read -r -p "Pulsa Enter para cerrar esta ventana..."

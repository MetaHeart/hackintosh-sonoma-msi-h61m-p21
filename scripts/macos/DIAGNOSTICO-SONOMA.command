#!/bin/bash
# ============================================================
#  DIAGNOSTICO-SONOMA.command
#
#  Recoge el estado de macOS Sonoma y lo guarda en el pendrive
#  OCSONOMA como DIAGNOSTICO-SONOMA-1.txt (o -2, -3...).
#
#  USO:
#   1) Conecta el pendrive OCSONOMA.
#   2) En macOS, doble clic en este archivo.
#      Si macOS no lo abre: clic derecho > Abrir > Abrir.
#      O abre Terminal y ejecuta:
#        bash /Volumes/OCSONOMA/DIAGNOSTICO-SONOMA.command
#   3) Espera 2-5 minutos (el HDD es lento). No cierres la ventana.
#   4) Reinicia en Windows y avisa al asistente.
#
#  No cambia nada del sistema: solo lee datos.
# ============================================================

set -u
export LC_ALL=C

echo ""
echo "=================================================="
echo "  DIAGNOSTICO DE macOS SONOMA"
echo "=================================================="
echo ""
echo "Recoge espacio en disco, hardware, energia, arranque,"
echo "kexts, actualizaciones y estado general."
echo "No cambia nada: solo lee datos."
echo ""

# --- localizar el pendrive / carpeta de salida ---------------
SALIDA=""
for v in "/Volumes/OCSONOMA" "/Volumes/OCSONOMA 1" "/Volumes/OCSONOMA 2"; do
  if [ -d "$v" ]; then
    i=1
    while [ -f "$v/DIAGNOSTICO-SONOMA-$i.txt" ]; do i=$((i+1)); done
    SALIDA="$v/DIAGNOSTICO-SONOMA-$i.txt"
    break
  fi
done

if [ -z "$SALIDA" ]; then
  for v in /Volumes/*; do
    [ -d "$v" ] || continue
    if [ -d "$v/EFI/OC" ] || [ -d "$v/com.apple.recovery.boot" ]; then
      i=1
      while [ -f "$v/DIAGNOSTICO-SONOMA-$i.txt" ]; do i=$((i+1)); done
      SALIDA="$v/DIAGNOSTICO-SONOMA-$i.txt"
      break
    fi
  done
fi

if [ -z "$SALIDA" ]; then
  i=1
  while [ -f "$HOME/Desktop/DIAGNOSTICO-SONOMA-$i.txt" ]; do i=$((i+1)); done
  SALIDA="$HOME/Desktop/DIAGNOSTICO-SONOMA-$i.txt"
  echo "AVISO: no encuentro el pendrive OCSONOMA."
  echo "El informe se guardara en el Escritorio."
  echo "Luego habra que copiarlo al pendrive."
  echo ""
fi

echo "El informe se guardara en:"
echo "  $SALIDA"
echo ""
echo "Se pedira tu contrasena (solo para leer datos del sistema)."
echo ""

if ! sudo -v; then
  echo "No se pudo obtener permiso de administrador. Saliendo."
  read -r -p "Pulsa Enter para cerrar..."
  exit 1
fi

# A partir de aqui, todo el informe va al archivo.
# El progreso se muestra en la terminal mediante el descriptor 3.
exec 3>&1
exec >> "$SALIDA" 2>&1

progress() { printf '%s\n' "$*" >&3; }
refresh_sudo() { sudo -v </dev/tty >/dev/tty 2>&1 || true; }

echo "================================================================"
echo " DIAGNOSTICO DE macOS SONOMA"
echo " Fecha: $(date)"
echo "================================================================"
echo ""

echo "### SISTEMA"
sw_vers
uname -a
echo "Modelo: $(sysctl -n hw.model 2>&1)"
echo "CPU: $(sysctl -n machdep.cpu.brand_string 2>&1)"
echo "RAM bytes: $(sysctl -n hw.memsize 2>&1)"
uptime
echo ""

echo "### RESUMEN RAPIDO DE ESPACIO"
df -h / /System/Volumes/Data
diskutil info / 2>&1 | grep -E 'Capacity|Free Space|SMART|Solid State|Media Name' 2>/dev/null
echo ""

echo "### ESPACIO: df COMPLETO"
df -h
echo ""

echo "### CONTENEDOR APFS Y VOLUMENES"
diskutil apfs list
echo ""

echo "### DISCOS Y PARTICIONES"
diskutil list
echo ""

echo "### INFORMACION DEL VOLUMEN DE ARRANQUE"
diskutil info /
echo ""

echo "### INFORMACION DEL VOLUMEN DE DATOS"
diskutil info /System/Volumes/Data
echo ""

echo "### PUNTOS DE MONTAJE"
mount
echo ""

echo "### SNAPSHOTS APFS / TIME MACHINE"
sudo tmutil listlocalsnapshots / 2>&1
echo ""
sudo tmutil destinationinfo 2>&1
echo ""

echo "### TAMANOS DE CARPETAS (du; puede tardar)"
progress "Calculando tamano del volumen de datos..."
refresh_sudo
echo "--- Volumen de datos: nivel 1 (MB, ordenado) ---"
sudo du -x -d 1 -m /System/Volumes/Data 2>/dev/null | sort -n
echo ""

progress "Calculando tamano de Aplicaciones..."
refresh_sudo
echo "--- Aplicaciones (MB, mayor primero) ---"
sudo du -s -m /Applications/* 2>/dev/null | sort -n | tail -n 60
echo ""

progress "Calculando tamano de Usuarios..."
refresh_sudo
echo "--- Usuarios: nivel 2 (MB, ordenado) ---"
sudo du -x -d 2 -m /System/Volumes/Data/Users 2>/dev/null | sort -n | tail -n 80
echo ""

progress "Calculando tamano de Biblioteca del sistema..."
refresh_sudo
echo "--- Biblioteca del sistema: nivel 2 (MB, ordenado) ---"
sudo du -x -d 2 -m /System/Volumes/Data/Library 2>/dev/null | sort -n | tail -n 80
echo ""

progress "Calculando carpetas del usuario, caches y swap..."
refresh_sudo
echo "--- Carpetas clave del usuario ---"
sudo du -sh "$HOME/Desktop" "$HOME/Documents" "$HOME/Downloads" "$HOME/Pictures" "$HOME/Movies" "$HOME/Music" "$HOME/Library" 2>/dev/null
echo ""
echo "--- Caches y logs ---"
sudo du -sh /Library/Caches /Library/Logs /private/var/log "$HOME/Library/Caches" 2>/dev/null
echo ""
echo "--- Swap / memoria virtual ---"
sudo ls -lah /private/var/vm 2>&1
sudo du -sh /private/var/vm 2>/dev/null
echo ""
echo "--- Carpetas ocultas grandes del volumen de datos ---"
sudo du -sh /System/Volumes/Data/.Spotlight-V100 /System/Volumes/Data/.DocumentRevisions-V100 /System/Volumes/Data/.fseventsd /System/Volumes/Data/.TemporaryItems 2>/dev/null
echo ""

echo "### HARDWARE"
system_profiler SPHardwareDataType 2>&1
echo ""

echo "### GRAFICA"
system_profiler SPDisplaysDataType 2>&1
echo ""

echo "### ALMACENAMIENTO (todos los discos)"
system_profiler SPStorageDataType 2>&1
echo ""

echo "### AUDIO"
system_profiler SPAudioDataType 2>&1
echo ""

echo "### ETHERNET"
system_profiler SPEthernetDataType 2>&1
echo ""

echo "### SOFTWARE / ARRANQUE"
system_profiler SPSoftwareDataType 2>&1
echo ""

echo "### ENERGIA / SLEEP / SWAP"
pmset -g 2>&1
echo ""
pmset -g custom 2>&1
echo ""
pmset -g therm 2>&1
echo ""
pmset -g assertions 2>&1 | head -n 100
echo ""
echo "xcpm.mode: $(sysctl -n machdep.xcpm.mode 2>&1)"
sysctl vm.swapusage 2>&1
echo ""
vm_stat 2>&1 | head -n 30
echo ""

echo "### SIP / NVRAM / KEXTS"
csrutil status 2>&1
echo ""
nvram boot-args 2>&1
echo ""
nvram -p 2>&1 | grep -E 'boot-args|csr-active-config|revpatch|OCLP|AMFI|SecureBootModel' 2>/dev/null
echo ""
echo "--- kextstat ---"
kextstat 2>/dev/null | grep -E 'Lilu|WhateverGreen|AppleALC|VirtualSMC|RestrictEvents|CryptexFixup|AMFIPass|RealtekRTL8111|VoodooHDA|SMC|Blue|Brcm' 2>/dev/null
echo ""
echo "--- kmutil showloaded ---"
kmutil showloaded 2>/dev/null | grep -E 'Lilu|WhateverGreen|AppleALC|VirtualSMC|RestrictEvents|CryptexFixup|AMFIPass|RealtekRTL8111|VoodooHDA|SMC|Blue|Brcm' 2>/dev/null
echo ""

echo "### ACTUALIZACIONES AUTOMATICAS / HISTORIAL"
sudo defaults read /Library/Preferences/com.apple.SoftwareUpdate 2>&1
echo ""
defaults read com.apple.SoftwareUpdate 2>&1
echo ""
sudo softwareupdate --history 2>&1 | tail -n 40
echo ""

echo "### SPOTLIGHT"
mdutil -s / 2>&1
for v in /Volumes/*; do
  [ -d "$v" ] || continue
  echo "--- $v ---"
  mdutil -s "$v" 2>&1
done
echo ""

echo "### ELEMENTOS DE INICIO / SEGUNDO PLANO"
sudo sfltool dumpbtm 2>&1 | head -n 180
echo ""
echo "--- LaunchAgents / LaunchDaemons ---"
ls -la /Library/LaunchAgents /Library/LaunchDaemons "$HOME/Library/LaunchAgents" 2>&1 | head -n 160
echo ""

echo "### SALUD DEL DISCO / ERRORES"
diskutil info / 2>&1 | grep -E 'Device Node|Volume Name|File System|Mounted|Capacity|Free Space|SMART|Solid State|Media Name|Protocol|Device Location' 2>/dev/null
echo ""
sudo dmesg 2>/dev/null | grep -iE 'disk|I/O|error|fail|smart' | tail -n 120
echo ""
ls -la /Library/Logs/DiagnosticReports/*.panic 2>/dev/null | tail -n 20
ls -la "$HOME/Library/Logs/DiagnosticReports" 2>/dev/null | tail -n 30
echo ""

echo "### RED"
networksetup -listallhardwareports 2>&1
echo ""
networksetup -getinfo Ethernet 2>&1
echo ""
ifconfig en0 2>&1 | head -n 40
echo ""
scutil --dns 2>&1 | head -n 40
echo ""

echo "### OCLP"
if [ -d "/Applications/OpenCore-Patcher.app" ]; then
  echo "OpenCore-Patcher.app encontrada."
  defaults read "/Applications/OpenCore-Patcher.app/Contents/Info.plist" CFBundleShortVersionString 2>&1
  ls -la "/Applications/OpenCore-Patcher.app" 2>&1 | head -n 20
else
  echo "OpenCore-Patcher.app NO encontrada en /Applications."
fi
echo ""
echo "--- Dortania support ---"
ls -la "/Library/Application Support/Dortania" 2>&1
echo ""
nvram -p 2>&1 | grep -i oclp 2>/dev/null
echo ""

echo "### FIN DEL INFORME"
echo "Fecha de finalizacion: $(date)"
echo "INFORME COMPLETADO."

# --- volver a la terminal y despedirse ------------------------
exec 1>&3 2>&3
exec 3>&-

echo ""
echo "=================================================="
echo "  INFORME GUARDADO EN:"
echo "  $SALIDA"
echo "=================================================="
echo ""
echo "Si el informe se guardo en el Escritorio, copialo al pendrive."
echo "Ahora reinicia en Windows y avisa al asistente."
echo ""
read -r -p "Pulsa Enter para cerrar esta ventana..."

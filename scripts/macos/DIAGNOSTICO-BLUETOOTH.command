#!/bin/bash
# ============================================================
#  DIAGNOSTICO-BLUETOOTH.command
#
#  Recoge toda la informacion posible sobre el Bluetooth del
#  equipo y la guarda en el pendrive OCSONOMA como:
#     DIAGNOSTICO-BLUETOOTH-1.txt  (o -2, -3...)
#
#  COMO USARLO:
#   1) Conecta el pendrive OCSONOMA.
#   2) En macOS, doble clic en este archivo (esta en el pendrive).
#   3) Sigue las instrucciones de la ventana que se abre.
# ============================================================

echo ""
echo "=================================================="
echo "  DIAGNOSTICO DE BLUETOOTH"
echo "=================================================="
echo ""

# --- localizar el pendrive ----------------------------------
SALIDA=""
for v in "/Volumes/OCSONOMA" "/Volumes/OCSONOMA 1" "/Volumes/OCSONOMA 2"; do
  if [ -d "$v" ]; then
    i=1
    while [ -f "$v/DIAGNOSTICO-BLUETOOTH-$i.txt" ]; do i=$((i+1)); done
    SALIDA="$v/DIAGNOSTICO-BLUETOOTH-$i.txt"
    break
  fi
done
if [ -z "$SALIDA" ]; then
  i=1
  while [ -f "$HOME/Desktop/DIAGNOSTICO-BLUETOOTH-$i.txt" ]; do i=$((i+1)); done
  SALIDA="$HOME/Desktop/DIAGNOSTICO-BLUETOOTH-$i.txt"
  echo "AVISO: no encuentro el pendrive OCSONOMA."
  echo "El informe se guardara en el Escritorio de tu usuario."
  echo "Luego habra que copiarlo al pendrive."
  echo ""
fi

echo "El informe se guardara en:"
echo "  $SALIDA"
echo ""
echo "IMPORTANTE: antes de continuar, intenta encender el Bluetooth"
echo "2-3 veces desde los Ajustes del Sistema (aunque no se encienda)."
echo "Asi queda registrado el problema."
echo ""
read -p "Pulsa Enter cuando lo hayas intentado..."

echo ""
echo "Se pedira tu contrasena (para leer los registros del sistema)."
echo "La recogida de datos puede tardar 1-2 minutos. No cierres la ventana."
echo ""
sudo -v

resumen() { echo ""; echo "===================== $1 ====================="; echo ""; }

{
resumen "FECHA"
date
resumen "SISTEMA"
sw_vers
uname -a
sysctl -n hw.model 2>/dev/null

resumen "USB - ARBOL COMPLETO"
system_profiler SPUSBDataType 2>&1

resumen "NVRAM (bluetooth / arranque)"
sudo nvram -p 2>/dev/null | grep -iE 'bluetooth|boot-args|csr-active|7C436110'

resumen "KEXTS CARGADOS RELACIONADOS"
sudo kmutil showloaded 2>/dev/null | grep -iE 'lilu|blue|brcm|bcm|as\.vit9696'
echo "--- kextstat (respaldo) ---"
kextstat 2>/dev/null | grep -iE 'lilu|blue|brcm|bcm'

resumen "TRANSPORTES DE BLUETOOTH DISPONIBLES EN EL SISTEMA"
ls -la /System/Library/Extensions/IOBluetoothFamily.kext/Contents/PlugIns/ 2>&1

resumen "LISTA DEL TRANSPORTE BROADCOM (stock, JSON)"
plutil -convert json -o - "/System/Library/Extensions/IOBluetoothFamily.kext/Contents/PlugIns/BroadcomBluetoothHostControllerUSBTransport.kext/Contents/Info.plist" 2>&1

resumen "LISTA DEL TRANSPORTE USB GENERICO (stock, JSON)"
plutil -convert json -o - "/System/Library/Extensions/IOBluetoothFamily.kext/Contents/PlugIns/IOBluetoothHostControllerUSBTransport.kext/Contents/Info.plist" 2>&1

resumen "IOREG - TRANSPORTE BROADCOM (instancias)"
ioreg -c BroadcomBluetoothHostControllerUSBTransport -l -w 0 2>&1 | head -n 60

resumen "IOREG - TRANSPORTE USB GENERICO (instancias)"
ioreg -c IOBluetoothHostControllerUSBTransport -l -w 0 2>&1 | head -n 60

resumen "IOREG - CONTROLADOR BLUETOOTH (instancias)"
ioreg -c IOBluetoothHCIController -l -w 0 2>&1 | head -n 100

resumen "BLUETOOTH (system_profiler)"
system_profiler SPBluetoothDataType 2>&1

resumen "BUSQUEDA DEL DONGLE EN EL USB"
system_profiler SPUSBDataType 2>&1 | grep -i -B 3 -A 18 -E '07d1|f101|bluetooth|broadcom|d-link'

resumen "IOREG - NODO USB DEL DONGLE (que drivers tiene colgando)"
ioreg -l -w 0 2>&1 | grep -i -B 3 -A 60 -E 'd-link|07d1' | head -n 200

resumen "IOREG - NODOS CON LA PALABRA BLUETOOTH (muestra amplia)"
ioreg -l -w 0 2>&1 | grep -i -B 2 -A 30 -E 'bluetooth' | head -n 300

resumen "DMESG (mensajes del kernel sobre USB/Bluetooth)"
sudo dmesg 2>/dev/null | grep -iE 'usb|bluetooth|brcm' | tail -n 150

resumen "PROCESOS BLUETOOTH"
ps aux | grep -iE 'bluetooth|BlueTool' | grep -v grep

resumen "ESTADO DEL SERVICIO bluetoothd"
sudo launchctl print system/com.apple.bluetoothd 2>&1 | head -n 80

resumen "PREFERENCIAS DE BLUETOOTH DEL SISTEMA"
sudo defaults read /Library/Preferences/com.apple.Bluetooth 2>&1 | head -n 80

resumen "REGISTROS: bluetoothd / BlueTool (desde el arranque)"
sudo log show --last boot --info --predicate 'process == "bluetoothd" OR process == "BlueTool"' --style compact 2>/dev/null | tail -n 300

resumen "REGISTROS: ERRORES DE BLUETOOTH (ultimos 30 min)"
sudo log show --last 30m --info --predicate 'eventMessage CONTAINS[c] "bluetooth"' --style compact 2>/dev/null | grep -iE 'error|fail|crash|firmware|chipset|unsupported|not found' | tail -n 150

resumen "FIN DEL INFORME"
echo "INFORME COMPLETADO CORRECTAMENTE."
} > "$SALIDA" 2>&1

echo ""
echo "=================================================="
echo "  INFORME GUARDADO EN:"
echo "  $SALIDA"
echo "=================================================="
echo ""
echo "Ahora, si quieres, puedo intentar REINICIAR el servicio"
echo "de Bluetooth para ver si responde."
read -p "Escribe S y Enter para intentarlo (o solo Enter para saltar): " resp
if [ "$resp" = "S" ] || [ "$resp" = "s" ]; then
  sudo killall bluetoothd 2>/dev/null
  sleep 6
  {
  resumen "TRAS REINICIAR EL SERVICIO BLUETOOTH"
  date
  system_profiler SPBluetoothDataType 2>&1 | head -n 60
  sudo log show --last 2m --info --predicate 'process == "bluetoothd" OR process == "BlueTool"' --style compact 2>/dev/null | tail -n 80
  } >> "$SALIDA" 2>&1
  echo ""
  echo "Hecho. Intenta encender el Bluetooth otra vez en los Ajustes."
  echo "(Lo que pase queda anotado en el informe.)"
fi

echo ""
echo "LISTO. Todo guardado en el pendrive."
echo "Cuando quieras: reinicia en Windows y avisa al asistente."
echo ""
read -p "Pulsa Enter para cerrar esta ventana..."

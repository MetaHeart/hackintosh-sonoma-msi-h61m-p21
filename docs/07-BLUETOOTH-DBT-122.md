# 07 — Bluetooth: D-Link DBT-122

## Resumen

| Dato | Valor |
|---|---|
| Adaptador | D-Link DBT-122 (USB) |
| Chipset | Broadcom **BCM2045** |
| Estándar | Bluetooth 1.2 (muy antiguo) |
| Estado en macOS | El dispositivo **se detecta por USB**, pero **no funciona** como Bluetooth. |
| Decisión | Aparcado. No merece más tiempo. |

## Qué se intentó

En el EFI se añadieron los kexts habituales para adaptadores Broadcom USB:

- `BrcmFirmwareData.kext` 2.7.2
- `BrcmPatchRAM3.kext` 2.7.2
- `BlueToolFixup.kext` 2.7.2

El adaptador aparece en el árbol USB, pero el sistema no lo reconoce como controlador Bluetooth: no se puede activar, no hay dispositivos y no hay menú de Bluetooth funcional.

## Por qué no funciona

- **BrcmPatchRAM** (y sus variantes) da soporte a chipsets Broadcom modernos como **BCM2070, BCM20702, BCM20703, BCM43602**, etc.
- El **BCM2045** del DBT-122 es de la generación de Bluetooth 1.2 (principios de los 2000), muy anterior a esos chipsets. Su firmware y su protocolo no encajan con el stack Bluetooth de macOS moderno.
- Aunque el USB lo enumere, macOS no encuentra un controlador compatible y el servicio Bluetooth no arranca.

En resumen: no es un problema de configuración del EFI, es **hardware demasiado antiguo**.

## Estado actual

- Kexts presentes en el EFI (no estorban, pero tampoco sirven para este adaptador).
- El adaptador está guardado.
- No se invertirá más tiempo salvo que el usuario quiera cambiar de hardware.

## Si algún día se quiere Bluetooth de verdad

Opciones recomendadas, de más sencilla a más completa:

### 1. Pendrive/adaptador USB Bluetooth moderno y compatible

Busca uno basado en **Broadcom BCM20702**, por ejemplo:

- IOGEAR GBU521
- ASUS USB-BT400
- Plugable USB-BT4LE
- Adaptadores CSR 4.0 (CSR8510) también suelen funcionar

Con un BCM20702, los kexts `BrcmFirmwareData`, `BrcmPatchRAM3` y `BlueToolFixup` que ya están en el EFI son justamente los necesarios. Solo habría que:

1. Conectar el adaptador.
2. Verificar que el sistema lo reconoce.
3. Reiniciar si hace falta.
4. Comprobar en Ajustes → Bluetooth.

### 2. Tarjeta PCIe Wi-Fi + Bluetooth

Tarjetas basadas en **BCM94360** (por ejemplo, las Fenvi) funcionan muy bien en Hackintosh, pero:

- Necesitan antenas y un slot PCIe libre.
- Requieren kexts adicionales para Wi-Fi en Sonoma (IOSkywalk, IO80211FamilyLegacy).
- Es más trabajo; solo tiene sentido si también quieres Wi-Fi.

## Diagnóstico (por si se retoma)

```bash
# ¿Aparece el adaptador en USB?
system_profiler SPUSBDataType | grep -A 12 -i "D-Link\|Bluetooth"

# ¿Qué dice macOS de Bluetooth?
system_profiler SPBluetoothDataType

# Estado del controlador en IORegistry
ioreg -l | grep -i -E "bluetooth|brcm"

# Kexts de Bluetooth cargados
kmutil showloaded | grep -i -E "brcm|bluetool"

# Registro reciente de bluetoothd
log show --predicate 'process == "bluetoothd"' --last 5m --style compact
```

Si el adaptador aparece en USB pero `system_profiler SPBluetoothDataType` está vacío o dice "no disponible", confirma que el chipset no es compatible.

## Conclusión

El Bluetooth de este equipo queda **descartado con el hardware actual**. Para tenerlo, hay que cambiar el adaptador por uno compatible. El resto del sistema (Ethernet, audio, gráfica) no depende de ello.

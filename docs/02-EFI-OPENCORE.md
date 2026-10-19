# 02 — EFI y OpenCore

Este documento detalla la configuración con la que arranca el equipo. Está basado en la inspección real de los archivos del proyecto, no en suposiciones.

> **Los `config.plist` de este repositorio están saneados:** los campos `SystemSerialNumber`, `MLB`, `SystemUUID` y `ROM` fueron sustituidos por marcadores (`TU-SERIAL-AQUI`, `TU-MLB-AQUI`, `00000000-0000-0000-0000-000000000000` y `00:00:00:00:00:00`). **Genera tu propio SMBIOS antes de usar cualquiera de ellos.**

## Versión y estructura

- **OpenCore 1.0.8** (verificado con `ocvalidate` de la misma versión).
- Estructura usada en el pendrive y en la EFI interna:

```text
EFI/
├── BOOT/
│   └── BOOTx64.efi              # Cargador que lanza OpenCore
└── OC/
    ├── OpenCore.efi             # Núcleo de OpenCore
    ├── config.plist             # Configuración activa (Fase 1 o Fase 2)
    ├── ACPI/
    │   └── SSDT-EC-USBX.aml     # Dispositivo EC + definición USBX
    ├── Drivers/
    │   ├── HfsPlus.efi          # Lectura de HFS+ (rescate)
    │   ├── OpenRuntime.efi      # Runtime de OpenCore (obligatorio)
    │   └── ResetNvramEntry.efi  # Entrada para borrar NVRAM desde el menú
    └── Kexts/
        ├── Lilu.kext
        ├── VirtualSMC.kext
        ├── WhateverGreen.kext
        ├── RestrictEvents.kext
        ├── CryptexFixup.kext
        ├── AMFIPass.kext
        ├── KDKlessWorkaround.kext
        ├── AppleIntelCPUPowerManagementClient.kext
        ├── AppleIntelCPUPowerManagement.kext
        ├── RealtekRTL8111.kext
        ├── BrcmFirmwareData.kext
        ├── BrcmPatchRAM3.kext
        ├── BlueToolFixup.kext
        └── VoodooHDA_BL.kext
```

Los binarios **no** se incluyen en este repositorio. Se descargan de sus fuentes oficiales (ver [`09-REFERENCIAS.md`](09-REFERENCIAS.md)):

- `OpenCore.efi`, `BOOTx64.efi`, `OpenRuntime.efi`, `ResetNvramEntry.efi` → **OpenCorePkg** 1.0.8.
- `HfsPlus.efi` → controlador HFS+ de Apple, distribuido con OpenCore.
- `SSDT-EC-USBX.aml` → incluido en este repositorio ([`../efi/ACPI/SSDT-EC-USBX.aml`](../efi/ACPI/SSDT-EC-USBX.aml)).

## Kexts: versiones, orden y función

El orden de `Kernel > Add` importa: **Lilu debe ir primero** y los kexts que dependen de Lilu, después.

| # | Kext | Versión | `MinKernel` | Función |
|---|---|---|---|---|
| 1 | `Lilu.kext` | 1.7.2 | — | Base para los demás kexts de Acidanthera. |
| 2 | `VirtualSMC.kext` | 1.3.8 | — | Emulación del SMC (sensores, arranque). |
| 3 | `WhateverGreen.kext` | 1.7.1 | — | Parches de GPU (AMD/Intel), `agdpmod`, etc. |
| 4 | `RestrictEvents.kext` | 1.1.6 | 20.4.0 (Big Sur 11.4) | Gestiona variables `revpatch`/`revblock` y bloquea procesos de análisis en hardware no soportado. |
| 5 | `CryptexFixup.kext` | 1.0.5 | 22.0.0 (Sonoma) | Permite arrancar macOS moderno en CPUs **sin AVX2** (Ivy Bridge). |
| 6 | `AMFIPass.kext` | 1.4.1 | 21.0.0 (Monterey) | Permite que AMFI siga activo mientras OCLP aplica parches (con `-amfipassbeta`). |
| 7 | `KDKlessWorkaround.kext` | 1.0.0 | 22.3.0 (Sonoma 14.3) | Apoyo para el root patch cuando el KDK no está disponible. |
| 8 | `AppleIntelCPUPowerManagementClient.kext` | 222.0.0 | 22.0.0 | Gestión de energía de la CPU (cliente). |
| 9 | `AppleIntelCPUPowerManagement.kext` | 222.0.0 | 22.0.0 | Gestión de energía de la CPU (SpeedStep) para Ivy Bridge. |
| 10 | `RealtekRTL8111.kext` | 3.0.4 | — | Ethernet Gigabit Realtek. |
| 11 | `BrcmFirmwareData.kext` | 2.7.2 | — | Firmware para adaptadores Broadcom (intento con el DBT-122). |
| 12 | `BrcmPatchRAM3.kext` | 2.7.2 | 20.0.0 | Carga de firmware Broadcom (intento con el DBT-122). |
| 13 | `BlueToolFixup.kext` | 2.7.2 | 21.0.0 | Parche del stack Bluetooth en Monterey+ (intento con el DBT-122). |
| 14 | `VoodooHDA_BL.kext` | 3.7.0 | — | Audio VIA VT1708S (AppleALC no lo soporta). |

> Los tres kexts `Brcm*`/`BlueToolFixup` solo tienen sentido si se intenta usar un adaptador Broadcom compatible. Con el D-Link DBT-122 no funcionan. Si no vas a usar Bluetooth, puedes eliminarlos de `Kernel > Add` y de la carpeta `Kexts` (la variante [`../efi/configs/config-fase2-antes-bluetooth.plist`](../efi/configs/config-fase2-antes-bluetooth.plist) refleja esa situación: 10 kexts en vez de 14).

## Boot-args por fase

| Fase | `boot-args` |
|---|---|
| **Fase 1 (instalación)** | `-v keepsyms=1 debug=0x100 agdpmod=vit9696 -wegnoigpu -amfipassbeta ipc_control_port_options=0 amfi=0x80 -amd_no_dgpu_accel` |
| **Fase 1 VMM/HV** | Igual que Fase 1 (los cambios están en los parches, no en los args). |
| **Fase 2 (diaria)** | `agdpmod=vit9696 -wegnoigpu -amfipassbeta ipc_control_port_options=0` |
| **Fase 2 AMFI off** | `agdpmod=vit9696 -wegnoigpu -amfipassbeta ipc_control_port_options=0 amfi=0x80` |

Significado:

- `agdpmod=vit9696`: parche de WhateverGreen para GPUs AMD con SMBIOS de Mac; evita pantalla negra.
- `-wegnoigpu`: desactiva la GPU integrada (HD 4000), que aquí no se usa.
- `-amfipassbeta`: habilita el comportamiento de AMFIPass con AMFI activo.
- `ipc_control_port_options=0`: ajuste de compatibilidad recomendado en este montaje.
- `-v keepsyms=1 debug=0x100`: arranque verboso y con símbolos (solo para diagnosticar).
- `amfi=0x80`: desactiva AMFI (necesario para instalar y para la variante "AMFI off").
- `-amd_no_dgpu_accel`: arranca sin aceleración AMD (para instalar y parchear sin conflictos).

## NVRAM y SIP

- `csr-active-config` = `03080000` (little-endian: `0x803`). Desactiva parcialmente SIP permitiendo:
  - Kexts no firmados (`CSR_ALLOW_UNTRUSTED_KEXTS`).
  - Sistema de archivos sin restricciones (`CSR_ALLOW_UNRESTRICTED_FS`).
  - Kexts no aprobados (`CSR_ALLOW_UNAPPROVED_KEXTS`).

  Es la configuración típica de OCLP. **No la cambies** a SIP completo: el root patch dejaría de funcionar.
- `NVRAM > Delete` incluye: `rtc-blacklist`, `revpatch`, `revblock`, `OCLP-Settings`, `OCLP-Version`, `OCLP-Model`, `OCLP-Spoofed-SN`, `OCLP-Spoofed-MLB`. OpenCore las borra en cada arranque para que OCLP las regenere limpias. No hace falta definirlas a mano.
- `SecureBootModel` = `Disabled` (necesario para OCLP).
- `Vault` = `Optional`, `DmgLoading` = `Signed`, `AllowNvramReset` = `None`, `AllowSetDefault` = `True`.

## SMBIOS

- Modelo: **`iMac13,2`** (Ivy Bridge nativo, con GPU AMD dedicada).
- `SystemMemoryStatus` = `Auto`, `ProcessorType` = `0`.
- Los valores personales están **saneados** en los configs del repositorio.
- Para generar los tuyos:
  1. Descarga **GenSMBIOS** (usa `macserial`).
  2. Genera un SMBIOS `iMac13,2` (serial, MLB, UUID).
  3. Rellena `PlatformInfo > Generic` en tu `config.plist` con ProperTree u OCAT.
  4. Para `ROM`, puedes usar la MAC de `en0` o `00:00:00:00:00:00`.
  5. Valida con `ocvalidate`.

## Parches (`Kernel > Patch` y `Booter > Patch`)

**Fase 2 (uso diario) — 6 parches de kernel:**

1. Force FileVault on Broken Seal.
2. Disable Library Validation Enforcement.
3. Disable `_csr_check()` in `_vnode_check_signature`.
4. Disable Root Hash validation.
5. CaseySJ — Fix PCI bus enumeration (Ventura).
6. Fix PCI bus enumeration (Sonoma).

**Fase 1 VMM/HV — añade 4 parches:** Reroute `kern.hv_vmm_present` (1), (2) Legacy y (2) Ventura, y Force `IOGetVMMPresent`. Sirven para que el instalador acepte la máquina cuando un modelo no soportado se resiste.

**Booter:**

- `Skip Board ID check` (evita que macOS rechace el arranque por el modelo).
- La variante VMM/HV añade `Reroute HW_BID to OC_BID`.

Todos estos parches provienen del conjunto que usa **OpenCore Legacy Patcher**; se aplican en caliente y son reversibles. Si actualizas OpenCore o cambias de versión de macOS, revisa que sigan siendo válidos.

## Quirks destacados

**Booter:** `AvoidRuntimeDefrag`, `EnableSafeModeSlide`, `EnableWriteUnprotector`, `FixupAppleEfiImages`, `ProvideCustomSlide`, `SetupVirtualMap` y `ResizeAppleGpuBars=-1`.

**Kernel:** `AppleCpuPmCfgLock` (si la BIOS bloquea MSR 0xE2), `DisableIoMapper` (evita problemas de VT-d/IOMMU), `DisableLinkeditJettison`, `PanicNoKextDump`, `PowerTimeoutKernelPanic`, `SetApfsTrimTimeout=-1`.

**UEFI:** `EnableVectorAcceleration`, `IgnoreInvalidFlexRatio` (arreglo del MSR 0x194 en Ivy Bridge), `RequestBootVarRouting`, `ResizeGpuBars=-1`.

Estos valores son los que quedaron tras la puesta a punto; no los cambies sin una razón concreta.

## Configuraciones incluidas

| Archivo | Cuándo usarlo |
|---|---|
| [`config-fase1-instalacion.plist`](../efi/configs/config-fase1-instalacion.plist) | Instalación de macOS y ejecución del root patch. |
| [`config-fase1-vmm-hv.plist`](../efi/configs/config-fase1-vmm-hv.plist) | Si el instalador se niega por "modelo no compatible". |
| [`config-fase2-aceleracion.plist`](../efi/configs/config-fase2-aceleracion.plist) | Uso diario, con AMFI activo y AMFIPass. |
| [`config-fase2-amfi-off.plist`](../efi/configs/config-fase2-amfi-off.plist) | Si la aceleración no queda bien con la Fase 2 normal. |
| [`config-fase2-antes-bluetooth.plist`](../efi/configs/config-fase2-antes-bluetooth.plist) | Variante limpia de Fase 2 sin los kexts de Bluetooth (10 kexts). |

Más información sobre cómo se generaron en [`../scripts/build/build_config_sanitized.py`](../scripts/build/build_config_sanitized.py).

## Validación

En Windows:

```powershell
ocvalidate.exe ruta\al\config.plist
```

En macOS:

```bash
./ocvalidate /Volumes/EFI/EFI/OC/config.plist
```

> Con los marcadores del repositorio, `ocvalidate` avisará de que el SMBIOS no es válido; es lo esperado. Tras poner tu serial/MLB/UUID reales, no debería dar errores graves.

# 09 — Referencias y versiones

## Versiones usadas en este montaje

| Componente | Versión | Enlace |
|---|---|---|
| OpenCore | 1.0.8 | <https://github.com/acidanthera/OpenCorePkg/releases/tag/1.0.8> |
| OpenCore Legacy Patcher | 2.5.1 | <https://github.com/dortania/OpenCore-Legacy-Patcher/releases> |
| Lilu | 1.7.2 | <https://github.com/acidanthera/Lilu> |
| WhateverGreen | 1.7.1 | <https://github.com/acidanthera/WhateverGreen> |
| VirtualSMC | 1.3.8 | <https://github.com/acidanthera/VirtualSMC> |
| RestrictEvents | 1.1.6 | <https://github.com/acidanthera/RestrictEvents> |
| CryptexFixup | 1.0.5 | <https://github.com/khronokernel/CryptexFixup> |
| AMFIPass | 1.4.1 | <https://github.com/dhinakg/AMFIPass> |
| KDKlessWorkaround | 1.0.0 | <https://github.com/flagersgit/KDKlessWorkaround> |
| RealtekRTL8111 | 3.0.4 | <https://github.com/Mieze/RTL8111_driver_for_OS_X> |
| VoodooHDA | 3.7.0 | <https://sourceforge.net/projects/voodoohda/> (la variante `_BL` se extrae del paquete de OCLP) |
| BrcmPatchRAM (BrcmFirmwareData / BrcmPatchRAM3 / BlueToolFixup) | 2.7.2 | <https://github.com/acidanthera/BrcmPatchRAM> |

## Guías principales

- **Dortania — OpenCore Install Guide:** <https://dortania.github.io/OpenCore-Install-Guide/>
- **Dortania — Ivy Bridge (desktop):** <https://dortania.github.io/OpenCore-Install-Guide/config.plist/ivy-bridge.html>
- **Dortania — Troubleshooting:** <https://dortania.github.io/OpenCore-Install-Guide/troubleshooting/troubleshooting.html>
- **OCLP4Hackintosh — Guía Ivy Bridge (5T33Z0):** <https://github.com/5T33Z0/OCLP4Hackintosh/blob/main/Guides/Ivy_Bridge.md> — muy recomendable para entender los parches y kexts de este montaje.
- **OpenCore Legacy Patcher — documentación:** <https://dortania.github.io/OpenCore-Legacy-Patcher/>
- **OpenCore Legacy Patcher — repositorio:** <https://github.com/dortania/OpenCore-Legacy-Patcher>

## Herramientas

| Herramienta | Para qué | Enlace |
|---|---|---|
| **GenSMBIOS** / `macserial` | Generar serial, MLB y UUID | <https://github.com/corpnewt/GenSMBIOS> |
| **ProperTree** | Editar `config.plist` | <https://github.com/corpnewt/ProperTree> |
| **OCAuxiliaryTools (OCAT)** | Editar y validar `config.plist` con interfaz | <https://github.com/ic005k/OCAuxiliaryTools> |
| **SSDTTime** | Generar SSDTs (EC, USBX, etc.) | <https://github.com/corpnewt/SSDTTime> |
| **ocvalidate** | Validar `config.plist` | Incluido en OpenCorePkg |
| **macrecovery** | Descargar la imagen de recuperación de macOS | Incluido en OpenCorePkg (`Utilities/macrecovery`) |
| **MountEFI** | Montar particiones EFI | <https://github.com/corpnewt/MountEFI> |

## Hardware

| Componente | Enlace |
|---|---|
| Intel Core i7-3770 | <https://www.intel.com/content/www/us/en/products/sku/65719/intel-core-i73770-processor-8m-cache-up-to-3-90-ghz/specifications.html> |
| MSI H61M-P21 (MS-7680) | <https://www.msi.com/Motherboard/H61M-P21/support> |
| AMD Radeon RX 580 | <https://www.amd.com/en/products/graphics/radeon-rx-580> |

## Comunidad y soporte

- **r/Hackintosh:** <https://www.reddit.com/r/hackintosh/>
- **InsanelyMac:** <https://www.insanelymac.com/>
- **Foro de RealtekRTL8111:** <https://www.insanelymac.com/forum/topic/287161-new-driver-for-realtek-rtl8111/>
- **OpenCore Legacy Patcher — Issues:** <https://github.com/dortania/OpenCore-Legacy-Patcher/issues>

## KDK (Kernel Debug Kits)

- **Apple Developer — descargas:** <https://developer.apple.com/download/all/?q=Kernel%20Debug%20Kit>
- OCLP normalmente descarga automáticamente el KDK que necesita. En este equipo ya están instalados (2,5 GB) y conviene conservarlos.

## Software que **no** se incluye en este repositorio

Por tamaño y/o licencia, no se redistribuyen:

- Imagen de recuperación de macOS.
- `OpenCore-Patcher.pkg` (OCLP).
- Binarios de OpenCore, controladores y kexts.
- KDKs de Apple.

Todos se obtienen de las fuentes oficiales enlazadas arriba.

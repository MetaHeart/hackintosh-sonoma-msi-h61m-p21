# 09 — References and versions

## Versions used in this build

| Component | Version | Link |
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
| VoodooHDA | 3.7.0 | <https://sourceforge.net/projects/voodoohda/> (the `_BL` variant is extracted from the OCLP package) |
| BrcmPatchRAM (BrcmFirmwareData / BrcmPatchRAM3 / BlueToolFixup) | 2.7.2 | <https://github.com/acidanthera/BrcmPatchRAM> |

## Main guides

- **Dortania — OpenCore Install Guide:** <https://dortania.github.io/OpenCore-Install-Guide/>
- **Dortania — Ivy Bridge (desktop):** <https://dortania.github.io/OpenCore-Install-Guide/config.plist/ivy-bridge.html>
- **Dortania — Troubleshooting:** <https://dortania.github.io/OpenCore-Install-Guide/troubleshooting/troubleshooting.html>
- **OCLP4Hackintosh — Ivy Bridge guide (5T33Z0):** <https://github.com/5T33Z0/OCLP4Hackintosh/blob/main/Guides/Ivy_Bridge.md> — highly recommended for understanding the patches and kexts of this build.
- **OpenCore Legacy Patcher — documentation:** <https://dortania.github.io/OpenCore-Legacy-Patcher/>
- **OpenCore Legacy Patcher — repository:** <https://github.com/dortania/OpenCore-Legacy-Patcher>

## Tools

| Tool | What it is for | Link |
|---|---|---|
| **GenSMBIOS** / `macserial` | Generate serial, MLB and UUID | <https://github.com/corpnewt/GenSMBIOS> |
| **ProperTree** | Edit `config.plist` | <https://github.com/corpnewt/ProperTree> |
| **OCAuxiliaryTools (OCAT)** | Edit and validate `config.plist` with a graphical interface | <https://github.com/ic005k/OCAuxiliaryTools> |
| **SSDTTime** | Generate SSDTs (EC, USBX, etc.) | <https://github.com/corpnewt/SSDTTime> |
| **ocvalidate** | Validate `config.plist` | Included in OpenCorePkg |
| **macrecovery** | Download the macOS recovery image | Included in OpenCorePkg (`Utilities/macrecovery`) |
| **MountEFI** | Mount EFI partitions | <https://github.com/corpnewt/MountEFI> |

## Hardware

| Component | Link |
|---|---|
| Intel Core i7-3770 | <https://www.intel.com/content/www/us/en/products/sku/65719/intel-core-i73770-processor-8m-cache-up-to-3-90-ghz/specifications.html> |
| MSI H61M-P21 (MS-7680) | <https://www.msi.com/Motherboard/H61M-P21/support> |
| AMD Radeon RX 580 | <https://www.amd.com/en/products/graphics/radeon-rx-580> |

## Community and support

- **r/Hackintosh:** <https://www.reddit.com/r/hackintosh/>
- **InsanelyMac:** <https://www.insanelymac.com/>
- **RealtekRTL8111 forum:** <https://www.insanelymac.com/forum/topic/287161-new-driver-for-realtek-rtl8111/>
- **OpenCore Legacy Patcher — Issues:** <https://github.com/dortania/OpenCore-Legacy-Patcher/issues>

## KDK (Kernel Debug Kits)

- **Apple Developer — downloads:** <https://developer.apple.com/download/all/?q=Kernel%20Debug%20Kit>
- OCLP normally downloads the KDK it needs automatically. On this machine they are already installed (2.5 GB) and it is advisable to keep them.

## Software that is **not** included in this repository

For size and/or licensing reasons, the following are not redistributed:

- macOS recovery image.
- `OpenCore-Patcher.pkg` (OCLP).
- OpenCore binaries, drivers and kexts.
- Apple KDKs.

All of them are obtained from the official sources linked above.

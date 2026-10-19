# Hackintosh macOS Sonoma — MSI H61M-P21 + i7-3770 + Radeon RX 580

> Spanish version: [README.md](README.md)

Complete guide, configurations and results of a **working Hackintosh with macOS Sonoma 14.8.9** on Intel Ivy Bridge hardware, using **OpenCore 1.0.8** and **OpenCore Legacy Patcher (OCLP) 2.5.1**.

> **Status:** ✅ stable system, GPU with Metal 2 acceleration, Ethernet at 1 Gb/s, audio working and boot without USB drive.
> **Pending:** the D-Link DBT-122 USB Bluetooth adapter is detected but not functional (postponed).

This repository collects **steps, instructions, configurations, references, modifications and specifications** so that anyone can study or replicate this build. Third-party binaries (OpenCore, kexts, OCLP, macOS recovery image) are **not** redistributed here: their official sources are linked in [`docs/en/09-REFERENCES.md`](docs/en/09-REFERENCES.md).

The **[Releases](https://github.com/MetaHeart/hackintosh-sonoma-msi-h61m-p21/releases)** tab includes a ZIP with the sanitized `config.plist` files and `SSDT-EC-USBX.aml` (own material only, no binaries).

---

## Index

| Document | Content |
|---|---|
| [`docs/en/00-SUMMARY.md`](docs/en/00-SUMMARY.md) | Project summary, decisions and current status. |
| [`docs/en/01-INSTALLATION.md`](docs/en/01-INSTALLATION.md) | Step-by-step installation guide (Phase 1 → Phase 2 → internal EFI). |
| [`docs/en/02-EFI-OPENCORE.md`](docs/en/02-EFI-OPENCORE.md) | EFI details: OpenCore, kexts, boot-args, quirks and patches. |
| [`docs/en/03-OCLP-AND-ACCELERATION.md`](docs/en/03-OCLP-AND-ACCELERATION.md) | OpenCore Legacy Patcher, root patch, KDK and Metal acceleration. |
| [`docs/en/04-MAINTENANCE.md`](docs/en/04-MAINTENANCE.md) | Maintenance, recommended settings and backups. |
| [`docs/en/05-DIAGNOSTICS-AND-RESULTS.md`](docs/en/05-DIAGNOSTICS-AND-RESULTS.md) | Diagnostic scripts and real results from this machine. |
| [`docs/en/06-PERFORMANCE-AND-UPDATES.md`](docs/en/06-PERFORMANCE-AND-UPDATES.md) | HDD vs SSD, update policy and upgrades. |
| [`docs/en/07-BLUETOOTH-DBT-122.md`](docs/en/07-BLUETOOTH-DBT-122.md) | D-Link DBT-122 Bluetooth attempt and current status. |
| [`docs/en/08-TROUBLESHOOTING.md`](docs/en/08-TROUBLESHOOTING.md) | Common problems and how to solve them. |
| [`docs/en/09-REFERENCES.md`](docs/en/09-REFERENCES.md) | Official links, tools and versions used. |
| [`docs/en/10-LICENSES-AND-CREDITS.md`](docs/en/10-LICENSES-AND-CREDITS.md) | Licenses, disclaimer and credits. |
| [`docs/en/`](docs/en/) | Complete English translation of this documentation. |
| [`docs/en/11-FAQ.md`](docs/en/11-FAQ.md) | Frequently asked questions (English). |
| [`docs/originales/`](docs/originales/) | Original guides in plain text as they were used. |
| [`docs/ejemplos/`](docs/ejemplos/) | Sample reports and logs (personal data removed). |
| [`efi/configs/`](efi/configs/README.en.md) | Sanitized `config.plist` files (no serial numbers). |
| [`scripts/`](scripts/README.en.md) | Installation, diagnostic and maintenance scripts. |

---

## Machine summary

| Component | Model / Detail |
|---|---|
| **CPU** | Intel Core i7-3770 (Ivy Bridge, 4 cores / 8 threads, 3.4–3.9 GHz, 8 MB L3, 77 W, LGA1155, **no AVX2**) |
| **Motherboard** | MSI H61M-P21 (MS-7680) v3.0, Intel H61 chipset, BIOS V19.2 |
| **RAM** | 16 GB DDR3 (2 × 8 GB; the H61 chipset may run at 1333 MHz) |
| **GPU** | AMD Radeon RX 580 8 GB GDDR5 (Polaris), PCIe x16, **Metal 2** working |
| **Display** | 1360 × 768 at 60 Hz (TV/monitor over HDMI) |
| **Ethernet** | Realtek RTL8111/8168H Gigabit (1 Gb/s) |
| **Audio** | VIA VT1708S onboard (VoodooHDA 3.7.0) |
| **macOS disk** | Seagate ST500LT012-1DG142, 500 GB, 2.5", 5400 RPM, SATA |
| **Other disks** | Crucial BX500 480 GB SSD (Windows), Kingston A400 240 GB SSD, HGST 1 TB HDD |
| **USB** | USB 2.0 (keyboard, mouse and OCSONOMA rescue USB drive) |
| **Bluetooth** | D-Link DBT-122 (Broadcom BCM2045) — detected, not functional |
| **SMBIOS** | `iMac13,2` |

| Software | Version |
|---|---|
| macOS | Sonoma 14.8.9 (build 23J631), Darwin 23.6.0 |
| OpenCore | 1.0.8 |
| OpenCore Legacy Patcher | 2.5.1 (root patch applied) |
| Lilu | 1.7.2 |
| WhateverGreen | 1.7.1 |
| VirtualSMC | 1.3.8 |
| RestrictEvents | 1.1.6 |
| CryptexFixup | 1.0.5 |
| AMFIPass | 1.4.1 |
| RealtekRTL8111 | 3.0.4 |
| VoodooHDA | 3.7.0 |

---

## What works and what does not

**Works:**

- Boot via OpenCore, with and without USB drive (EFI copied to the internal disk).
- AMD RX 580 GPU acceleration with **Metal 2** and 1360 × 768 resolution.
- Gigabit Ethernet (Realtek RTL8111).
- VIA VT1708S audio (output, microphone and SPDIF) with VoodooHDA.
- System sleep and display sleep (with `disksleep` disabled).
- Windows and its disks untouched (dual boot through the F11/OpenCore menu).

**Does not work (or is pending):**

- **D-Link DBT-122 Bluetooth**: the adapter shows up in USB, but there is no Bluetooth. It is hardware that is too old (BCM2045) for the current stack; it is postponed. See [`docs/en/07-BLUETOOTH-DBT-122.md`](docs/en/07-BLUETOOTH-DBT-122.md).
- Update to macOS Tahoe 26.7.1: **not supported** on this machine/OCLP. Do not install.

---

## Diagnostic results

Real data from this machine (sanitized report in [`docs/ejemplos/RESULTADO-DIAGNOSTICO-SANITIZADO.txt`](docs/ejemplos/RESULTADO-DIAGNOSTICO-SANITIZADO.txt)):

| Metric | Value |
|---|---|
| APFS container capacity | 499.9 GB |
| Used by macOS | **33.8 GB (6.8 %)** |
| Free | **466.1 GB (93.2 %)** |
| SMART of all disks | `Verified` |
| RAM | 16 GB, swap used: 0 MB |
| FileVault | Disabled |
| SIP | Customized by OCLP (`csr-active-config=03080000`) |
| Automatic updates | Disabled (system and user) |
| Hard disk sleep | Disabled (`disksleep 0`) |

Details and full breakdown in [`docs/en/05-DIAGNOSTICS-AND-RESULTS.md`](docs/en/05-DIAGNOSTICS-AND-RESULTS.md).

---

## Repository structure

```text
.
├── README.md                     This document (Spanish)
├── README.en.md                  This document (English)
├── LICENSE                       MIT License (only for the content of this repo)
├── docs/
│   ├── 00-RESUMEN.md             Project summary and decisions
│   ├── 01-INSTALACION.md         Step-by-step installation guide
│   ├── 02-EFI-OPENCORE.md        OpenCore and kexts configuration
│   ├── 03-OCLP-Y-ACELERACION.md  OCLP root patch and Metal 2
│   ├── 04-MANTENIMIENTO.md       Maintenance and settings
│   ├── 05-DIAGNOSTICO-Y-RESULTADOS.md
│   ├── 06-RENDIMIENTO-Y-ACTUALIZACIONES.md
│   ├── 07-BLUETOOTH-DBT-122.md
│   ├── 08-SOLUCION-DE-PROBLEMAS.md
│   ├── 09-REFERENCIAS.md
│   ├── 10-LICENCIAS-Y-CREDITOS.md
│   ├── 11-PREGUNTAS-FRECUENTES.md  FAQ (Spanish)
│   ├── en/                       English translation of the documentation
│   │   ├── README.md             Documentation index (English)
│   │   ├── 00-SUMMARY.md
│   │   ├── 01-INSTALLATION.md
│   │   ├── 02-EFI-OPENCORE.md
│   │   ├── 03-OCLP-AND-ACCELERATION.md
│   │   ├── 04-MAINTENANCE.md
│   │   ├── 05-DIAGNOSTICS-AND-RESULTS.md
│   │   ├── 06-PERFORMANCE-AND-UPDATES.md
│   │   ├── 07-BLUETOOTH-DBT-122.md
│   │   ├── 08-TROUBLESHOOTING.md
│   │   ├── 09-REFERENCES.md
│   │   ├── 10-LICENSES-AND-CREDITS.md
│   │   └── 11-FAQ.md
│   ├── originales/               Original guides in plain text
│   └── ejemplos/                 Sanitized sample reports
├── efi/
│   ├── configs/                  Sanitized config.plist files (Phase 1, Phase 2, variants)
│   └── ACPI/                     SSDT-EC-USBX.aml
└── scripts/
    ├── macos/                    .command scripts to run on macOS
    ├── windows/                  .cmd/.ps1/.py scripts to prepare the USB
    └── build/                    Config generation script (sanitized example)
```

---

## How to use this repository

### If you want to replicate this build

1. First read [`docs/en/00-SUMMARY.md`](docs/en/00-SUMMARY.md) and [`docs/en/09-REFERENCES.md`](docs/en/09-REFERENCES.md).
2. Follow [`docs/en/01-INSTALLATION.md`](docs/en/01-INSTALLATION.md) from start to finish.
3. Use the sanitized configs in [`efi/configs/`](efi/configs/README.en.md) as a starting point. **Important:** serial numbers, MLB, UUID and ROM are replaced with placeholders; generate your own SMBIOS with GenSMBIOS/OCAT before booting.
4. Apply the OCLP root patch following [`docs/en/03-OCLP-AND-ACCELERATION.md`](docs/en/03-OCLP-AND-ACCELERATION.md).
5. Verify the result with the scripts in [`scripts/macos/`](scripts/macos/).

### If you already have a similar build

- [`docs/en/04-MAINTENANCE.md`](docs/en/04-MAINTENANCE.md): recommended routines.
- [`docs/en/05-DIAGNOSTICS-AND-RESULTS.md`](docs/en/05-DIAGNOSTICS-AND-RESULTS.md): how to generate a report of the real status.
- [`docs/en/06-PERFORMANCE-AND-UPDATES.md`](docs/en/06-PERFORMANCE-AND-UPDATES.md): what to improve and what **not** to install.
- [`docs/en/08-TROUBLESHOOTING.md`](docs/en/08-TROUBLESHOOTING.md): typical problems and solutions.

---

## Legal notice

This repository is intended for **educational and documentation purposes**. Installing macOS on hardware that is not from Apple may infringe Apple's license agreement; each user is responsible for how they use this information. In this repository:

- Apple software (neither macOS, nor Recovery, nor KDKs) is **not** distributed.
- OpenCore, kext or OCLP binaries are **not** distributed; only official links.
- **No** personal data is included: real serial numbers, MLB, UUID and MAC were replaced with placeholders.
- The configurations are provided **as is**, without warranty. An incorrect `config.plist` can prevent boot.

---

## Credits

This build would not be possible without the work of:

- **[Acidanthera](https://github.com/acidanthera)** — OpenCore, Lilu, WhateverGreen, VirtualSMC, RestrictEvents and BrcmPatchRAM.
- **[Dortania](https://dortania.github.io/OpenCore-Install-Guide/)** — OpenCore Install Guide.
- **[OpenCore Legacy Patcher](https://github.com/dortania/OpenCore-Legacy-Patcher)** — root patches for unsupported hardware.
- **[5T33Z0 / OCLP4Hackintosh](https://github.com/5T33Z0/OCLP4Hackintosh)** — guide specific to Ivy Bridge.
- **[khronokernel](https://github.com/khronokernel)** — CryptexFixup and VoodooHDA.
- **[dhinakg](https://github.com/dhinakg)** — AMFIPass.
- **[Mieze](https://github.com/Mieze/RTL8111_driver_for_OS_X)** — RealtekRTL8111.
- **[CorpNewt](https://github.com/corpnewt)** — GenSMBIOS and ProperTree.
- And the Hackintosh community in general.

---

## License

The original content of this repository (documentation and our own scripts) is published under the **MIT license**. The third-party components mentioned keep their own licenses. See [`docs/en/10-LICENSES-AND-CREDITS.md`](docs/en/10-LICENSES-AND-CREDITS.md).

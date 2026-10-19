# Hackintosh macOS Sonoma — MSI H61M-P21 + i7-3770 + Radeon RX 580

English summary of a working **macOS Sonoma 14.8.9** Hackintosh build on Intel Ivy Bridge hardware, using **OpenCore 1.0.8** and **OpenCore Legacy Patcher (OCLP) 2.5.1**.

> **Status:** ✅ stable. Full Metal 2 acceleration, Gigabit Ethernet, audio, sleep and boot without USB drive.
> **Known issue:** the old D-Link DBT-122 USB Bluetooth adapter is detected but not functional (parked).

## Hardware

| Component | Detail |
|---|---|
| CPU | Intel Core i7-3770 (Ivy Bridge, 4C/8T, 3.4–3.9 GHz, **no AVX2**) |
| Motherboard | MSI H61M-P21 (MS-7680) v3.0, Intel H61, BIOS V19.2 |
| RAM | 16 GB DDR3 (2 × 8 GB) |
| GPU | AMD Radeon RX 580 8 GB (Polaris), Metal 2 |
| Display | 1360 × 768 @ 60 Hz (HDMI) |
| Ethernet | Realtek RTL8111/8168H Gigabit |
| Audio | VIA VT1708S (VoodooHDA 3.7.0) |
| macOS disk | Seagate ST500LT012 500 GB 2.5" 5400 RPM HDD |
| SMBIOS | iMac13,2 |

## Software

- macOS Sonoma 14.8.9 (23J631), Darwin 23.6.0
- OpenCore 1.0.8
- OCLP 2.5.1 (root patch applied)
- Lilu 1.7.2, WhateverGreen 1.7.1, VirtualSMC 1.3.8, RestrictEvents 1.1.6, CryptexFixup 1.0.5, AMFIPass 1.4.1, RealtekRTL8111 3.0.4, VoodooHDA 3.7.0

## Key results

- macOS uses **33.8 GB out of 499.9 GB (6.8 %)**; **466.1 GB free**.
- SMART `Verified` on all disks; 16 GB RAM with 0 MB swap; FileVault off.
- Automatic updates disabled; `disksleep 0`.
- Pending updates: Safari 18.6, Safari 26.6.1, macOS Tahoe 26.7.1 — **do not install Tahoe**.

## Repository layout

- `docs/` — full Spanish documentation (installation, EFI, OCLP, maintenance, diagnostics, performance, Bluetooth, troubleshooting, references, licensing).
- `docs/originales/` — original plain-text guides.
- `docs/ejemplos/` — sanitized sample reports.
- `efi/configs/` — sanitized `config.plist` files (real serials/MLB/UUID/MAC replaced by placeholders).
- `efi/ACPI/` — `SSDT-EC-USBX.aml`.
- `scripts/macos/` — `.command` scripts for macOS (diagnostics, settings, phase switching, EFI copy).
- `scripts/windows/` — `.cmd`/`.ps1`/`.py` scripts to prepare the USB and install the internal bootloader.
- `scripts/build/` — sanitized config generation example.

## Important notes

- These configs are for **this specific hardware combination**. Do not use them blindly.
- **Generate your own SMBIOS** (serial, MLB, UUID) before booting. Placeholders are invalid by design.
- No third-party binaries are redistributed; see `docs/09-REFERENCIAS.md` for official download links.
- No Apple software is included. Installing macOS on non-Apple hardware may violate Apple's EULA; use at your own risk.
- Never install OCLP's "Build and Install OpenCore" option on this setup; only use the root patch.

## License

Original documentation and scripts: **MIT** (see `LICENSE`). Third-party components keep their own licenses.

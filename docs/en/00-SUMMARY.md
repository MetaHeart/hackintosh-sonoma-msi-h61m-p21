# 00 — Project summary

This document summarizes **what was done, why, and in what state the Hackintosh was left**.

## Starting point

The goal was to install macOS Sonoma on an old PC (Intel Ivy Bridge, H61 board, Radeon RX 580) and to leave a **stable, documented, and repeatable** system. The process was divided into phases to separate the installation (without graphics acceleration) from the final acceleration (with OCLP patches).

## Decisions made

| Decision | Reason |
|---|---|
| **Keep macOS Sonoma 14.8.9** | It works well; updating to macOS Tahoe 26.7.1 would break compatibility with Ivy Bridge/OCLP. |
| **Do not install macOS updates without asking** | A build change can invalidate the OCLP root patch. |
| **Automatic updates disabled** | Prevents macOS from downloading or installing anything on its own. |
| **No Apple ID or FileVault** | They are not necessary for this use and they add complexity. |
| **Ethernet only** | There is no onboard Wi-Fi/Bluetooth on this board; the old Bluetooth adapter is not compatible. |
| **Do not reflash the GPU VBIOS** | High risk and it adds nothing with the RX 580 already working. |
| **OCLP 2.5.1 stays as it is** | "Build and Install OpenCore" is not used; only the root patch. |
| **No cleaners, antivirus, or "APFS defrag"** | Unnecessary and potentially harmful. |
| **Keep the OCSONOMA USB drive** | It serves as a rescue and emergency boot drive. |
| **SATA SSD as the only real upgrade** | The 5400 RPM HDD is the bottleneck; the upgrade is big but optional. |

## Current state

- macOS Sonoma 14.8.9 (23J631) booting through OpenCore 1.0.8, without the USB drive.
- AMD RX 580 GPU with **Metal 2** (OCLP 2.5.1 root patch applied).
- Gigabit Ethernet, audio, USB, and display sleep working.
- Windows and the `C:`, `D:`, `E:`, and `S:` disks untouched.
- Full diagnostics completed: **33.8 GB used out of 499.9 GB (6.8%)**; SMART `Verified` on all disks.
- Settings applied: automatic updates OFF and `disksleep 0`.
- Bluetooth D-Link DBT-122: shelved.

## Build phases

1. **Phase 1 — installation:** `config.plist` with `-amd_no_dgpu_accel`, `amfi=0x80`, and verbose boot. It allows installing macOS and running the OCLP root patch without the GPU interfering.
2. **Phase 2 — acceleration:** `config.plist` with AMFI active and AMFIPass (`-amfipassbeta`), without `-amd_no_dgpu_accel`. This is the daily-use configuration.
3. **Internal EFI:** the `EFI` folder from the USB drive is copied to the EFI partition of the macOS disk to boot without the USB drive.

The technical details of each phase are in [`02-EFI-OPENCORE.md`](02-EFI-OPENCORE.md) and the step-by-step process is in [`01-INSTALLATION.md`](01-INSTALLATION.md).

## What remains pending (all optional)

- **2.5" SATA SSD**: replace the HDD with an SSD. It is the most notable performance upgrade. Not purchased or started.
- **Bluetooth**: use a modern, compatible USB adapter (CSR 4.0 / Broadcom BCM20702) instead of the D-Link DBT-122.
- **Space**: deleting `sleepimage` (8 GB) is possible but not urgent; the KDKs (2.5 GB) are best left in place.
- **Spotlight on the USB drive**: `sudo mdutil -i off /Volumes/OCSONOMA` (optional).
- **Safari**: there are pending updates (18.6 and 26.6.1) that can be evaluated without rush.

## Permanent warnings

- **Do not install macOS Tahoe 26.7.1** or any major update without first checking compatibility with OCLP.
- **Do not press "Build and Install OpenCore"** inside OCLP.
- **Do not enable FileVault** (the root patch and booting become complicated).
- **Do not delete** APFS system snapshots.
- **Keep a copy of the EFI** (USB drive + a copy in the cloud or on another disk).

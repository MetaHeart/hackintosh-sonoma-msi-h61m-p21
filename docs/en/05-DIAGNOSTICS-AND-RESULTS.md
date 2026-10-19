# 05 — Diagnostics and results

## Diagnostic scripts

### `DIAGNOSTICO-SONOMA.command`

Location: [`../scripts/macos/DIAGNOSTICO-SONOMA.command`](../../scripts/macos/DIAGNOSTICO-SONOMA.command)

It is **read-only**: it does not change anything on the system. It collects:

- Disk space and APFS volume breakdown.
- Hardware: CPU, RAM, GPU, display, disks, Ethernet, USB, audio.
- Update status.
- Power settings (`pmset`).
- Boot (OpenCore, SIP, `boot-args`).
- Loaded kexts and relevant errors from the log.

**How to use it:**

1. Connect the `OCSONOMA` USB drive.
2. In macOS, double-click the file (if macOS does not open it: right-click → Open → Open).
3. Wait 2–5 minutes (the HDD is slow). You will be asked for the administrator password.
4. The report is saved on the USB drive as `DIAGNOSTICO-SONOMA-1.txt`, `-2.txt`, etc.
5. Reboot into Windows and review the file from there.

### `APLICAR-AJUSTES-SONOMA.command`

Location: [`../scripts/macos/APLICAR-AJUSTES-SONOMA.command`](../../scripts/macos/APLICAR-AJUSTES-SONOMA.command)

It applies **only two** safe settings:

1. Disables automatic updates (system and user).
2. Disables hard disk sleep (`disksleep 0`).

It does not touch EFI, OpenCore, OCLP, FileVault or disks. It generates a log `AJUSTES-SONOMA-FECHA.txt` on the USB drive with the *before* and the *after*.

## Real results from the machine

Data taken from the most recent report (`DIAGNOSTICO-SONOMA-2.txt`). The sanitized version is in [`ejemplos/RESULTADO-DIAGNOSTICO-SANITIZADO.txt`](../ejemplos/RESULTADO-DIAGNOSTICO-SANITIZADO.txt) and the settings log in [`ejemplos/AJUSTES-SONOMA-EJEMPLO.txt`](../ejemplos/AJUSTES-SONOMA-EJEMPLO.txt).

### Disk space

| Item | Value |
|---|---|
| macOS disk | `ST500LT012-1DG142` |
| Total capacity | 499.9 GB (465.6 GiB) |
| APFS container | 499.9 GB |
| **Used by macOS** | **33.8 GB (6.8%)** |
| **Free** | **466.1 GB (93.2%)** |

Breakdown by APFS volume:

| Volume | Size |
|---|---|
| System | 12.0 GB |
| Data | 15.0 GB |
| Preboot | 5.4 GB |
| Recovery | 1.2 GB |
| VM | 1.1 MB |
| **Total** | **33.8 GB** |

Inside the **Data** volume (what takes up the most space):

| Folder | Size | Notes |
|---|---|---|
| `private` | 8.8 GB | Almost all `sleepimage` (8.0 GB). |
| `Library` | 4.0 GB | KDKs 2.5 GB; Dortania 0.8 GB; Updates 0.4 GB; Caches 0.2 GB. |
| `System` | 0.8 GB | |
| `Users` | 0.3 GB | Desktop, Documents, Downloads and Movies empty; Pictures 3.6 MB. |
| `Previous Content` | 0.3 GB | |
| `Spotlight` | 15 MB | |

**Conclusion:** the installation is very clean. There is no need to delete anything to gain space; 466 GB are left over.

### System status

| Check | Result |
|---|---|
| macOS | 14.8.9 (23J631), Darwin 23.6.0, SMBIOS `iMac13,2` |
| RAM | 16 GB, swap used: 0 MB, no memory pressure |
| GPU | AMD Radeon RX 580, 8 GB VRAM, **Metal 2**, 1360 × 768 at 60 Hz |
| Ethernet | Realtek RTL8111 at **1 Gb/s** |
| Audio | VoodooHDA: output, microphone and SPDIF working |
| SMART | `Verified` on all disks |
| FileVault | Disabled |
| SIP | Customized by OCLP (`csr-active-config=03080000`) |
| `boot-args` | Phase 2 (correct) |
| Kexts | Lilu 1.7.2, WhateverGreen 1.7.1, RestrictEvents 1.1.6, CryptexFixup 1.0.5, AMFIPass 1.4.1, VirtualSMC 1.3.8, VoodooHDA 3.7.0, RealtekRTL8111 3.0.4 |
| OCLP | 2.5.1, root patch applied |
| Bluetooth | D-Link DBT-122 detected on USB, but not functional |
| Benign errors | `IOTimeSyncFamily` and `AppleIPAppender` do not load; they do not affect anything |

### Updates

- Automatic updates: **disabled** (system and user). Verified in the log.
- Pending updates that macOS sees:
  - **Safari 26.6.1** (optional).
  - **Safari 18.6** (optional).
  - **macOS Tahoe 26.7.1** → **DO NOT INSTALL**. It is not compatible with Ivy Bridge/OCLP.
- Rule: **do not install macOS updates without consulting first**.

### Power

Current configuration (`pmset -g`):

| Setting | Value |
|---|---|
| `disksleep` | **0** (disk always active) |
| `sleep` | 10 min |
| `displaysleep` | 10 min |
| `powernap` | 0 |
| `standby` | 0 |
| `hibernatemode` | 0 |
| `autorestart` | 0 |

If the PC sleeps and wakes up fine, it can be left as it is. If failures appear when waking up, disable sleep with `sudo pmset -a sleep 0`.

### Snapshots and Time Machine

- Time Machine: no destinations configured.
- There are no local Time Machine snapshots.
- There are **2 APFS system snapshots** (`com.apple.os.update-...` and `com.apple.bless...`) needed to boot. **Do not delete.**

## Recommendations derived from the diagnostic

1. There is no urgent action: the system is healthy.
2. Keep automatic updates OFF.
3. Do not install macOS Tahoe 26.7.1.
4. Do not click "Build and Install OpenCore" in OCLP.
5. Do not enable FileVault or install cleaners/antivirus.
6. Keep at least 15–20% of the disk free (right now there is plenty of margin).
7. Leave the OCLP KDKs (2.5 GB) in place in case you need to re-patch.
8. Optional: disable Spotlight on the OCSONOMA USB drive.
9. Optional: free the 8 GB `sleepimage` (it is not necessary).
10. Backups: keep the OCSONOMA USB drive, a copy of the EFI and the important files on another disk or in the cloud.
11. The real performance improvement is still a **2.5" SATA SSD** to replace the HDD. It is not urgent.
12. Bluetooth remains postponed; if it is taken up again, use a modern and compatible adapter.

## How to interpret a new report

- Compare the **used space** against the one in this report: if it grows a lot for no reason, look for large files in `~/Downloads`, `~/Movies`, caches, etc.
- Check that the **kexts** are still loaded and that `boot-args` is still the Phase 2 one.
- If new disk errors appear (`I/O error`), make a backup and check the disk.
- The `IOTimeSyncFamily` and `AppleIPAppender` errors are benign and also appear on real machines.

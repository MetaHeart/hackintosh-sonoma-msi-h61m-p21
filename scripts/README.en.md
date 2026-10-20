# Scripts

> Spanish version: [README.md](README.md)

Scripts used to prepare the USB drive, install, diagnose, maintain and repair the system. **Read them before running them** and always keep a copy of the EFI.

## macOS (`scripts/macos/`)

| Script | What it does | Risk |
|---|---|---|
| `DIAGNOSTICO-SONOMA.command` | Collects the system status (read-only) and saves the report to the `OCSONOMA` USB drive as `DIAGNOSTICO-SONOMA-N.txt`. | None (it does not modify anything). |
| `APLICAR-AJUSTES-SONOMA.command` | Disables automatic updates and `disksleep`; saves a log with the before/after. | Low (reversible). |
| `CAMBIAR-A-FASE2.command` | Run from the root of the USB drive: it saves the current config and copies `config-fase2.plist` to `EFI/OC/config.plist`. | Medium: it changes the boot configuration. |
| `VOLVER-A-FASE1.command` | Restores the Phase 1 config from `EXTRAS/config-fase1-backup.plist`. | Medium: it changes the boot configuration. |
| `COPIAR-EFI-INTERNO.command` | Mounts the EFI partition of the macOS disk and copies the `EFI` folder from the USB drive. | Medium-high: it writes to the boot partition. |
| `DIAGNOSTICO-BLUETOOTH.command` | Collects Bluetooth and USB information (read-only). | None. |

### How to run them on macOS

1. Connect the `OCSONOMA` USB drive.
2. Double-click the `.command` file. If macOS does not open it: **right-click → Open → Open**.
3. Alternative via Terminal:

```bash
bash /Volumes/OCSONOMA/SCRIPT-NAME.command
```

Scripts that ask for a password use `sudo`; while typing it nothing is shown on screen (this is normal).

> When downloading them from GitHub, the execution permissions may be lost. If needed:
>
> ```bash
> chmod +x NOMBRE.command
> ```

## Windows (`scripts/windows/`)

| Script | What it does | Risk |
|---|---|---|
| `PREPARAR-USB-SONOMA.cmd` + `preparar_usb_sonoma.py` | Formats a USB drive as FAT32 with the label `OCSONOMA` and copies the working files. | **High:** it formats a disk. Check the selected disk. |
| `INSTALAR-ARRANQUE-INTERNO.cmd` + `instalar_arranque_interno.ps1` | Copies the `EFI` folder from the `OCSONOMA` USB drive to the EFI partition (200 MB) of the internal disk with macOS. | **High:** it writes to the boot partition. Requires administrator. |
| `RESTAURAR-CONFIG-ANTERIOR.cmd` | Run from the root of the USB drive: it restores `EXTRAS/config-fase2-antes-bt.plist` as `EFI/OC/config.plist`. | Medium: for emergencies. |
| `ARREGLAR-RELOJ-DUALBOOT.cmd` | Makes Windows treat the BIOS clock as UTC (`RealTimeIsUniversal=1`), disables Fast Startup and resynchronizes the clock. Fixes the dual-boot clock offset. | Low: it changes two registry values and the time service. Requires administrator. |
| `REPARAR-EARTRUMPET.cmd` | Uninstalls EarTrumpet and reinstalls it from Microsoft Store; if that fails, it uses the winget community source (GitHub package, no Store license). | Low: it uninstalls and reinstalls a per-user application. |
| `REPARAR-VANGUARD.cmd` | Diagnoses the `vgc`/`vgk` services and offers a menu to repair, reinstall (together with Valorant) or uninstall Vanguard. | Medium: it can uninstall Vanguard. Requires administrator. |

### Notes

- `preparar_usb_sonoma.py`: the `SRC` variable contains a **sample path**; edit it before running. The script has a safety limit (it does not format disks larger than 64 GB) and requires administrator permissions (the `.cmd` requests them).
- `instalar_arranque_interno.ps1`: it looks for the disk with an APFS partition, checks that it is not USB and that the EFI partition has a reasonable size, and asks for confirmation before copying. Even so, **always verify the disk shown on screen**.
- `RESTAURAR-CONFIG-ANTERIOR.cmd` must be run **from the root of the USB drive** (double-click from the USB drive itself, not from the desktop).
- `ARREGLAR-RELOJ-DUALBOOT.cmd` does not touch macOS or the EFI: it only configures Windows to use UTC. It is safe to run more than once.
- `REPARAR-EARTRUMPET.cmd` does not need administrator rights; if the Store fails, the script itself tries the `winget` community source.
- `REPARAR-VANGUARD.cmd` requires administrator rights. If Valorant is not installed, Vanguard has no purpose: use the uninstall option.

## Config generation (`scripts/build/`)

| Script | What it does |
|---|---|
| `build_config_sanitized.py` | Sanitized example of the script that generated the `config.plist` files for the different phases. It serves as documentation of the process; **it is not standalone**: it expects a `tools/` folder with OpenCorePkg and the kexts, and paths that must be adapted. The SMBIOS values are placeholders (`TU-SERIAL-AQUI`, etc.). |

## General warnings

- These scripts are provided **as is**, without warranty. A badly executed formatting or EFI-writing script can erase data.
- Before running any script that writes to disks: **back up** and double-check the selected disk.
- The diagnostic scripts are read-only; use them without fear to gather information before touching anything.
- If something goes wrong, the `OCSONOMA` USB drive and a copy of the EFI are your safety net.

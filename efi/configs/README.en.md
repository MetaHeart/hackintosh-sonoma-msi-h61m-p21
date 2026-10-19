# OpenCore configurations (sanitized)

> Spanish version: [README.md](README.md)

This folder contains the `config.plist` files used in the project, **with personal data replaced by placeholders**. They serve as a reference and starting point; **do not use them as is without generating your own SMBIOS**.

## Placeholders

| Field | Value in this repository |
|---|---|
| `PlatformInfo > Generic > SystemSerialNumber` | `TU-SERIAL-AQUI` |
| `PlatformInfo > Generic > MLB` | `TU-MLB-AQUI` |
| `PlatformInfo > Generic > SystemUUID` | `00000000-0000-0000-0000-000000000000` |
| `PlatformInfo > Generic > ROM` | `00:00:00:00:00:00` (6 bytes set to zero) |

## Which file to use

| File | Phase | When to use it |
|---|---|---|
| `config-fase1-instalacion.plist` | Phase 1 | Install macOS and run the OCLP root patch. |
| `config-fase1-vmm-hv.plist` | Phase 1 | If the installer refuses due to "unsupported model" (it adds VMM/HV patches). |
| `config-fase2-aceleracion.plist` | Phase 2 | Daily use with AMFI enabled and AMFIPass. |
| `config-fase2-amfi-off.plist` | Phase 2 | If acceleration does not work with the normal Phase 2 (it adds `amfi=0x80`). |
| `config-fase2-antes-bluetooth.plist` | Phase 2 | Clean variant without the Bluetooth kexts (10 kexts). |

## Main differences

| | Phase 1 | Phase 2 |
|---|---|---|
| `boot-args` | `-v keepsyms=1 debug=0x100 agdpmod=vit9696 -wegnoigpu -amfipassbeta ipc_control_port_options=0 amfi=0x80 -amd_no_dgpu_accel` | `agdpmod=vit9696 -wegnoigpu -amfipassbeta ipc_control_port_options=0` |
| AMFI | Disabled (`amfi=0x80`) | Enabled (AMFIPass) |
| GPU | Without acceleration (`-amd_no_dgpu_accel`) | Full acceleration |
| Extra VMM patches | No | No (only in the VMM/HV variant) |
| Kexts | 14 | 14 (10 in the variant without Bluetooth) |

All the details are in [`../../docs/en/02-EFI-OPENCORE.md`](../../docs/en/02-EFI-OPENCORE.md).

## How to generate your SMBIOS

1. Download [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) (it works on Windows, macOS and Linux).
2. Run it and choose `iMac13,2`.
3. Copy the generated `Serial`, `MLB` and `SystemUUID`.
4. For `ROM`, use the MAC of your `en0` interface or leave it as zeros.
5. Edit the `config.plist` with [ProperTree](https://github.com/corpnewt/ProperTree) or [OCAT](https://github.com/ic005k/OCAuxiliaryTools).
6. Save and validate with `ocvalidate`.

> An invalid or duplicated serial can prevent booting or cause service problems. Always generate your own.

## How to apply a config

1. Back up the current `config.plist`.
2. Rename/place the chosen file as `EFI/OC/config.plist` on the USB drive or in the internal EFI.
3. Reboot and check.

The script [`../../scripts/macos/CAMBIAR-A-FASE2.command`](../../scripts/macos/CAMBIAR-A-FASE2.command) automates the change from Phase 1 to Phase 2 on the USB drive.

## Validation

```powershell
# Windows
ocvalidate.exe config-fase2-aceleracion.plist
```

```bash
# macOS
./ocvalidate /Volumes/EFI/EFI/OC/config.plist
```

With the placeholders, `ocvalidate` will give warnings about the SMBIOS; after entering your real data, there should be no serious errors.

## Warning

The `config.plist` files are specific to **this hardware combination** (MSI H61M-P21 + i7-3770 + RX 580 + Sonoma 14.8.9). On another machine they may need adjustments. Do not use them blindly.

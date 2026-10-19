# 01 — Step-by-step installation guide

> This is a condensed and ordered version of the process. The complete original guide, with the exact texts that were used, is in [`originales/GUIA-INSTALACION-SONOMA.txt`](../originales/GUIA-INSTALACION-SONOMA.txt). The paths and scripts mentioned are in [`../scripts/`](../../scripts/).

## Before you start

**Required hardware**

- Target PC (in this case: i7-3770 + MSI H61M-P21 + RX 580 + 16 GB RAM + 500 GB disk).
- A **USB drive of 8 GB or more** (it gets fully formatted; its contents will be lost).
- A **Windows PC** to prepare the USB drive (or access to one).
- An Internet connection (to download OpenCore, kexts, and the macOS recovery image).
- A USB keyboard and mouse.

**Important notices**

- Back up everything on the USB drive.
- **Do not** modify the EFI partitions of Windows: this build adds its own EFI on the macOS disk.
- Have the original guide and this repository at hand.

## Step 1 — Prepare the USB drive from Windows

Contents that should end up in the root of the USB drive (label `OCSONOMA`, FAT32):

```text
OCSONOMA\
├── EFI\                     # OpenCore with the Phase 1 configuration
├── com.apple.recovery.boot\ # macOS Sonoma recovery image
├── config-fase2.plist       # Phase 2 configuration (not used yet)
├── EXTRAS\                  # Config variants and auxiliary material
└── *.command / *.txt        # Scripts and guides
```

In this repository you have:

- [`../scripts/windows/PREPARAR-USB-SONOMA.cmd`](../../scripts/windows/PREPARAR-USB-SONOMA.cmd) and [`../scripts/windows/preparar_usb_sonoma.py`](../../scripts/windows/preparar_usb_sonoma.py): they format the USB drive as FAT32 with the label `OCSONOMA` and copy the files. **Review and edit the `SRC` path inside the `.py`** before running it.
- The sanitized `config.plist` files in [`../efi/configs/`](../../efi/configs/). Remember: you must generate your own SMBIOS before using any of them.
- The recovery image is obtained with the official `macrecovery` utility (included in OpenCorePkg) or with OCLP; see [`09-REFERENCES.md`](09-REFERENCES.md).

## Step 2 — Configure the BIOS

Enter the BIOS (`Del` key when powering on; on Spanish keyboards it may appear as `Supr`) and check:

- **Boot mode:** UEFI (not Legacy/CSM).
- **SATA:** **AHCI** mode.
- **XHCI Hand-off / USB:** enabled if the option exists.
- **Fast Boot:** disabled.
- **Boot order:** the USB drive as the first option (or use the `F11` key for the boot menu).
- **Secure Boot:** disabled (or not available, as on this board).
- **Integrated graphics:** if the board allows it, leave the dedicated GPU as the primary one.

> On the MSI H61M-P21 some options may not exist. AHCI + UEFI is usually enough.

## Step 3 — Phase 1: install macOS

1. Connect the `OCSONOMA` USB drive and boot from it (`F11` → UEFI entry of the USB drive).
2. The OpenCore menu will appear. Choose the **macOS Base System** entry or the Sonoma installer.
3. In macOS Utilities, open **Disk Utility**:
   - Select the 500 GB internal disk (`ST500LT012`).
   - Erase it with **APFS** format and **GUID** scheme.
4. Close Disk Utility and install macOS Sonoma on the freshly erased disk.
5. The machine will restart several times. **Keep the USB drive connected** and always choose the correct entry in OpenCore (installer or internal disk, as appropriate).
6. Finish the initial setup:
   - **Do not** sign in with an Apple ID if you don't need to.
   - Create the local user.
   - You can skip Siri, analytics, etc.

The Phase 1 configuration temporarily disables AMD acceleration (`-amd_no_dgpu_accel`) and AMFI (`amfi=0x80`), which allows installing and patching without conflicts.

## Step 4 — OCLP root patch (still in Phase 1)

With macOS already installed and booting from the internal disk (still with the USB drive plugged in):

1. Copy/open **OpenCore-Patcher** (OCLP 2.5.1) from the USB drive or from its location.
2. Press **Post-Install Root Patch** (root patch). **Do not** press "Build and Install OpenCore".
3. Wait for it to finish (it can take quite a while on an HDD). If it asks to restart, restart.
4. The root patch installs the components that enable Metal acceleration for the RX 580 in Sonoma on unsupported hardware. It requires the KDK (or the `KDKlessWorkaround` that is already included in the EFI); the specific process is in [`03-OCLP-AND-ACCELERATION.md`](03-OCLP-AND-ACCELERATION.md).

## Step 5 — Phase 2: enable acceleration

1. Make sure the USB drive is connected and that you are in macOS.
2. Run [`../scripts/macos/CAMBIAR-A-FASE2.command`](../../scripts/macos/CAMBIAR-A-FASE2.command) (double click). The script:
   - Saves the Phase 1 configuration to `EXTRAS/config-fase1-backup.plist`.
   - Copies `config-fase2.plist` to `EFI/OC/config.plist` on the USB drive.
3. Restart and boot again from the USB drive.
4. Check acceleration:
   - Apple menu → **System Report** → **Graphics/Displays**: the **Radeon RX 580** and **Metal: Supported** should appear.
   - The interface should be smooth (Dock transparency, videos without stuttering).

If something fails, you can go back to Phase 1 with [`../scripts/macos/VOLVER-A-FASE1.command`](../../scripts/macos/VOLVER-A-FASE1.command) or try the AMFI off variant (see [`03-OCLP-AND-ACCELERATION.md`](03-OCLP-AND-ACCELERATION.md)).

## Step 6 — Copy the EFI to the internal disk (boot without the USB drive)

1. In macOS, with the USB drive connected, run [`../scripts/macos/COPIAR-EFI-INTERNO.command`](../../scripts/macos/COPIAR-EFI-INTERNO.command).
2. The script mounts the EFI partition of the macOS disk and copies the `EFI` folder from the USB drive.
3. Restart with the USB drive plugged in:
   - Press `F11` and choose the UEFI entry of the **internal disk** (`ST500LT012`).
   - The OpenCore menu should appear and macOS should boot.
4. If it works, enter the BIOS and set that entry as the **first boot option**.
5. Store the `OCSONOMA` USB drive in a safe place: it is your rescue system.

## Step 7 — Post-install settings

- Run [`../scripts/macos/APLICAR-AJUSTES-SONOMA.command`](../../scripts/macos/APLICAR-AJUSTES-SONOMA.command) to disable automatic updates and `disksleep`.
- Run [`../scripts/macos/DIAGNOSTICO-SONOMA.command`](../../scripts/macos/DIAGNOSTICO-SONOMA.command) to generate a status report and save it next to the EFI.
- Review [`04-MAINTENANCE.md`](04-MAINTENANCE.md) and [`06-PERFORMANCE-AND-UPDATES.md`](06-PERFORMANCE-AND-UPDATES.md).

## Problems during installation

| Symptom | What to try |
|---|---|
| The installer says the model is not supported | Use the VMM/HV variant (`config-fase1-vmm-hv.plist`), which adds the `kern.hv_vmm_present` and `Reroute HW_BID` patches. |
| Black screen or no signal after the root patch | Boot with the USB drive in Phase 1, or try `config-fase2-amfi-off.plist`. |
| The internal disk's boot entry does not appear | Check that the EFI was copied to the correct EFI partition and that the BIOS is in UEFI mode. |
| No audio | Check that VoodooHDA is loaded and select the correct output in Sound settings. |
| No Ethernet | Check the RealtekRTL8111 kext and the cable; check `en0` in System Report. |

More cases in [`08-TROUBLESHOOTING.md`](08-TROUBLESHOOTING.md).

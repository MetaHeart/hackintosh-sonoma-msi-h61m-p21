# 04 — Maintenance and settings

Simple routines to keep the system stable without unnecessary experiments.

## Monthly routine (5 minutes)

1. **Free space:** Apple menu → System Report → Storage (or `df -h /`). Keep at least **15–20% free**; right now there is plenty of margin (466 GB free).
2. **Disk SMART:** Disk Utility → select each disk → **First Aid**. You can also check the status with `diskutil info disk0 | grep -i smart`.
3. **Updates:** `softwareupdate -l` just to *see* what is available. **Do not install** macOS Tahoe 26.7.1 or anything that changes the major version without consulting first. Automatic updates are already disabled.
4. **EFI copy:** save a copy of the `EFI` folder on the OCSONOMA USB drive and somewhere else (cloud or external disk). It is small (a few MB) and it is your boot insurance.
5. **Data backup:** copy important documents/photos to an external disk or to the cloud. Time Machine is not required, but if you have a free external disk you can set it up (it does not require an Apple ID).

## Quarterly routine

- Run [`../scripts/macos/DIAGNOSTICO-SONOMA.command`](../../scripts/macos/DIAGNOSTICO-SONOMA.command) and save the report next to the EFI copy.
- Review [`05-DIAGNOSTICS-AND-RESULTS.md`](05-DIAGNOSTICS-AND-RESULTS.md) to compare values.
- Check that the OCSONOMA USB drive still boots (plug it in and boot from it once).
- Check the KDKs: they should still be in `/Library/Developer/KDKs` if you want to be able to re-patch.

## Settings already applied

Run with [`../scripts/macos/APLICAR-AJUSTES-SONOMA.command`](../../scripts/macos/APLICAR-AJUSTES-SONOMA.command) and verified:

- **Automatic updates: OFF** (system and user domain).
  - `AutomaticCheckEnabled`, `AutomaticDownload`, `AutomaticallyInstallMacOSUpdates`, `CriticalUpdateInstall`, `ConfigDataInstall` → `0`.
  - `softwareupdate --schedule off`.
- **Hard disk sleep: OFF** (`disksleep 0`) to avoid waits of 5–10 seconds when using the HDD.
- **System sleep:** `sleep 10`, `displaysleep 10`, `powernap 0`, `standby 0`, `hibernatemode 0`, `autorestart 0`.

To revert the updates: System Settings → General → Software Update → Automatic Updates.
To allow disk sleep again: `sudo pmset -a disksleep 10`.

## Things you should **not** do

- **Do not use "cleaners" or antivirus** software such as CleanMyMac, CCleaner, etc. On a Hackintosh with a root patch they can delete things the system needs.
- **Do not "defragment" APFS** or delete system snapshots: the snapshots are needed to boot.
- **Do not delete the KDKs** from OCLP (2.5 GB): they are used to patch again.
- **Do not enable FileVault** or lock the firmware with a password unless it is essential.
- **Do not update macOS** without first checking OCLP compatibility.
- **Do not click "Build and Install OpenCore"** in OCLP.
- **Do not edit the internal EFI** "by hand" without having the rescue USB drive at hand.

## Optional settings (only if you want)

### Keep Spotlight from indexing the USB drive

Prevents macOS from consuming resources by indexing the rescue drive:

```bash
sudo mdutil -i off /Volumes/OCSONOMA
```

### Free the `sleepimage` (8 GB)

With `hibernatemode 0` the hibernation file is not used, but macOS may recreate it:

```bash
sudo rm -f /private/var/vm/sleepimage
```

It is not urgent: there are 466 GB free. If you prefer not to touch it, there is no problem.

### Change sleep behavior

- If the PC sleeps and wakes up fine: leave it as it is.
- If black screens or hangs appear when waking up: disable sleep:

```bash
# Disable system sleep (keep display sleep only)
sudo pmset -a sleep 0
```

### Power on only after a power outage

```bash
sudo pmset -a autorestart 1
```

### Switch between OpenCore configurations

- Switch to Phase 2: [`../scripts/macos/CAMBIAR-A-FASE2.command`](../../scripts/macos/CAMBIAR-A-FASE2.command)
- Go back to Phase 1: [`../scripts/macos/VOLVER-A-FASE1.command`](../../scripts/macos/VOLVER-A-FASE1.command)
- Restore the previous configuration from Windows: [`../scripts/windows/RESTAURAR-CONFIG-ANTERIOR.cmd`](../../scripts/windows/RESTAURAR-CONFIG-ANTERIOR.cmd)

## Useful inspection commands

```bash
# macOS version
sw_vers

# Disk space
df -h /

# Power
pmset -g

# Loaded kexts (hides Apple ones)
kmutil showloaded | grep -v com.apple

# Boot arguments
nvram boot-args

# SIP status
csrutil status

# Pending updates (view only, do not install)
softwareupdate -l

# Disk information
diskutil list
diskutil info disk0 | grep -i smart
```

## If something goes wrong: order of action

1. **Do not panic:** the system usually boots from the USB drive even if the internal EFI fails.
2. Boot from the OCSONOMA USB drive (F11 → USB UEFI entry).
3. If it boots fine, the problem is in the internal EFI: copy it again with [`../scripts/macos/COPIAR-EFI-INTERNO.command`](../../scripts/macos/COPIAR-EFI-INTERNO.command).
4. If macOS does not boot properly from the USB drive, boot in **safe mode** (hold `Shift` at the OpenCore menu or use `-x` as a boot-arg).
5. If the problem started after a change, restore the previous configuration with `VOLVER-A-FASE1.command` or `RESTAURAR-CONFIG-ANTERIOR.cmd`.
6. Check [`08-TROUBLESHOOTING.md`](08-TROUBLESHOOTING.md).

> Never delete partitions or "reinstall" without having the rescue USB drive and a copy of the EFI at hand.

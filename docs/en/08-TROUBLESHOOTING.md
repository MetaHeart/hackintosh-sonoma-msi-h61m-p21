# 08 — Troubleshooting

> **Before touching anything:** boot from the OCSONOMA USB drive. If the system boots from the USB drive but not from the internal disk, the problem is in the internal EFI and is fixed by copying it again ([`../scripts/macos/COPIAR-EFI-INTERNO.command`](../../scripts/macos/COPIAR-EFI-INTERNO.command)). Always keep a copy of the EFI.

## Boot / OpenCore

| Symptom | Probable cause | Solution |
|---|---|---|
| The OpenCore menu does not appear | BIOS in Legacy/CSM, USB drive not UEFI, fast boot enabled | BIOS → UEFI, disable Fast Boot, boot with `F11` and choose the UEFI entry. |
| The menu appears but there is no macOS entry | EFI without the correct patches or APFS disk not detected | Use the USB drive in Phase 2; check `HfsPlus.efi` and that the disk is in APFS. |
| It gets stuck on the Apple logo | Incorrect kexts or `boot-args` | Boot with `-v` to see where it stops; try Phase 1. |
| Prohibited sign (crossed-out circle) | Unsupported model / SMBIOS | Use the VMM/HV variant in Phase 1; check the `Skip Board ID check` patches. |
| Reboot loop | Incompatible kext or badly applied patch | Safe mode (`-x`), review recently added kexts, restore the previous config. |
| "OCB: StartImage failed" | Corrupted EFI or bad driver | Restore the entire `EFI` folder from the copy. |
| Prohibited screen after updating | Lost root patch | Boot in Phase 1 and apply the OCLP root patch again. |

## Installation

| Symptom | Probable cause | Solution |
|---|---|---|
| "This model is not supported" | SMBIOS not accepted by the installer | Use `config-fase1-vmm-hv.plist`, which adds the `kern.hv_vmm_present` and `Reroute HW_BID` patches. |
| The installation does not finish or hangs | Slow USB, slow HDD, not enough patience | Wait; use a stable USB 2.0; check `-v` in case there is a real error. |
| The internal disk does not appear in Disk Utility | SATA in RAID/IDE or disk with an odd format | BIOS → SATA **AHCI**; format APFS + GUID. |

## Graphics

| Symptom | Probable cause | Solution |
|---|---|---|
| No acceleration (slow Dock, choppy video) | Root patch not applied or Phase 1 active | Go back to Phase 1, apply the root patch, switch to Phase 2. |
| Black screen when booting Phase 2 | AMFI/GPU patch | Try `config-fase2-amfi-off.plist`; check `agdpmod=vit9696` and `-wegnoigpu`. |
| Wrong resolution | EDID of the TV/monitor | Settings → Displays; try another cable/HDMI port. |
| Flickering or artifacts | Cable/adapter or GPU | Try another cable; watch temperatures; check that the RX 580 is properly powered. |

## Audio

| Symptom | Probable cause | Solution |
|---|---|---|
| No sound | Wrong output or VoodooHDA not loaded | Settings → Sound → choose output; check `kmutil showloaded | grep -i voodoo`. |
| Microphone does not work | Input not selected | Settings → Sound → Input. |
| Noisy sound | VoodooHDA setting | Try lowering the gain or use SPDIF. |

## Ethernet

| Symptom | Probable cause | Solution |
|---|---|---|
| "Ethernet disconnected" | Cable/switch or kext not loaded | Try another cable/port; check `RealtekRTL8111`. |
| Low speed | Negotiation at 100 Mb/s | Change cable/switch; check in System Report → Ethernet. |
| No IP | DHCP or manual configuration | Settings → Network → Ethernet → Use DHCP. |

## USB

| Symptom | Probable cause | Solution |
|---|---|---|
| A USB device does not work | USB map/SSDT | Check `SSDT-EC-USBX.aml`; try another port. |
| Keyboard/mouse fails in the OpenCore menu | USB legacy | Enable USB legacy in BIOS or use USB 2.0 ports. |
| The USB drive does not mount | Format | Use FAT32 for the USB drive; APFS/HFS+ are seen in macOS. |

## Sleep and power

| Symptom | Probable cause | Solution |
|---|---|---|
| Does not wake up properly | Aggressive suspend | `sudo pmset -a sleep 0` (keep only display sleep). |
| The system freezes on wake | GPU/USB | Check logs; try disabling `powernap`; keep `hibernatemode 0`. |
| The HDD clicks and makes you wait | `disksleep` | It is already at `0`; if not, `sudo pmset -a disksleep 0`. |
| It restarts on its own after a power outage | `autorestart 0` | `sudo pmset -a autorestart 1` if desired. |

## OCLP and root patch

| Symptom | Probable cause | Solution |
|---|---|---|
| "Post Install Root Patch" disabled | macOS version not supported or already patched | Check the version; do not update macOS. |
| Error downloading the KDK | Network or Apple Developer | Retry; use `KDKlessWorkaround`; download the KDK manually. |
| After an update the acceleration is lost | OCLP needs to re-patch | Apply the root patch again and restart. |
| OCLP offers to "update OpenCore" | Feature for real Macs | **Do not accept**; it can replace the EFI and leave the system unable to boot. |
| The system does not boot after patching | Incompatible patch | Boot from the USB drive; go back to Phase 1; revert the root patch from OCLP if possible. |

## Updates

| Symptom | Probable cause | Solution |
|---|---|---|
| macOS Tahoe 26.7.1 appears | The updates app offers it | **Ignore it**; do not install. |
| Safari 18.6 / 26.6.1 appear | Normal updates | Optional; they do not affect booting. |
| A Security Response Update appears | RSR | **Do not install** on pre-Haswell; it will fail. |
| Something was downloaded by accident | Automatic updates | Check that they are OFF; delete the downloaded installer from Settings if it appears. |

## Windows and dual boot

| Symptom | Probable cause | Solution |
|---|---|---|
| Windows does not boot | Boot order changed | `F11` → choose Windows Boot Manager; adjust the order in BIOS. |
| I do not want to touch the Windows EFI | — | This build uses the EFI of the macOS disk; do not touch the Windows one. |
| Windows asks for repair | Order or disk change | Boot Windows from its own UEFI entry; do not reinstall anything without a backup. |
| The time changes when switching from macOS to Windows | macOS and Windows interpret the BIOS clock differently | Run [`ARREGLAR-RELOJ-DUALBOOT.cmd`](../../scripts/windows/ARREGLAR-RELOJ-DUALBOOT.cmd) as administrator and restart. |
| EarTrumpet shows a CLiP license error or `0xc0ea000a` | Invalidated Microsoft Store license | Reinstall it from the winget community source; see [EarTrumpet](#eartrumpet-clip-license-error). |
| The Riot Vanguard icon is gray | The `vgc` service does not start ("Incorrect function") | Repair or reinstall Vanguard; see [Riot Vanguard](#riot-vanguard-gray-icon-or-vgc-service-stopped). |

### Clock offset when switching between macOS and Windows

**Symptom:** after using macOS, Windows starts with the clock offset (by your time zone difference: for example, 5 hours in Colombia) and fixes itself after a while or after syncing.

**Cause:** macOS stores the BIOS/CMOS clock in **UTC**. Windows, by default, interprets it as **local time**. Each system writes and reads the time differently, so the clock "jumps" when you switch systems.

**Solution (Windows only):**

1. Run [`scripts/windows/ARREGLAR-RELOJ-DUALBOOT.cmd`](../../scripts/windows/ARREGLAR-RELOJ-DUALBOOT.cmd) as administrator (double-click; the script requests UAC).
2. Restart Windows.

The script:

- Creates `RealTimeIsUniversal = 1` (DWORD) under `HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation`, so Windows also treats the BIOS clock as UTC.
- Disables **Fast Startup** (`HiberbootEnabled = 0`), recommended for dual boot.
- Sets the `w32time` service to automatic and resynchronizes the clock.

**Manual check:**

```cmd
reg query "HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal
tzutil /g
w32tm /resync
```

**macOS needs no changes:** it always uses UTC. If the clock still drifts by a few minutes, check that the time zone is correct and run the script again. This fix is Windows-only and does not touch OpenCore, the EFI or macOS.

## Secondary Windows problems

These failures do not affect booting or macOS: they are Windows applications that can be left in a bad state after switching systems, changing the clock or updating. They can be fixed without reinstalling Windows.

### EarTrumpet: CLiP license error

**Symptom:** EarTrumpet does not start and shows:

> "The device ID of the CLiP license does not match the device ID of the bound device license."

When reinstalling it from the Store, winget may fail with `0xc0ea000a`.

**Cause:** the Microsoft Store license is bound to the device and the account. A clock offset, a change in the Store state or a reinstall can invalidate it. `ClipSVC` (Client License Service) is the service that manages those licenses; there is no need to disable it or "repair" it by hand.

**Recommended solution — install without going through the Store:**

```cmd
winget install --id File-New-Project.EarTrumpet --source winget --accept-package-agreements --accept-source-agreements
```

The `winget` source downloads the package from the GitHub *releases* and installs it as a local MSIX application: **it does not use a Store license**, so the CLiP error cannot appear. To update it later:

```cmd
winget upgrade --id File-New-Project.EarTrumpet
```

**Alternative with Microsoft Store:**

1. Check that the time and time zone are correct.
2. Run `WSReset.exe` (Win+R) and restart Windows.
3. Open Microsoft Store, sign in and go to **Library → Get updates**.
4. Install or update EarTrumpet from its page.
5. If it still fails, run `DISM /Online /Cleanup-Image /RestoreHealth` and `sfc /scannow` as administrator, restart and try again.

You can also use [`scripts/windows/REPARAR-EARTRUMPET.cmd`](../../scripts/windows/REPARAR-EARTRUMPET.cmd), which uninstalls the current version and tries the Store first and then the `winget` source.

> The version installed by `winget` does not update automatically from the Store; use the `winget upgrade` command above.

### Riot Vanguard: gray icon or `vgc` service stopped

**Symptom:** the Vanguard icon in the system tray is gray and `sc query vgc` shows the service stopped, even though it is set to Automatic. League of Legends or VALORANT may ask for Vanguard when entering a match and refuse to continue.

**Cause:** the `vgc` service does not start. The Windows event log usually shows event **7023**: "The vgc service terminated with the following error: Incorrect function" (error 1). It normally indicates a corrupted installation or a `vgk` driver that fails to load.

**Check:**

```cmd
sc query vgc
sc query vgk
```

And, in PowerShell:

```powershell
Get-WinEvent -LogName System -MaxEvents 500 |
  Where-Object { $_.Message -match 'vgc|vgk' } |
  Select-Object -First 5 TimeCreated, Id, Message
```

**Solution:**

1. **Try to repair it** (as administrator):

   ```cmd
   sc config vgc start= auto
   net start vgc
   ```

   If it starts, the icon should turn red again.

2. **If it fails with "Incorrect function"**, the installation is damaged. Uninstall Vanguard with `C:\Program Files\Riot Vanguard\uninstall.exe`, restart Windows and open **Riot Client** or the game (**League of Legends** or **VALORANT**). Riot will download and install Vanguard automatically; restart when prompted.

3. **If you do not play any game that uses Vanguard**, uninstall it. Vanguard is required for **VALORANT** and **League of Legends** (Riot requires it when entering a match); **TFT does not use it**. If you play either of them, do not uninstall it: repair or reinstall it.

You can also use [`scripts/windows/REPARAR-VANGUARD.cmd`](../../scripts/windows/REPARAR-VANGUARD.cmd), which shows the service status and offers a menu to repair, reinstall or uninstall.

> **Note:** Vanguard is installed together with VALORANT or League of Legends; there is no standalone installer. When you open Riot Client or the game, it is downloaded and installed automatically.

## Disk and space

| Symptom | Probable cause | Solution |
|---|---|---|
| Low space | Caches, downloads, `sleepimage` | Check `df -h /`; delete `sleepimage` if you want (optional); do not delete snapshots. |
| Slow disk | 5400 RPM HDD | It is normal; an SSD is the solution. |
| SMART not verified | Degraded disk | Back up immediately and plan a replacement. |
| I/O errors in the log | Cable/disk | Check the SATA cables; make a backup. |

## Emergency recovery

1. **Boot from the OCSONOMA USB drive** (`F11` → UEFI entry of the USB).
2. If the problem is configuration, restore the previous one:
   - From macOS: `VOLVER-A-FASE1.command`.
   - From Windows: `RESTAURAR-CONFIG-ANTERIOR.cmd` (running it from the root of the USB drive).
3. If the problem is the internal EFI, copy it again with `COPIAR-EFI-INTERNO.command`.
4. If the system does not boot even from the USB drive, try:
   - `-v` to see the error.
   - `-x` (safe mode).
   - The `config-fase1-vmm-hv.plist` variant.
   - Another entry in the OpenCore menu.
5. As a last resort, reinstall macOS on a new volume (do not erase the previous one until you have a copy of your data).

> **Never** run destructive commands (`diskutil eraseDisk`, `rm -rf` on system paths, etc.) without a backup and without understanding exactly what they do.

# 06 — Performance and updates

## The bottleneck: the HDD

The system is installed on a **Seagate ST500LT012, 500 GB, 2.5" and 5400 RPM**. It is a decent drive with SMART `Verified`, but it is slow: boot, opening applications and operations with many small files are noticeable.

**The only truly significant performance improvement is replacing it with a 2.5" SATA SSD.**

### What to expect from an SSD

| Aspect | Current HDD | SATA SSD (2.5") |
|---|---|---|
| macOS boot | Tens of seconds | Much faster |
| Opening apps | Slow | Noticeably faster |
| Copying many files | Very slow | Big improvement (especially latency) |
| Noise / power draw | Has moving parts | Quiet and efficient |

The board is H61 (SATA II, up to ~300 MB/s), so an SSD will not reach its theoretical maximums, but the gain in **latency and operations per second** is huge compared to a 5400 RPM HDD.

### Which SSD to buy

- **2.5" SATA** form factor (not M.2; this board does not support it).
- Recommended capacity: **480 GB to 1 TB**.
- Reliable brands: Crucial BX500/MX500, Samsung 870 EVO, WD Blue, Kingston KC600.
- Avoid generic unbranded SSDs or ones of dubious origin.

### How to migrate (recommended: fresh install)

> The HDD works; this is optional and not urgent. Before touching anything, **back up your data and the EFI**.

1. Get the SSD and connect it (via SATA or USB).
2. Boot from the `OCSONOMA` USB drive.
3. Install macOS Sonoma on the SSD following the same process as [`01-INSTALLATION.md`](01-INSTALLATION.md) (APFS + GUID).
4. Apply the OCLP root patch on the SSD.
5. Copy the EFI to the SSD (`COPIAR-EFI-INTERNO.command`) or restore your EFI backup.
6. In the BIOS, set the SSD as the first boot option (or select it with `F11`).
7. Leave the HDD as a data/backup disk or remove it.

**Alternative:** clone the HDD to the SSD with a dedicated tool (Carbon Copy Cloner, SuperDuper, etc.). It can work, but a fresh install is more predictable, especially with OCLP involved.

## What does NOT need changing

- **RAM:** 16 GB (2 × 8 GB) is the board's maximum; it is already maxed out.
- **CPU:** the i7-3770 still performs well for office work, browsing and multimedia.
- **GPU:** the RX 580 8 GB is perfect for this machine; it does not need a modified VBIOS.
- **Cooling:** with a 5400 RPM HDD and an RX 580, keep the case clean and with good airflow.

## Update policy

This is the most delicate part of a Hackintosh with OCLP. Clear rules:

1. **Automatic updates: OFF.** Already applied; it avoids surprises.
2. **Do not install macOS Tahoe 26.7.1.** There is no support for this hardware.
3. **Do not install macOS updates** (not even minor ones) without checking first:
   - That the OCLP version supports them.
   - That there is a copy of the EFI and of the rescue USB drive.
   - That you know how to roll back.
4. **Safari** (18.6 and 26.6.1) is optional and lower risk, but it is not urgent either. You can keep using the current Safari or install Firefox/Chrome.
5. **After any macOS update**, OCLP will ask you to apply the root patch again. Do it before considering the system good.
6. **Do not install Security Response Updates (RSR)** on pre-Haswell systems: they fail. If they show up, ignore them.
7. **Apple ID is not necessary** for any of this.

## Other optional improvements

| Improvement | How | Impact |
|---|---|---|
| Prevent Spotlight from indexing the USB drive | `sudo mdutil -i off /Volumes/OCSONOMA` | Less disk activity. |
| Free up 8 GB from the `sleepimage` | `sudo rm -f /private/var/vm/sleepimage` | More space (not urgent). |
| Disable sleep if it fails to wake | `sudo pmset -a sleep 0` | Avoids freezes on wake. |
| Auto power-on after a power outage | `sudo pmset -a autorestart 1` | Useful if the machine is unattended. |
| Reduce transparency | Settings → Accessibility → Display → Reduce transparency | Less GPU load on an old machine. |
| Alternative browser | Firefox or Chrome | Less dependence on Safari. |

## Before any big change

- Back up the entire `EFI` folder.
- Have the `OCSONOMA` USB drive connected and tested.
- Write down which configuration you have (Phase 1 or Phase 2) and which `boot-args` you use.
- Do not make two changes at once: if something fails, you will know what caused it.

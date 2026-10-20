# 11 — Frequently Asked Questions (FAQ)

Quick answers to the most common questions about this build. Follow the links for more detail.

## General

### Is it legal to install macOS on this PC?

Installing macOS on non-Apple hardware may violate Apple's EULA. This repository is **educational documentation**: it does not distribute Apple software or third-party binaries, and each user is responsible for how they use the information. This is not legal advice.

### Why macOS Sonoma and not Sequoia or Tahoe?

Because **Sonoma 14.8.9 runs stably** on this hardware with OCLP 2.5.1. The Sequoia migration was cancelled to avoid breaking a working system, and **macOS Tahoe is not compatible** with Ivy Bridge / this patch set. See [`00-SUMMARY.md`](00-SUMMARY.md) and [`06-PERFORMANCE-AND-UPDATES.md`](06-PERFORMANCE-AND-UPDATES.md).

### Can I upgrade macOS to a major version?

No. Any major upgrade can invalidate OCLP's root patch and leave the system without graphics acceleration or unable to boot. The rule is: **do not update without checking compatibility first**. See [`06-PERFORMANCE-AND-UPDATES.md`](06-PERFORMANCE-AND-UPDATES.md).

### Can I install the Safari updates?

They are optional and low risk (Safari 18.6 and 26.6.1). They do not affect booting or the root patch. Install them if you want; if you prefer not to touch anything, the current Safari keeps working.

### Can I use Apple ID, iMessage or FaceTime?

They are not configured and **not required**. Technically they can work with a valid SMBIOS, but they are not guaranteed and add complexity. This build was designed to be used without an Apple ID.

### Does Wi-Fi work?

There is no built-in Wi-Fi; the board uses **Gigabit Ethernet**. For Wi-Fi you would need a compatible PCIe card or USB adapter plus additional kexts. See [`07-BLUETOOTH-DBT-122.md`](07-BLUETOOTH-DBT-122.md).

### Does Bluetooth work?

With the D-Link DBT-122 adapter, **no** (it is too old). With a modern USB adapter based on Broadcom BCM20702, the kexts already present in the EFI should be enough. See [`07-BLUETOOTH-DBT-122.md`](07-BLUETOOTH-DBT-122.md).

## Performance and hardware

### Why is the system slow to boot or open apps?

Because macOS is installed on a **5400 RPM HDD**. The rest of the hardware is fine; the disk is the bottleneck. The real upgrade is a **2.5" SATA SSD**. See [`06-PERFORMANCE-AND-UPDATES.md`](06-PERFORMANCE-AND-UPDATES.md).

### Is it worth replacing the HDD with an SSD?

Yes, it is the only really noticeable performance upgrade. A 480 GB–1 TB 2.5" SATA SSD (Crucial, Samsung, WD, Kingston) makes everything much smoother. The board is SATA II, so it will not reach theoretical maximums, but latency improves a lot.

### Can I clone the HDD to the SSD?

It is possible, but a **fresh install** on the SSD (same USB process) followed by copying your data is recommended. With OCLP, a clean install is more predictable than a clone. See [`06-PERFORMANCE-AND-UPDATES.md`](06-PERFORMANCE-AND-UPDATES.md).

### Can I upgrade the RAM?

No: the board supports **16 GB maximum** and 16 GB are already installed (2 × 8 GB). See [`00-SUMMARY.md`](00-SUMMARY.md).

### Can I use two monitors?

The RX 580 has several outputs and macOS usually handles them well. If you see glitches, check `agdpmod=vit9696` and WhateverGreen. It has not been tested on this machine with two displays.

### Can I play games or use Steam?

The RX 580 has Metal 2 acceleration, so many macOS games run with moderate performance. Do not expect miracles: the CPU is from 2012 and the disk is an HDD. For serious gaming, use Windows.

## Boot and troubleshooting

### What should I do if macOS will not boot?

1. Boot from the `OCSONOMA` USB drive.
2. Restore the previous configuration (`VOLVER-A-FASE1.command` or `RESTAURAR-CONFIG-ANTERIOR.cmd`).
3. If the internal EFI is the problem, copy it again.
4. Check [`08-TROUBLESHOOTING.md`](08-TROUBLESHOOTING.md).

### Can I have Windows and macOS on the same PC?

Yes. They are on different disks and are selected from the boot menu (F11 or OpenCore's own menu). **Do not touch the Windows EFI partition**: this build uses the macOS disk's EFI.

### Why does the clock change when switching from macOS to Windows?

Because macOS stores the BIOS clock in UTC and Windows interprets it as local time. The fix is to make Windows use UTC as well: run [`scripts/windows/ARREGLAR-RELOJ-DUALBOOT.cmd`](../../scripts/windows/ARREGLAR-RELOJ-DUALBOOT.cmd) as administrator and restart. It is explained in [`08-TROUBLESHOOTING.md`](08-TROUBLESHOOTING.md#clock-offset-when-switching-between-macos-and-windows).

### Why does EarTrumpet show a CLiP license error?

The Microsoft Store license was invalidated. The quickest fix is to reinstall it from the winget community catalog, which does not use a Store license:

```cmd
winget install --id File-New-Project.EarTrumpet --source winget
```

More details in [`08-TROUBLESHOOTING.md`](08-TROUBLESHOOTING.md#eartrumpet-clip-license-error).

### Why is the Riot Vanguard icon gray?

Because the `vgc` service does not start (often with the "Incorrect function" error). You can try to repair or reinstall it; if you do not play **VALORANT** or **League of Legends**, uninstall it (both require it when entering a match; TFT does not use it). Steps in [`08-TROUBLESHOOTING.md`](08-TROUBLESHOOTING.md#riot-vanguard-gray-icon-or-vgc-service-stopped).

### Can I enable FileVault?

It is not recommended: it complicates booting, OCLP root patching and recovery. If you need encryption, plan carefully and keep backups.

### What do "Phase 1" and "Phase 2" mean?

**Phase 1** is the configuration used to install macOS and apply the root patch (no acceleration, AMFI disabled). **Phase 2** is the daily-use configuration (AMFI enabled with AMFIPass and full acceleration). See [`02-EFI-OPENCORE.md`](02-EFI-OPENCORE.md) and [`03-OCLP-AND-ACCELERATION.md`](03-OCLP-AND-ACCELERATION.md).

### What is the "root patch" and why are the KDKs needed?

OCLP's **root patch** modifies system components to restore graphics acceleration (among other things) on unsupported hardware. The **KDKs** (Kernel Debug Kits) are needed to prepare those patches; they take about 2.5 GB and should be kept. See [`03-OCLP-AND-ACCELERATION.md`](03-OCLP-AND-ACCELERATION.md).

## Maintenance and backups

### How often should I do maintenance?

A **monthly** 5-minute routine (space, SMART, updates, EFI backup) is enough. Every three months, run the diagnostic. See [`04-MAINTENANCE.md`](04-MAINTENANCE.md).

### How do I back up the EFI?

Copy the `EFI` folder from the USB drive or the internal EFI partition to another USB drive, the cloud or another disk. It is small (a few MB) and it is your safety net if something stops booting. The `OCSONOMA` USB drive is already a rescue copy.

### Can I delete the `sleepimage` or the KDKs?

The `sleepimage` (8 GB) can be deleted, but it is not urgent and macOS may recreate it. The KDKs **should not** be deleted: they are used to re-apply root patches. See [`04-MAINTENANCE.md`](04-MAINTENANCE.md).

### Can I use Time Machine?

Yes, with an external disk. It does not require an Apple ID. This machine has no destination configured; you can add one if you want.

## About the repository

### Why isn't the full EFI with binaries included?

For size, licensing and security reasons: OpenCore, the kexts, OCLP and the recovery image are downloaded from their official sources. The repository includes the **sanitized configs**, the SSDT and the scripts; there is also a **release** with a ZIP of the configs + SSDT. See [`09-REFERENCES.md`](09-REFERENCES.md).

### Is there any personal data in the repository?

No: real serial numbers, MLB, UUID and MAC addresses were replaced by placeholders, and the IP address in the report was replaced with an example one. See [`10-LICENSES-AND-CREDITS.md`](10-LICENSES-AND-CREDITS.md).

### Can I contribute or report a bug?

Yes: open an *issue* or a *pull request* on GitHub. Do not include personal data (serials, MACs, UUIDs) in issues or PRs. See [`10-LICENSES-AND-CREDITS.md`](10-LICENSES-AND-CREDITS.md).

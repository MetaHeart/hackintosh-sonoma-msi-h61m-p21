# 03 — OCLP and Metal acceleration

## What OCLP is and why it is used here

**OpenCore Legacy Patcher (OCLP)** makes it possible to run modern versions of macOS on hardware that Apple no longer supports. On this machine it does two fundamental things:

1. **Booting on a CPU without AVX2** (Ivy Bridge), relying on `CryptexFixup`.
2. **GPU root patch** so that the **Radeon RX 580** works with **Metal 2** acceleration in Sonoma.

The version used is **OCLP 2.5.1**.

> OCLP has two clearly distinct functions: **creating/updating the OpenCore EFI** (the "Build and Install OpenCore" option, which is **not** used here) and **applying patches to the system** ("Post-Install Root Patch", which is the one that is used).

## The difference between Phase 1 and Phase 2

| | Phase 1 | Phase 2 |
|---|---|---|
| Goal | Install macOS and apply the root patch | Daily use with acceleration |
| AMFI | Disabled (`amfi=0x80`) | Enabled (AMFIPass + `-amfipassbeta`) |
| GPU | No acceleration (`-amd_no_dgpu_accel`) | Full acceleration |
| Boot | Verbose (`-v keepsyms=1 debug=0x100`) | Normal |
| Config | `config-fase1-instalacion.plist` | `config-fase2-aceleracion.plist` |

You install in Phase 1, apply the root patch, and then switch to Phase 2 with [`../scripts/macos/CAMBIAR-A-FASE2.command`](../../scripts/macos/CAMBIAR-A-FASE2.command).

## Root patch: how it was applied

1. macOS Sonoma 14.8.9 already installed and booting (in Phase 1).
2. **OpenCore-Patcher** opened from the USB drive or from Applications.
3. Click **Post-Install Root Patch** and wait. The process:
   - Checks the macOS version and the available patches.
   - Installs the required **KDKs** (Kernel Debug Kits) or uses `KDKlessWorkaround`.
   - Modifies the system's graphics components to restore AMD acceleration.
   - Asks for a reboot.
4. After rebooting, switch to Phase 2 and verify **Metal: Supported**.

On this machine the root patch was applied successfully and the RX 580 shows up with **Metal 2** in the System Report.

## KDK and KDKlessWorkaround

- OCLP uses the **Kernel Debug Kits** to prepare the patches. On this machine they were downloaded and take up about **2.5 GB** inside `/Library`.
- **Do not delete them**: if you ever need to patch again, they will save you the download.
- The EFI includes `KDKlessWorkaround.kext`, which allows patching on recent Sonoma versions when the KDK is not available or fails.

## AMFIPass and AMFI

- **AMFI** (Apple Mobile File Integrity) is a macOS security protection.
- To install and patch, it is temporarily disabled with `amfi=0x80` (Phase 1).
- In Phase 2 it is **re-enabled** and **AMFIPass 1.4.1** is used together with the `-amfipassbeta` argument, so that the system keeps AMFI enabled while the OCLP patches continue to work.
- If acceleration does not work with AMFI enabled, there is the variant [`config-fase2-amfi-off.plist`](../../efi/configs/config-fase2-amfi-off.plist), which adds `amfi=0x80` to Phase 2. It is a plan B, not the recommended configuration.

## Custom SIP

The `config.plist` sets `csr-active-config = 03080000` (`0x803`): it allows unsigned kexts, unapproved kexts and unrestricted access to the file system. It is what OCLP needs to apply the patches. **Do not change it** for the standard SIP: you would break the root patch and probably graphics boot.

## Verifying acceleration

In macOS:

```bash
# Does the GPU show up with Metal?
system_profiler SPDisplaysDataType | grep -E "Chipset|VRAM|Metal|Resolution"

# Are the key kexts loaded?
kmutil showloaded | grep -Ei "lilu|whatevergreen|amfipass|cryptexfixup|voodoohda|rtl8111"

# What boot arguments are set?
nvram boot-args

# SIP status?
csrutil status
```

Expected result: `AMD Radeon RX 580`, `Metal: Supported`, the kexts loaded and the Phase 2 `boot-args`.

## If something goes wrong

| Problem | Solution |
|---|---|
| No acceleration after the root patch | Try `config-fase2-amfi-off.plist`; if it is still the same, go back to Phase 1 and repeat the root patch. |
| Black screen when booting Phase 2 | Boot in Phase 1 and check `boot-args`; try the AMFI off variant. |
| OCLP asks for the KDK and the download fails | Use `KDKlessWorkaround` (already included) or download the KDK manually from Apple Developer. |
| "Root Patch" disabled | Check the macOS version and that OCLP 2.5.1 recognizes it; do not update macOS. |
| After a GPU change | Apply the root patch again. |

## Warnings

- **Do not update macOS** (not even a minor update) without first checking compatibility with your version of OCLP. A build change invalidates the patches.
- **Do not click "Build and Install OpenCore"** in OCLP: your EFI already works; that option can overwrite it.
- **Do not enable FileVault**: it complicates booting and the patches.
- **Do not delete** `/Library/Apple/System/Library/Extensions` or the KDKs.
- **Keep a copy of the EFI** on the OCSONOMA USB drive and on another medium.

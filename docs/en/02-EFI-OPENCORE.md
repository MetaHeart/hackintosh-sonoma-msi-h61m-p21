# 02 — EFI and OpenCore

This document details the configuration the machine boots with. It is based on an actual inspection of the project's files, not on assumptions.

> **The `config.plist` files in this repository are sanitized:** the `SystemSerialNumber`, `MLB`, `SystemUUID`, and `ROM` fields were replaced with placeholders (`TU-SERIAL-AQUI`, `TU-MLB-AQUI`, `00000000-0000-0000-0000-000000000000`, and `00:00:00:00:00:00`). **Generate your own SMBIOS before using any of them.**

## Version and structure

- **OpenCore 1.0.8** (verified with `ocvalidate` from the same version).
- Structure used on the USB drive and in the internal EFI:

```text
EFI/
├── BOOT/
│   └── BOOTx64.efi              # Loader that launches OpenCore
└── OC/
    ├── OpenCore.efi             # OpenCore core
    ├── config.plist             # Active configuration (Phase 1 or Phase 2)
    ├── ACPI/
    │   └── SSDT-EC-USBX.aml     # EC device + USBX definition
    ├── Drivers/
    │   ├── HfsPlus.efi          # HFS+ support (recovery)
    │   ├── OpenRuntime.efi      # OpenCore runtime (required)
    │   └── ResetNvramEntry.efi  # Menu entry to clear NVRAM
    └── Kexts/
        ├── Lilu.kext
        ├── VirtualSMC.kext
        ├── WhateverGreen.kext
        ├── RestrictEvents.kext
        ├── CryptexFixup.kext
        ├── AMFIPass.kext
        ├── KDKlessWorkaround.kext
        ├── AppleIntelCPUPowerManagementClient.kext
        ├── AppleIntelCPUPowerManagement.kext
        ├── RealtekRTL8111.kext
        ├── BrcmFirmwareData.kext
        ├── BrcmPatchRAM3.kext
        ├── BlueToolFixup.kext
        └── VoodooHDA_BL.kext
```

The binaries are **not** included in this repository. They are downloaded from their official sources (see [`09-REFERENCES.md`](09-REFERENCES.md)):

- `OpenCore.efi`, `BOOTx64.efi`, `OpenRuntime.efi`, `ResetNvramEntry.efi` → **OpenCorePkg** 1.0.8.
- `HfsPlus.efi` → Apple's HFS+ driver, distributed with OpenCore.
- `SSDT-EC-USBX.aml` → included in this repository ([`../efi/ACPI/SSDT-EC-USBX.aml`](../../efi/ACPI/SSDT-EC-USBX.aml)).

## Kexts: versions, order, and purpose

The order in `Kernel > Add` matters: **Lilu must come first**, and the kexts that depend on Lilu come after.

| # | Kext | Version | `MinKernel` | Purpose |
|---|---|---|---|---|
| 1 | `Lilu.kext` | 1.7.2 | — | Foundation for the other Acidanthera kexts. |
| 2 | `VirtualSMC.kext` | 1.3.8 | — | SMC emulation (sensors, boot). |
| 3 | `WhateverGreen.kext` | 1.7.1 | — | GPU patches (AMD/Intel), `agdpmod`, etc. |
| 4 | `RestrictEvents.kext` | 1.1.6 | 20.4.0 (Big Sur 11.4) | Manages the `revpatch`/`revblock` variables and blocks analytics processes on unsupported hardware. |
| 5 | `CryptexFixup.kext` | 1.0.5 | 22.0.0 (Sonoma) | Allows booting modern macOS on CPUs **without AVX2** (Ivy Bridge). |
| 6 | `AMFIPass.kext` | 1.4.1 | 21.0.0 (Monterey) | Lets AMFI stay active while OCLP applies patches (with `-amfipassbeta`). |
| 7 | `KDKlessWorkaround.kext` | 1.0.0 | 22.3.0 (Sonoma 14.3) | Support for the root patch when the KDK is not available. |
| 8 | `AppleIntelCPUPowerManagementClient.kext` | 222.0.0 | 22.0.0 | CPU power management (client). |
| 9 | `AppleIntelCPUPowerManagement.kext` | 222.0.0 | 22.0.0 | CPU power management (SpeedStep) for Ivy Bridge. |
| 10 | `RealtekRTL8111.kext` | 3.0.4 | — | Realtek Gigabit Ethernet. |
| 11 | `BrcmFirmwareData.kext` | 2.7.2 | — | Firmware for Broadcom adapters (attempt with the DBT-122). |
| 12 | `BrcmPatchRAM3.kext` | 2.7.2 | 20.0.0 | Broadcom firmware loading (attempt with the DBT-122). |
| 13 | `BlueToolFixup.kext` | 2.7.2 | 21.0.0 | Patch for the Bluetooth stack on Monterey+ (attempt with the DBT-122). |
| 14 | `VoodooHDA_BL.kext` | 3.7.0 | — | VIA VT1708S audio (AppleALC does not support it). |

> The three `Brcm*`/`BlueToolFixup` kexts only make sense if you are trying to use a compatible Broadcom adapter. They do not work with the D-Link DBT-122. If you are not going to use Bluetooth, you can remove them from `Kernel > Add` and from the `Kexts` folder (the variant [`../efi/configs/config-fase2-antes-bluetooth.plist`](../../efi/configs/config-fase2-antes-bluetooth.plist) reflects that situation: 10 kexts instead of 14).

## Boot-args per phase

| Phase | `boot-args` |
|---|---|
| **Phase 1 (installation)** | `-v keepsyms=1 debug=0x100 agdpmod=vit9696 -wegnoigpu -amfipassbeta ipc_control_port_options=0 amfi=0x80 -amd_no_dgpu_accel` |
| **Phase 1 VMM/HV** | Same as Phase 1 (the changes are in the patches, not in the args). |
| **Phase 2 (daily)** | `agdpmod=vit9696 -wegnoigpu -amfipassbeta ipc_control_port_options=0` |
| **Phase 2 AMFI off** | `agdpmod=vit9696 -wegnoigpu -amfipassbeta ipc_control_port_options=0 amfi=0x80` |

Meaning:

- `agdpmod=vit9696`: WhateverGreen patch for AMD GPUs with a Mac SMBIOS; prevents a black screen.
- `-wegnoigpu`: disables the integrated GPU (HD 4000), which is not used here.
- `-amfipassbeta`: enables AMFIPass behavior with AMFI active.
- `ipc_control_port_options=0`: compatibility setting recommended for this build.
- `-v keepsyms=1 debug=0x100`: verbose boot with symbols (for diagnostics only).
- `amfi=0x80`: disables AMFI (needed for installation and for the "AMFI off" variant).
- `-amd_no_dgpu_accel`: boots without AMD acceleration (to install and patch without conflicts).

## NVRAM and SIP

- `csr-active-config` = `03080000` (little-endian: `0x803`). It partially disables SIP, allowing:
  - Unsigned kexts (`CSR_ALLOW_UNTRUSTED_KEXTS`).
  - Unrestricted filesystem (`CSR_ALLOW_UNRESTRICTED_FS`).
  - Unapproved kexts (`CSR_ALLOW_UNAPPROVED_KEXTS`).

  This is the typical OCLP configuration. **Do not change it** to full SIP: the root patch would stop working.
- `NVRAM > Delete` includes: `rtc-blacklist`, `revpatch`, `revblock`, `OCLP-Settings`, `OCLP-Version`, `OCLP-Model`, `OCLP-Spoofed-SN`, `OCLP-Spoofed-MLB`. OpenCore deletes them on every boot so that OCLP regenerates them cleanly. You don't need to define them by hand.
- `SecureBootModel` = `Disabled` (required for OCLP).
- `Vault` = `Optional`, `DmgLoading` = `Signed`, `AllowNvramReset` = `None`, `AllowSetDefault` = `True`.

## SMBIOS

- Model: **`iMac13,2`** (native Ivy Bridge, with a dedicated AMD GPU).
- `SystemMemoryStatus` = `Auto`, `ProcessorType` = `0`.
- The personal values are **sanitized** in the repository configs.
- To generate your own:
  1. Download **GenSMBIOS** (it uses `macserial`).
  2. Generate an `iMac13,2` SMBIOS (serial, MLB, UUID).
  3. Fill in `PlatformInfo > Generic` in your `config.plist` with ProperTree or OCAT.
  4. For `ROM`, you can use the MAC of `en0` or `00:00:00:00:00:00`.
  5. Validate with `ocvalidate`.

## Patches (`Kernel > Patch` and `Booter > Patch`)

**Phase 2 (daily use) — 6 kernel patches:**

1. Force FileVault on Broken Seal.
2. Disable Library Validation Enforcement.
3. Disable `_csr_check()` in `_vnode_check_signature`.
4. Disable Root Hash validation.
5. CaseySJ — Fix PCI bus enumeration (Ventura).
6. Fix PCI bus enumeration (Sonoma).

**Phase 1 VMM/HV — adds 4 patches:** Reroute `kern.hv_vmm_present` (1), (2) Legacy, and (2) Ventura, and Force `IOGetVMMPresent`. They help the installer accept the machine when an unsupported model resists.

**Booter:**

- `Skip Board ID check` (prevents macOS from refusing to boot because of the model).
- The VMM/HV variant adds `Reroute HW_BID to OC_BID`.

All these patches come from the set used by **OpenCore Legacy Patcher**; they are applied on the fly and are reversible. If you update OpenCore or change macOS versions, check that they are still valid.

## Notable quirks

**Booter:** `AvoidRuntimeDefrag`, `EnableSafeModeSlide`, `EnableWriteUnprotector`, `FixupAppleEfiImages`, `ProvideCustomSlide`, `SetupVirtualMap`, and `ResizeAppleGpuBars=-1`.

**Kernel:** `AppleCpuPmCfgLock` (if the BIOS locks MSR 0xE2), `DisableIoMapper` (prevents VT-d/IOMMU issues), `DisableLinkeditJettison`, `PanicNoKextDump`, `PowerTimeoutKernelPanic`, `SetApfsTrimTimeout=-1`.

**UEFI:** `EnableVectorAcceleration`, `IgnoreInvalidFlexRatio` (fix for MSR 0x194 on Ivy Bridge), `RequestBootVarRouting`, `ResizeGpuBars=-1`.

These values are what was left after tuning; do not change them without a specific reason.

## Included configurations

| File | When to use it |
|---|---|
| [`config-fase1-instalacion.plist`](../../efi/configs/config-fase1-instalacion.plist) | Installing macOS and running the root patch. |
| [`config-fase1-vmm-hv.plist`](../../efi/configs/config-fase1-vmm-hv.plist) | If the installer refuses because of an "unsupported model". |
| [`config-fase2-aceleracion.plist`](../../efi/configs/config-fase2-aceleracion.plist) | Daily use, with AMFI active and AMFIPass. |
| [`config-fase2-amfi-off.plist`](../../efi/configs/config-fase2-amfi-off.plist) | If acceleration does not work properly with the normal Phase 2. |
| [`config-fase2-antes-bluetooth.plist`](../../efi/configs/config-fase2-antes-bluetooth.plist) | Clean Phase 2 variant without the Bluetooth kexts (10 kexts). |

More information about how they were generated in [`../scripts/build/build_config_sanitized.py`](../../scripts/build/build_config_sanitized.py).

## Validation

On Windows:

```powershell
ocvalidate.exe ruta\al\config.plist
```

On macOS:

```bash
./ocvalidate /Volumes/EFI/EFI/OC/config.plist
```

> With the repository placeholders, `ocvalidate` will warn that the SMBIOS is not valid; this is expected. After you enter your real serial/MLB/UUID, it should not report serious errors.

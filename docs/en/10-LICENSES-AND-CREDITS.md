# 10 — Licenses, disclaimer and credits

## License of this repository

Unless otherwise indicated, **the documentation and the repository's own scripts are published under the MIT license**. The full text is in [`../../LICENSE`](../../LICENSE).

You may use, copy, modify and redistribute this content as long as you keep the copyright notice and the license. It is provided **without warranty**.

## Third-party components

This repository **does not redistribute** third-party binaries. The `config.plist` files and documents refer to projects that keep **their own licenses**:

| Project | License (check the repository) |
|---|---|
| OpenCorePkg | BSD-3-Clause |
| Lilu, WhateverGreen, VirtualSMC, RestrictEvents | BSD-3-Clause |
| BrcmPatchRAM | BSD-3-Clause |
| CryptexFixup | See repository |
| AMFIPass | See repository |
| KDKlessWorkaround | See repository |
| RealtekRTL8111 (Mieze) | **GPLv2** |
| VoodooHDA | See repository / SourceForge |
| OpenCore Legacy Patcher | See repository |
| Dortania / OCLP4Hackintosh guides | They keep the license of their authors |

By downloading and using those components, you accept **their** licenses and conditions.

## Apple software

- **No** Apple software is included: neither macOS, nor recovery images, nor KDKs, nor proprietary drivers.
- macOS is the property of Apple and installing it on non-Apple hardware may infringe Apple's license agreement. This repository is **educational documentation**; each user decides how to use it.

## Personal data

The files in this repository were **sanitized** before publication:

- `SystemSerialNumber`, `MLB`, `SystemUUID` and `ROM` in the `config.plist` files were replaced with placeholders.
- The IP address in the diagnostic report was replaced with a sample one.
- No raw reports with serials, MACs, hardware UUIDs or user/computer names are included.

If you find any personal data by mistake, open an *issue* so it can be corrected.

## Disclaimer

This project is offered **as is**, without warranty of any kind. An incorrect `config.plist`, an incompatible kext or a badly executed command can:

- Prevent the machine from booting.
- Cause data loss.
- Damage Windows or other system installations.

**Make backups and always test from a rescue USB drive.** Neither the authors nor the contributors are responsible for damage resulting from the use of this information.

## Credits

- **[Acidanthera](https://github.com/acidanthera)** — OpenCore, Lilu, WhateverGreen, VirtualSMC, RestrictEvents, BrcmPatchRAM and much of the ecosystem.
- **[Dortania](https://dortania.github.io/)** — OpenCore Install Guide and OpenCore Legacy Patcher.
- **[5T33Z0](https://github.com/5T33Z0/OCLP4Hackintosh)** — guide specific to Ivy Bridge.
- **[khronokernel](https://github.com/khronokernel)** — CryptexFixup and VoodooHDA.
- **[dhinakg](https://github.com/dhinakg)** — AMFIPass.
- **[flagersgit](https://github.com/flagersgit/KDKlessWorkaround)** — KDKlessWorkaround.
- **[Mieze](https://github.com/Mieze/RTL8111_driver_for_OS_X)** — RealtekRTL8111.
- **[CorpNewt](https://github.com/corpnewt)** — GenSMBIOS, ProperTree, SSDTTime, MountEFI.
- **[ic005k](https://github.com/ic005k/OCAuxiliaryTools)** — OCAT.
- To the **Hackintosh community** (r/Hackintosh, InsanelyMac and Spanish-speaking forums) for sharing knowledge and answering questions.

## How to contribute

If you find a mistake, a typo or an improvement:

1. Open an *issue* describing the problem.
2. If you want to propose a change, submit a *pull request*.
3. Do not include personal data (serials, MACs, UUIDs) in issues or PRs.
4. Keep the didactic tone and Spanish, except in `README.en.md`.

Thanks for reading and for keeping shared knowledge alive.

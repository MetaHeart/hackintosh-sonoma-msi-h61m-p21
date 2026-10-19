# 10 — Licencias, descargo y créditos

## Licencia de este repositorio

Salvo que se indique lo contrario, **la documentación y los scripts propios de este repositorio se publican bajo la licencia MIT**. El texto completo está en [`../LICENSE`](../LICENSE).

Puedes usar, copiar, modificar y redistribuir este contenido manteniendo el aviso de copyright y la licencia. Se ofrece **sin garantía**.

## Componentes de terceros

Este repositorio **no redistribuye** binarios de terceros. Los `config.plist` y documentos hacen referencia a proyectos que conservan **sus propias licencias**:

| Proyecto | Licencia (consulta el repositorio) |
|---|---|
| OpenCorePkg | BSD-3-Clause |
| Lilu, WhateverGreen, VirtualSMC, RestrictEvents | BSD-3-Clause |
| BrcmPatchRAM | BSD-3-Clause |
| CryptexFixup | Ver repositorio |
| AMFIPass | Ver repositorio |
| KDKlessWorkaround | Ver repositorio |
| RealtekRTL8111 (Mieze) | **GPLv2** |
| VoodooHDA | Ver repositorio / SourceForge |
| OpenCore Legacy Patcher | Ver repositorio |
| Guías de Dortania / OCLP4Hackintosh | Conservan la licencia de sus autores |

Al descargar y usar esos componentes, aceptas **sus** licencias y condiciones.

## Software de Apple

- **No** se incluye software de Apple: ni macOS, ni imágenes de recuperación, ni KDKs, ni controladores propietarios.
- macOS es propiedad de Apple y su instalación en hardware que no es de Apple puede infringir el contrato de licencia de Apple. Este repositorio es **documentación educativa**; cada usuario decide cómo usarla.

## Datos personales

Los archivos de este repositorio fueron **saneados** antes de publicarse:

- `SystemSerialNumber`, `MLB`, `SystemUUID` y `ROM` de los `config.plist` fueron sustituidos por marcadores.
- La dirección IP del informe de diagnóstico fue reemplazada por una de ejemplo.
- No se incluyen informes crudos con seriales, MACs, UUIDs de hardware ni nombres de usuario/equipo.

Si encuentras algún dato personal por error, abre un *issue* para que se corrija.

## Descargo de responsabilidad

Este proyecto se ofrece **tal cual**, sin garantía de ningún tipo. Un `config.plist` incorrecto, un kext incompatible o un comando mal ejecutado pueden:

- Impedir que el equipo arranque.
- Provocar pérdida de datos.
- Dañar instalaciones de Windows u otros sistemas.

**Haz copias de seguridad y prueba siempre desde un pendrive de rescate.** Ni los autores ni los colaboradores se hacen responsables de daños derivados del uso de esta información.

## Créditos

- **[Acidanthera](https://github.com/acidanthera)** — OpenCore, Lilu, WhateverGreen, VirtualSMC, RestrictEvents, BrcmPatchRAM y buena parte del ecosistema.
- **[Dortania](https://dortania.github.io/)** — OpenCore Install Guide y OpenCore Legacy Patcher.
- **[5T33Z0](https://github.com/5T33Z0/OCLP4Hackintosh)** — guía específica para Ivy Bridge.
- **[khronokernel](https://github.com/khronokernel)** — CryptexFixup y VoodooHDA.
- **[dhinakg](https://github.com/dhinakg)** — AMFIPass.
- **[flagersgit](https://github.com/flagersgit/KDKlessWorkaround)** — KDKlessWorkaround.
- **[Mieze](https://github.com/Mieze/RTL8111_driver_for_OS_X)** — RealtekRTL8111.
- **[CorpNewt](https://github.com/corpnewt)** — GenSMBIOS, ProperTree, SSDTTime, MountEFI.
- **[ic005k](https://github.com/ic005k/OCAuxiliaryTools)** — OCAT.
- A la **comunidad Hackintosh** (r/Hackintosh, InsanelyMac y foros hispanos) por compartir conocimiento y resolver dudas.

## Cómo contribuir

Si encuentras un error, una errata o una mejora:

1. Abre un *issue* describiendo el problema.
2. Si quieres proponer un cambio, envía un *pull request*.
3. No incluyas datos personales (seriales, MACs, UUIDs) en issues o PRs.
4. Mantén el tono didáctico y en español, salvo en `README.en.md`.

Gracias por leer y por mantener vivo el conocimiento compartido.

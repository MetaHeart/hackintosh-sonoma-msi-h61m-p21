# Hackintosh macOS Sonoma — MSI H61M-P21 + i7-3770 + Radeon RX 580

Guía completa, configuraciones y resultados de un **Hackintosh funcional con macOS Sonoma 14.8.9** sobre hardware Intel Ivy Bridge, usando **OpenCore 1.0.8** y **OpenCore Legacy Patcher (OCLP) 2.5.1**.

> **Estado:** ✅ sistema estable, gráfica con aceleración Metal 2, Ethernet a 1 Gb/s, audio funcionando y arranque sin pendrive.
> **Pendiente:** el adaptador Bluetooth USB D-Link DBT-122 se detecta pero no funciona (aplazado).

Este repositorio recopila **pasos, instrucciones, configuraciones, referencias, modificaciones y especificaciones** para que cualquiera pueda estudiar o replicar este montaje. Los binarios de terceros (OpenCore, kexts, OCLP, imagen de recuperación de macOS) **no** se redistribuyen aquí: se enlazan sus fuentes oficiales en [`docs/09-REFERENCIAS.md`](docs/09-REFERENCIAS.md).

La pestaña **[Releases](https://github.com/MetaHeart/hackintosh-sonoma-msi-h61m-p21/releases)** incluye un ZIP con los `config.plist` saneados y el `SSDT-EC-USBX.aml` (solo material propio, sin binarios).

> **Versión en inglés:** [`README.en.md`](README.en.md) · Documentación completa en [`docs/en/`](docs/en/).

---

## Índice

| Documento | Contenido |
|---|---|
| [`docs/00-RESUMEN.md`](docs/00-RESUMEN.md) | Resumen del proyecto, decisiones y estado actual. |
| [`docs/01-INSTALACION.md`](docs/01-INSTALACION.md) | Guía de instalación paso a paso (Fase 1 → Fase 2 → EFI interna). |
| [`docs/02-EFI-OPENCORE.md`](docs/02-EFI-OPENCORE.md) | Detalle del EFI: OpenCore, kexts, boot-args, quirks y parches. |
| [`docs/03-OCLP-Y-ACELERACION.md`](docs/03-OCLP-Y-ACELERACION.md) | OpenCore Legacy Patcher, root patch, KDK y aceleración Metal. |
| [`docs/04-MANTENIMIENTO.md`](docs/04-MANTENIMIENTO.md) | Mantenimiento, ajustes recomendados y copias de seguridad. |
| [`docs/05-DIAGNOSTICO-Y-RESULTADOS.md`](docs/05-DIAGNOSTICO-Y-RESULTADOS.md) | Scripts de diagnóstico y resultados reales del equipo. |
| [`docs/06-RENDIMIENTO-Y-ACTUALIZACIONES.md`](docs/06-RENDIMIENTO-Y-ACTUALIZACIONES.md) | HDD vs SSD, política de actualizaciones y mejoras. |
| [`docs/07-BLUETOOTH-DBT-122.md`](docs/07-BLUETOOTH-DBT-122.md) | Intento de Bluetooth con D-Link DBT-122 y estado actual. |
| [`docs/08-SOLUCION-DE-PROBLEMAS.md`](docs/08-SOLUCION-DE-PROBLEMAS.md) | Problemas comunes y cómo resolverlos. |
| [`docs/09-REFERENCIAS.md`](docs/09-REFERENCIAS.md) | Enlaces oficiales, herramientas y versiones usadas. |
| [`docs/10-LICENCIAS-Y-CREDITOS.md`](docs/10-LICENCIAS-Y-CREDITOS.md) | Licencias, descargo de responsabilidad y créditos. |
| [`docs/11-PREGUNTAS-FRECUENTES.md`](docs/11-PREGUNTAS-FRECUENTES.md) | Preguntas frecuentes (FAQ). |
| [`docs/en/`](docs/en/) | Documentación completa en inglés (incluye FAQ). |
| [`docs/originales/`](docs/originales/) | Guías originales en texto plano tal como se usaron. |
| [`docs/ejemplos/`](docs/ejemplos/) | Ejemplos de informes y registros (datos personales eliminados). |
| [`efi/configs/`](efi/configs/) | Configuraciones `config.plist` saneadas (sin números de serie). |
| [`scripts/`](scripts/) | Scripts de instalación, diagnóstico y mantenimiento. |

---

## Resumen del equipo

| Componente | Modelo / Detalle |
|---|---|
| **CPU** | Intel Core i7-3770 (Ivy Bridge, 4 núcleos / 8 hilos, 3,4–3,9 GHz, 8 MB L3, 77 W, LGA1155, **sin AVX2**) |
| **Placa base** | MSI H61M-P21 (MS-7680) v3.0, chipset Intel H61, BIOS V19.2 |
| **RAM** | 16 GB DDR3 (2 × 8 GB; el chipset H61 puede funcionar a 1333 MHz) |
| **Gráfica** | AMD Radeon RX 580 8 GB GDDR5 (Polaris), PCIe x16, **Metal 2** funcionando |
| **Pantalla** | 1360 × 768 a 60 Hz (TV/monitor por HDMI) |
| **Ethernet** | Realtek RTL8111/8168H Gigabit (1 Gb/s) |
| **Audio** | VIA VT1708S onboard (VoodooHDA 3.7.0) |
| **Disco de macOS** | Seagate ST500LT012-1DG142, 500 GB, 2,5", 5400 RPM, SATA |
| **Otros discos** | SSD Crucial BX500 480 GB (Windows), SSD Kingston A400 240 GB, HDD HGST 1 TB |
| **USB** | USB 2.0 (teclado, ratón y pendrive OCSONOMA de rescate) |
| **Bluetooth** | D-Link DBT-122 (Broadcom BCM2045) — detectado, no funcional |
| **SMBIOS** | `iMac13,2` |

| Software | Versión |
|---|---|
| macOS | Sonoma 14.8.9 (build 23J631), Darwin 23.6.0 |
| OpenCore | 1.0.8 |
| OpenCore Legacy Patcher | 2.5.1 (root patch aplicado) |
| Lilu | 1.7.2 |
| WhateverGreen | 1.7.1 |
| VirtualSMC | 1.3.8 |
| RestrictEvents | 1.1.6 |
| CryptexFixup | 1.0.5 |
| AMFIPass | 1.4.1 |
| RealtekRTL8111 | 3.0.4 |
| VoodooHDA | 3.7.0 |

---

## Qué funciona y qué no

**Funciona:**

- Arranque por OpenCore, con y sin pendrive (EFI copiada al disco interno).
- Aceleración gráfica AMD RX 580 con **Metal 2** y resolución 1360 × 768.
- Ethernet Gigabit (Realtek RTL8111).
- Audio VIA VT1708S (salida, micrófono y SPDIF) con VoodooHDA.
- Sueño del sistema y suspensión de pantalla (con `disksleep` desactivado).
- Windows y sus discos intactos (arranque dual mediante menú F11/OpenCore).

**No funciona (o está pendiente):**

- **Bluetooth D-Link DBT-122**: el adaptador aparece en USB, pero no hay Bluetooth. Es hardware demasiado antiguo (BCM2045) para el stack actual; queda aplazado. Ver [`docs/07-BLUETOOTH-DBT-122.md`](docs/07-BLUETOOTH-DBT-122.md).
- Actualización a macOS Tahoe 26.7.1: **no compatible** con este equipo/OCLP. No instalar.

---

## Resultados del diagnóstico

Datos reales del equipo (informe saneado en [`docs/ejemplos/RESULTADO-DIAGNOSTICO-SANITIZADO.txt`](docs/ejemplos/RESULTADO-DIAGNOSTICO-SANITIZADO.txt)):

| Métrica | Valor |
|---|---|
| Capacidad del contenedor APFS | 499,9 GB |
| Usado por macOS | **33,8 GB (6,8 %)** |
| Libre | **466,1 GB (93,2 %)** |
| SMART de todos los discos | `Verified` |
| RAM | 16 GB, swap usado: 0 MB |
| FileVault | Desactivado |
| SIP | Personalizado por OCLP (`csr-active-config=03080000`) |
| Actualizaciones automáticas | Desactivadas (sistema y usuario) |
| Suspensión del disco duro | Desactivada (`disksleep 0`) |

Detalles y desglose completo en [`docs/05-DIAGNOSTICO-Y-RESULTADOS.md`](docs/05-DIAGNOSTICO-Y-RESULTADOS.md).

---

## Estructura del repositorio

```text
.
├── README.md                     Este documento (español)
├── README.en.md                  Versión completa en inglés
├── LICENSE                       Licencia MIT (solo para el contenido de este repo)
├── docs/
│   ├── 00-RESUMEN.md             Resumen y decisiones del proyecto
│   ├── 01-INSTALACION.md         Guía de instalación paso a paso
│   ├── 02-EFI-OPENCORE.md        Configuración de OpenCore y kexts
│   ├── 03-OCLP-Y-ACELERACION.md  Root patch de OCLP y Metal 2
│   ├── 04-MANTENIMIENTO.md       Mantenimiento y ajustes
│   ├── 05-DIAGNOSTICO-Y-RESULTADOS.md
│   ├── 06-RENDIMIENTO-Y-ACTUALIZACIONES.md
│   ├── 07-BLUETOOTH-DBT-122.md
│   ├── 08-SOLUCION-DE-PROBLEMAS.md
│   ├── 09-REFERENCIAS.md
│   ├── 10-LICENCIAS-Y-CREDITOS.md
│   ├── 11-PREGUNTAS-FRECUENTES.md  FAQ
│   ├── en/                       Traducción completa al inglés (docs/en/README.md)
│   ├── originales/               Guías originales en texto plano
│   └── ejemplos/                 Informes saneados de ejemplo
├── efi/
│   ├── configs/                  config.plist saneados (Fase 1, Fase 2, variantes)
│   └── ACPI/                     SSDT-EC-USBX.aml
└── scripts/
    ├── macos/                    Scripts .command para ejecutar en macOS
    ├── windows/                  Scripts .cmd/.ps1/.py para preparar el USB
    └── build/                    Script de generación de configs (ejemplo saneado)
```

---

## Cómo usar este repositorio

### Si quieres replicar el montaje

1. Lee primero [`docs/00-RESUMEN.md`](docs/00-RESUMEN.md) y [`docs/09-REFERENCIAS.md`](docs/09-REFERENCIAS.md).
2. Sigue [`docs/01-INSTALACION.md`](docs/01-INSTALACION.md) de principio a fin.
3. Usa los configs saneados de [`efi/configs/`](efi/configs/) como punto de partida. **Importante:** los números de serie, MLB, UUID y ROM están sustituidos por marcadores; genera tu propio SMBIOS con GenSMBIOS/OCAT antes de arrancar.
4. Aplica el root patch de OCLP siguiendo [`docs/03-OCLP-Y-ACELERACION.md`](docs/03-OCLP-Y-ACELERACION.md).
5. Verifica el resultado con los scripts de [`scripts/macos/`](scripts/macos/).

### Si ya tienes un montaje similar

- [`docs/04-MANTENIMIENTO.md`](docs/04-MANTENIMIENTO.md): rutinas recomendadas.
- [`docs/05-DIAGNOSTICO-Y-RESULTADOS.md`](docs/05-DIAGNOSTICO-Y-RESULTADOS.md): cómo generar un informe del estado real.
- [`docs/06-RENDIMIENTO-Y-ACTUALIZACIONES.md`](docs/06-RENDIMIENTO-Y-ACTUALIZACIONES.md): qué mejorar y qué **no** instalar.
- [`docs/08-SOLUCION-DE-PROBLEMAS.md`](docs/08-SOLUCION-DE-PROBLEMAS.md): problemas típicos y soluciones.

---

## Aviso legal

Este repositorio tiene **fines educativos y de documentación**. Instalar macOS en hardware que no es de Apple puede infringir el contrato de licencia de Apple; cada usuario es responsable de cómo use esta información. En este repositorio:

- **No** se distribuye software de Apple (ni macOS, ni Recovery, ni KDKs).
- **No** se distribuyen binarios de OpenCore, kexts ni OCLP; solo enlaces oficiales.
- **No** se incluyen datos personales: los números de serie, MLB, UUID y MAC reales fueron sustituidos por marcadores.
- Las configuraciones se ofrecen **tal cual**, sin garantía. Un `config.plist` incorrecto puede impedir el arranque.

---

## Créditos

Este montaje no sería posible sin el trabajo de:

- **[Acidanthera](https://github.com/acidanthera)** — OpenCore, Lilu, WhateverGreen, VirtualSMC, RestrictEvents y BrcmPatchRAM.
- **[Dortania](https://dortania.github.io/OpenCore-Install-Guide/)** — OpenCore Install Guide.
- **[OpenCore Legacy Patcher](https://github.com/dortania/OpenCore-Legacy-Patcher)** — root patches para hardware no soportado.
- **[5T33Z0 / OCLP4Hackintosh](https://github.com/5T33Z0/OCLP4Hackintosh)** — guía específica para Ivy Bridge.
- **[khronokernel](https://github.com/khronokernel)** — CryptexFixup y VoodooHDA.
- **[dhinakg](https://github.com/dhinakg)** — AMFIPass.
- **[Mieze](https://github.com/Mieze/RTL8111_driver_for_OS_X)** — RealtekRTL8111.
- **[CorpNewt](https://github.com/corpnewt)** — GenSMBIOS y ProperTree.
- Y a la comunidad Hackintosh en general.

---

## Licencia

El contenido original de este repositorio (documentación y scripts propios) se publica bajo **licencia MIT**. Los componentes de terceros mencionados conservan sus propias licencias. Ver [`docs/10-LICENCIAS-Y-CREDITOS.md`](docs/10-LICENCIAS-Y-CREDITOS.md).

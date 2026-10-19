# 00 — Resumen del proyecto

Este documento resume **qué se hizo, por qué y en qué estado quedó** el Hackintosh.

## Punto de partida

Se quería instalar macOS Sonoma en un PC antiguo (Intel Ivy Bridge, placa H61, Radeon RX 580) y dejar un sistema **estable, documentado y repetible**. El proceso se dividió en fases para separar la instalación (sin aceleración gráfica) de la aceleración definitiva (con parches de OCLP).

## Decisiones tomadas

| Decisión | Motivo |
|---|---|
| **Mantener macOS Sonoma 14.8.9** | Funciona bien; actualizar a macOS Tahoe 26.7.1 rompería la compatibilidad con Ivy Bridge/OCLP. |
| **No instalar actualizaciones de macOS sin consultar** | Un cambio de build puede invalidar el root patch de OCLP. |
| **Actualizaciones automáticas desactivadas** | Evita que macOS descargue o instale algo por su cuenta. |
| **Sin Apple ID ni FileVault** | No son necesarios para este uso y añaden complejidad. |
| **Solo Ethernet** | El Wi-Fi/Bluetooth integrado no existe en esta placa; el adaptador Bluetooth antiguo no es compatible. |
| **No reflashear la VBIOS de la GPU** | Riesgo alto y no aporta nada con la RX 580 ya funcionando. |
| **OCLP 2.5.1 se queda como está** | "Build and Install OpenCore" no se usa; solo el root patch. |
| **No limpiadores ni antivirus ni "desfragmentar APFS"** | Innecesario y potencialmente dañino. |
| **Conservar el pendrive OCSONOMA** | Sirve de rescate y de arranque de emergencia. |
| **SSD SATA como única mejora real** | El HDD de 5400 RPM es el cuello de botella; la mejora es grande pero opcional. |

## Estado actual

- macOS Sonoma 14.8.9 (23J631) arrancando por OpenCore 1.0.8, sin pendrive.
- Gráfica AMD RX 580 con **Metal 2** (root patch de OCLP 2.5.1 aplicado).
- Ethernet Gigabit, audio, USB y suspensión de pantalla funcionando.
- Windows y los discos `C:`, `D:`, `E:` y `S:` intactos.
- Diagnóstico completo realizado: **33,8 GB usados de 499,9 GB (6,8 %)**; SMART `Verified` en todos los discos.
- Ajustes aplicados: actualizaciones automáticas OFF y `disksleep 0`.
- Bluetooth D-Link DBT-122: aparcado.

## Fases del montaje

1. **Fase 1 — instalación:** `config.plist` con `-amd_no_dgpu_accel`, `amfi=0x80` y arranque verboso. Permite instalar macOS y ejecutar el root patch de OCLP sin que la GPU interfiera.
2. **Fase 2 — aceleración:** `config.plist` con AMFI activo y AMFIPass (`-amfipassbeta`), sin `-amd_no_dgpu_accel`. Es la configuración de uso diario.
3. **EFI interna:** la carpeta `EFI` del pendrive se copia a la partición EFI del disco de macOS para arrancar sin pendrive.

Los detalles técnicos de cada fase están en [`02-EFI-OPENCORE.md`](02-EFI-OPENCORE.md) y el proceso paso a paso en [`01-INSTALACION.md`](01-INSTALACION.md).

## Qué queda pendiente (todo opcional)

- **SSD SATA 2,5"**: sustituir el HDD por un SSD. Es la mejora de rendimiento más notable. No comprado ni iniciado.
- **Bluetooth**: usar un adaptador USB moderno y compatible (CSR 4.0 / Broadcom BCM20702) en lugar del D-Link DBT-122.
- **Espacio**: borrar `sleepimage` (8 GB) es posible pero no urgente; los KDKs (2,5 GB) conviene dejarlos.
- **Spotlight en el pendrive**: `sudo mdutil -i off /Volumes/OCSONOMA` (opcional).
- **Safari**: hay actualizaciones pendientes (18.6 y 26.6.1) que se pueden evaluar sin prisa.

## Advertencias permanentes

- **No instalar macOS Tahoe 26.7.1** ni ninguna actualización mayor sin comprobar antes la compatibilidad con OCLP.
- **No pulsar "Build and Install OpenCore"** dentro de OCLP.
- **No activar FileVault** (el root patch y el arranque se complican).
- **No borrar** los snapshots de sistema APFS.
- **Mantener una copia del EFI** (pendrive + copia en la nube o en otro disco).

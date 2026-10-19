# 03 — OCLP y aceleración Metal

## Qué es OCLP y por qué se usa aquí

**OpenCore Legacy Patcher (OCLP)** permite ejecutar versiones modernas de macOS en hardware que Apple ya no soporta. En este equipo hace dos cosas fundamentales:

1. **Arranque en un CPU sin AVX2** (Ivy Bridge), apoyándose en `CryptexFixup`.
2. **Root patch de gráficos** para que la **Radeon RX 580** funcione con aceleración **Metal 2** en Sonoma.

La versión usada es **OCLP 2.5.1**.

> OCLP tiene dos funciones bien distintas: **crear/actualizar el EFI de OpenCore** (la opción "Build and Install OpenCore", que aquí **no** se usa) y **aplicar parches al sistema** ("Post-Install Root Patch", que es la que sí se usa).

## La diferencia entre Fase 1 y Fase 2

| | Fase 1 | Fase 2 |
|---|---|---|
| Objetivo | Instalar macOS y aplicar el root patch | Uso diario con aceleración |
| AMFI | Desactivado (`amfi=0x80`) | Activo (AMFIPass + `-amfipassbeta`) |
| GPU | Sin aceleración (`-amd_no_dgpu_accel`) | Aceleración completa |
| Arranque | Verboso (`-v keepsyms=1 debug=0x100`) | Normal |
| Config | `config-fase1-instalacion.plist` | `config-fase2-aceleracion.plist` |

Se instala en Fase 1, se aplica el root patch y después se cambia a Fase 2 con [`../scripts/macos/CAMBIAR-A-FASE2.command`](../scripts/macos/CAMBIAR-A-FASE2.command).

## Root patch: cómo se aplicó

1. macOS Sonoma 14.8.9 ya instalado y arrancando (en Fase 1).
2. **OpenCore-Patcher** abierto desde el pendrive o desde Aplicaciones.
3. Pulsar **Post-Install Root Patch** y esperar. El proceso:
   - Comprueba la versión de macOS y los parches disponibles.
   - Instala los **KDK** (Kernel Debug Kits) necesarios o usa `KDKlessWorkaround`.
   - Modifica los componentes gráficos del sistema para restaurar la aceleración AMD.
   - Pide reiniciar.
4. Tras reiniciar, cambiar a Fase 2 y verificar **Metal: Compatible**.

En este equipo el root patch quedó aplicado y la RX 580 aparece con **Metal 2** en el Informe del sistema.

## KDK y KDKlessWorkaround

- OCLP usa los **Kernel Debug Kits** para preparar los parches. En este equipo se descargaron y ocupan unos **2,5 GB** dentro de `/Library`.
- **No los borres**: si algún día hay que volver a parchear, te ahorrarán la descarga.
- El EFI incluye `KDKlessWorkaround.kext`, que permite parchear en versiones recientes de Sonoma cuando el KDK no está disponible o falla.

## AMFIPass y AMFI

- **AMFI** (Apple Mobile File Integrity) es una protección de seguridad de macOS.
- Para instalar y parchear se desactiva temporalmente con `amfi=0x80` (Fase 1).
- En Fase 2 se **vuelve a activar** y se usa **AMFIPass 1.4.1** junto al argumento `-amfipassbeta`, de modo que el sistema mantiene AMFI activo mientras los parches de OCLP siguen funcionando.
- Si la aceleración no funciona con AMFI activo, existe la variante [`config-fase2-amfi-off.plist`](../efi/configs/config-fase2-amfi-off.plist), que añade `amfi=0x80` a Fase 2. Es un plan B, no la configuración recomendada.

## SIP personalizado

El `config.plist` fija `csr-active-config = 03080000` (`0x803`): permite kexts no firmados, kexts no aprobados y acceso sin restricciones al sistema de archivos. Es lo que OCLP necesita para aplicar los parches. **No lo cambies** por el SIP estándar: romperías el root patch y probablemente el arranque gráfico.

## Verificación de la aceleración

En macOS:

```bash
# ¿Aparece la GPU y Metal?
system_profiler SPDisplaysDataType | grep -E "Chipset|VRAM|Metal|Resolution"

# ¿Están cargados los kexts clave?
kmutil showloaded | grep -Ei "lilu|whatevergreen|amfipass|cryptexfixup|voodoohda|rtl8111"

# ¿Qué argumentos de arranque hay?
nvram boot-args

# ¿Estado de SIP?
csrutil status
```

Resultado esperado: `AMD Radeon RX 580`, `Metal: Compatible`, los kexts cargados y `boot-args` de Fase 2.

## Si algo falla

| Problema | Solución |
|---|---|
| No hay aceleración tras el root patch | Probar `config-fase2-amfi-off.plist`; si sigue igual, volver a Fase 1 y repetir el root patch. |
| Pantalla negra al arrancar Fase 2 | Arrancar en Fase 1 y revisar `boot-args`; probar la variante AMFI off. |
| OCLP pide KDK y falla la descarga | Usar `KDKlessWorkaround` (ya incluido) o descargar el KDK manualmente desde Apple Developer. |
| "Root Patch" deshabilitado | Comprobar la versión de macOS y que OCLP 2.5.1 la reconoce; no actualizar macOS. |
| Después de un cambio de GPU | Volver a aplicar el root patch. |

## Advertencias

- **No actualices macOS** (ni siquiera una actualización menor) sin comprobar antes la compatibilidad con tu versión de OCLP. Un cambio de build invalida los parches.
- **No pulses "Build and Install OpenCore"** en OCLP: tu EFI ya funciona; esa opción puede sobrescribirlo.
- **No actives FileVault**: complica el arranque y los parches.
- **No borres** `/Library/Apple/System/Library/Extensions` ni los KDKs.
- **Mantén una copia del EFI** en el pendrive OCSONOMA y en otro soporte.

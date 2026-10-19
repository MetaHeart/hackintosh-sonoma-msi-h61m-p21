# Configuraciones de OpenCore (saneadas)

Esta carpeta contiene los `config.plist` usados en el proyecto, **con los datos personales sustituidos por marcadores**. Sirven como referencia y punto de partida; **no los uses tal cual sin generar tu propio SMBIOS**.

## Marcadores

| Campo | Valor en este repositorio |
|---|---|
| `PlatformInfo > Generic > SystemSerialNumber` | `TU-SERIAL-AQUI` |
| `PlatformInfo > Generic > MLB` | `TU-MLB-AQUI` |
| `PlatformInfo > Generic > SystemUUID` | `00000000-0000-0000-0000-000000000000` |
| `PlatformInfo > Generic > ROM` | `00:00:00:00:00:00` (6 bytes a cero) |

## Qué archivo usar

| Archivo | Fase | Cuándo usarlo |
|---|---|---|
| `config-fase1-instalacion.plist` | Fase 1 | Instalar macOS y ejecutar el root patch de OCLP. |
| `config-fase1-vmm-hv.plist` | Fase 1 | Si el instalador se niega por "modelo no compatible" (añade parches VMM/HV). |
| `config-fase2-aceleracion.plist` | Fase 2 | Uso diario con AMFI activo y AMFIPass. |
| `config-fase2-amfi-off.plist` | Fase 2 | Si la aceleración no funciona con la Fase 2 normal (añade `amfi=0x80`). |
| `config-fase2-antes-bluetooth.plist` | Fase 2 | Variante limpia sin los kexts de Bluetooth (10 kexts). |

## Diferencias principales

| | Fase 1 | Fase 2 |
|---|---|---|
| `boot-args` | `-v keepsyms=1 debug=0x100 agdpmod=vit9696 -wegnoigpu -amfipassbeta ipc_control_port_options=0 amfi=0x80 -amd_no_dgpu_accel` | `agdpmod=vit9696 -wegnoigpu -amfipassbeta ipc_control_port_options=0` |
| AMFI | Desactivado (`amfi=0x80`) | Activo (AMFIPass) |
| GPU | Sin aceleración (`-amd_no_dgpu_accel`) | Aceleración completa |
| Parches extra VMM | No | No (solo en la variante VMM/HV) |
| Kexts | 14 | 14 (10 en la variante sin Bluetooth) |

Todo el detalle está en [`../../docs/02-EFI-OPENCORE.md`](../../docs/02-EFI-OPENCORE.md).

## Cómo generar tu SMBIOS

1. Descarga [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) (funciona en Windows, macOS y Linux).
2. Ejecuta y elige `iMac13,2`.
3. Copia el `Serial`, `MLB` y `SystemUUID` generados.
4. Para `ROM`, usa la MAC de tu interfaz `en0` o déjala a ceros.
5. Edita el `config.plist` con [ProperTree](https://github.com/corpnewt/ProperTree) u [OCAT](https://github.com/ic005k/OCAuxiliaryTools).
6. Guarda y valida con `ocvalidate`.

> Un serial inválido o duplicado puede impedir el arranque o causar problemas de servicios. Genera siempre uno propio.

## Cómo aplicar un config

1. Haz copia de seguridad del `config.plist` actual.
2. Renombra/coloca el archivo elegido como `EFI/OC/config.plist` en el pendrive o en la EFI interna.
3. Reinicia y comprueba.

El script [`../../scripts/macos/CAMBIAR-A-FASE2.command`](../../scripts/macos/CAMBIAR-A-FASE2.command) automatiza el cambio de Fase 1 a Fase 2 en el pendrive.

## Validación

```powershell
# Windows
ocvalidate.exe config-fase2-aceleracion.plist
```

```bash
# macOS
./ocvalidate /Volumes/EFI/EFI/OC/config.plist
```

Con los marcadores, `ocvalidate` dará avisos sobre el SMBIOS; tras poner tus datos reales, no debería haber errores graves.

## Aviso

Los `config.plist` son específicos para **esta combinación de hardware** (MSI H61M-P21 + i7-3770 + RX 580 + Sonoma 14.8.9). En otro equipo pueden necesitar ajustes. No los uses a ciegas.

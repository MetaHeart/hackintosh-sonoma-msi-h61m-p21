# Scripts

Scripts usados para preparar el USB, instalar, diagnosticar, mantener y reparar el sistema. **Léelos antes de ejecutarlos** y ten siempre una copia del EFI.

## macOS (`scripts/macos/`)

| Script | Qué hace | Riesgo |
|---|---|---|
| `DIAGNOSTICO-SONOMA.command` | Recoge el estado del sistema (solo lectura) y guarda el informe en el pendrive `OCSONOMA` como `DIAGNOSTICO-SONOMA-N.txt`. | Ninguno (no modifica nada). |
| `APLICAR-AJUSTES-SONOMA.command` | Desactiva actualizaciones automáticas y `disksleep`; guarda un registro con el antes/después. | Bajo (reversible). |
| `CAMBIAR-A-FASE2.command` | Ejecutado desde la raíz del pendrive: guarda la config actual y copia `config-fase2.plist` a `EFI/OC/config.plist`. | Medio: cambia la configuración de arranque. |
| `VOLVER-A-FASE1.command` | Restaura la config de Fase 1 desde `EXTRAS/config-fase1-backup.plist`. | Medio: cambia la configuración de arranque. |
| `COPIAR-EFI-INTERNO.command` | Monta la partición EFI del disco de macOS y copia la carpeta `EFI` del pendrive. | Medio-alto: escribe en la partición de arranque. |
| `DIAGNOSTICO-BLUETOOTH.command` | Recoge información de Bluetooth y USB (solo lectura). | Ninguno. |

### Cómo ejecutarlos en macOS

1. Conecta el pendrive `OCSONOMA`.
2. Doble clic sobre el `.command`. Si macOS no lo abre: **clic derecho → Abrir → Abrir**.
3. Alternativa por Terminal:

```bash
bash /Volumes/OCSONOMA/NOMBRE-DEL-SCRIPT.command
```

Los scripts que piden contraseña usan `sudo`; al escribirla no se ve nada en pantalla (es normal).

> Al descargarlos desde GitHub, los permisos de ejecución pueden perderse. Si hace falta:
>
> ```bash
> chmod +x NOMBRE.command
> ```

## Windows (`scripts/windows/`)

| Script | Qué hace | Riesgo |
|---|---|---|
| `PREPARAR-USB-SONOMA.cmd` + `preparar_usb_sonoma.py` | Formatea un USB como FAT32 con etiqueta `OCSONOMA` y copia los archivos de trabajo. | **Alto:** formatea un disco. Revisa el disco elegido. |
| `INSTALAR-ARRANQUE-INTERNO.cmd` + `instalar_arranque_interno.ps1` | Copia la carpeta `EFI` del pendrive `OCSONOMA` a la partición EFI (200 MB) del disco interno con macOS. | **Alto:** escribe en la partición de arranque. Requiere administrador. |
| `RESTAURAR-CONFIG-ANTERIOR.cmd` | Ejecutado desde la raíz del pendrive: restaura `EXTRAS/config-fase2-antes-bt.plist` como `EFI/OC/config.plist`. | Medio: para emergencias. |
| `ARREGLAR-RELOJ-DUALBOOT.cmd` | Hace que Windows trate la BIOS como UTC (`RealTimeIsUniversal=1`), desactiva el Inicio rápido y resincroniza la hora. Corrige el desfase horario del doble arranque. | Bajo: cambia dos valores del registro y el servicio de hora. Requiere administrador. |
| `REPARAR-EARTRUMPET.cmd` | Desinstala EarTrumpet y lo reinstala desde Microsoft Store; si falla, usa el origen comunitario de winget (paquete de GitHub, sin licencia de Store). | Bajo: desinstala y reinstala una aplicación del usuario. |
| `REPARAR-VANGUARD.cmd` | Diagnostica los servicios `vgc`/`vgk` y ofrece un menú para reparar, reinstalar (junto con Valorant) o desinstalar Vanguard. | Medio: puede desinstalar Vanguard. Requiere administrador. |

### Notas

- `preparar_usb_sonoma.py`: la variable `SRC` trae una **ruta de ejemplo**; edítala antes de ejecutar. El script tiene un límite de seguridad (no formatea discos de más de 64 GB) y exige permisos de administrador (el `.cmd` los solicita).
- `instalar_arranque_interno.ps1`: busca el disco con partición APFS, comprueba que no sea USB y que la partición EFI tenga un tamaño razonable, y pide confirmación antes de copiar. Aun así, **verifica siempre el disco que se muestra en pantalla**.
- `RESTAURAR-CONFIG-ANTERIOR.cmd` debe ejecutarse **desde la raíz del pendrive** (doble clic desde el propio pendrive, no desde el escritorio).
- `ARREGLAR-RELOJ-DUALBOOT.cmd` no toca macOS ni el EFI: solo configura Windows para que use UTC. Es seguro ejecutarlo más de una vez.
- `REPARAR-EARTRUMPET.cmd` no necesita administrador; si la Store falla, el propio script prueba el origen comunitario de `winget`.
- `REPARAR-VANGUARD.cmd` requiere administrador. Si no tienes Valorant instalado, Vanguard no tiene utilidad: usa la opción de desinstalarlo.

## Generación de configuraciones (`scripts/build/`)

| Script | Qué hace |
|---|---|
| `build_config_sanitized.py` | Ejemplo saneado del script que generó los `config.plist` de las distintas fases. Sirve como documentación del proceso; **no es autónomo**: espera una carpeta `tools/` con OpenCorePkg y los kexts, y rutas que hay que adaptar. Los valores de SMBIOS son marcadores (`TU-SERIAL-AQUI`, etc.). |

## Advertencias generales

- Estos scripts se ofrecen **tal cual**, sin garantía. Un script de formateo o de escritura de EFI mal ejecutado puede borrar datos.
- Antes de ejecutar cualquier script que escriba en discos: **copia de seguridad** y revisa dos veces el disco seleccionado.
- Los scripts de diagnóstico son de solo lectura; úsalos sin miedo para obtener información antes de tocar nada.
- Si algo sale mal, el pendrive `OCSONOMA` y una copia del EFI son tu red de seguridad.

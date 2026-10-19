# 04 — Mantenimiento y ajustes

Rutinas sencillas para que el sistema siga estable sin hacer experimentos innecesarios.

## Rutina mensual (5 minutos)

1. **Espacio libre:** menú Apple → Informe del sistema → Almacenamiento (o `df -h /`). Mantén al menos un **15–20 % libre**; ahora mismo hay mucho margen (466 GB libres).
2. **SMART de los discos:** Utilidad de Discos → seleccionar cada disco → **S.O.S. (First Aid)**. También puedes ver el estado con `diskutil info disk0 | grep -i smart`.
3. **Actualizaciones:** `softwareupdate -l` solo para *ver* qué hay. **No instalar** macOS Tahoe 26.7.1 ni nada que cambie la versión mayor sin consultar. Las actualizaciones automáticas ya están desactivadas.
4. **Copia del EFI:** guarda una copia de la carpeta `EFI` en el pendrive OCSONOMA y en otro sitio (nube o disco externo). Es pequeño (unos pocos MB) y es tu seguro de arranque.
5. **Backup de datos:** copia documentos/fotos importantes a un disco externo o a la nube. No hace falta Time Machine, pero si tienes un disco externo libre puedes configurarlo (no requiere Apple ID).

## Rutina trimestral

- Ejecuta [`../scripts/macos/DIAGNOSTICO-SONOMA.command`](../scripts/macos/DIAGNOSTICO-SONOMA.command) y guarda el informe junto a la copia del EFI.
- Revisa [`05-DIAGNOSTICO-Y-RESULTADOS.md`](05-DIAGNOSTICO-Y-RESULTADOS.md) para comparar valores.
- Comprueba que el pendrive OCSONOMA sigue arrancando (conéctalo y arranca desde él una vez).
- Revisa los KDKs: deben seguir en `/Library/Developer/KDKs` si quieres poder re-parchear.

## Ajustes ya aplicados

Ejecutados con [`../scripts/macos/APLICAR-AJUSTES-SONOMA.command`](../scripts/macos/APLICAR-AJUSTES-SONOMA.command) y verificados:

- **Actualizaciones automáticas: OFF** (dominio de sistema y de usuario).
  - `AutomaticCheckEnabled`, `AutomaticDownload`, `AutomaticallyInstallMacOSUpdates`, `CriticalUpdateInstall`, `ConfigDataInstall` → `0`.
  - `softwareupdate --schedule off`.
- **Suspensión del disco duro: OFF** (`disksleep 0`) para evitar esperas de 5–10 segundos al usar el HDD.
- **Sueño del sistema:** `sleep 10`, `displaysleep 10`, `powernap 0`, `standby 0`, `hibernatemode 0`, `autorestart 0`.

Para revertir las actualizaciones: Ajustes del Sistema → General → Actualización de software → Actualizaciones automáticas.
Para volver a permitir la suspensión del disco: `sudo pmset -a disksleep 10`.

## Cosas que **no** conviene hacer

- **No uses "limpiadores" ni antivirus** tipo CleanMyMac, CCleaner, etc. En un Hackintosh con root patch pueden borrar cosas que el sistema necesita.
- **No "desfragmentes" APFS** ni borres snapshots del sistema: los snapshots son necesarios para arrancar.
- **No borres los KDKs** de OCLP (2,5 GB): se usan para volver a parchear.
- **No actives FileVault** ni bloquees el firmware con contraseña si no es imprescindible.
- **No actualices macOS** sin comprobar antes la compatibilidad de OCLP.
- **No pulses "Build and Install OpenCore"** en OCLP.
- **No edites el EFI interno** "a mano" sin tener el pendrive de rescate a mano.

## Ajustes opcionales (solo si quieres)

### Que Spotlight no indexe el pendrive

Evita que macOS consuma recursos indexando la unidad de rescate:

```bash
sudo mdutil -i off /Volumes/OCSONOMA
```

### Liberar el `sleepimage` (8 GB)

Con `hibernatemode 0` el archivo de hibernación no se usa, pero macOS puede volver a crearlo:

```bash
sudo rm -f /private/var/vm/sleepimage
```

No es urgente: hay 466 GB libres. Si prefieres no tocarlo, no pasa nada.

### Cambiar el comportamiento del sueño

- Si el PC duerme y despierta bien: déjalo como está.
- Si al despertar aparecen pantallas negras o cuelgues: desactiva el sueño:

```bash
# Desactivar la suspensión del sistema (mantener solo apagado de pantalla)
sudo pmset -a sleep 0
```

### Encender solo tras un corte de luz

```bash
sudo pmset -a autorestart 1
```

### Alternar configuraciones de OpenCore

- Pasar a Fase 2: [`../scripts/macos/CAMBIAR-A-FASE2.command`](../scripts/macos/CAMBIAR-A-FASE2.command)
- Volver a Fase 1: [`../scripts/macos/VOLVER-A-FASE1.command`](../scripts/macos/VOLVER-A-FASE1.command)
- Restaurar la configuración anterior desde Windows: [`../scripts/windows/RESTAURAR-CONFIG-ANTERIOR.cmd`](../scripts/windows/RESTAURAR-CONFIG-ANTERIOR.cmd)

## Comandos útiles de consulta

```bash
# Versión de macOS
sw_vers

# Espacio en disco
df -h /

# Energía
pmset -g

# Kexts cargados (oculta los de Apple)
kmutil showloaded | grep -v com.apple

# Argumentos de arranque
nvram boot-args

# Estado de SIP
csrutil status

# Actualizaciones pendientes (solo ver, no instalar)
softwareupdate -l

# Información de discos
diskutil list
diskutil info disk0 | grep -i smart
```

## Si algo va mal: orden de actuación

1. **No entres en pánico:** el sistema suele arrancar desde el pendrive aunque la EFI interna falle.
2. Arranca desde el pendrive OCSONOMA (F11 → entrada UEFI del USB).
3. Si arranca bien, el problema está en la EFI interna: vuelve a copiarla con [`../scripts/macos/COPIAR-EFI-INTERNO.command`](../scripts/macos/COPIAR-EFI-INTERNO.command).
4. Si macOS no arranca bien desde el pendrive, arranca en **modo seguro** (mantén `Shift` en el menú de OpenCore o usa `-x` como boot-arg).
5. Si el problema empezó tras un cambio, restaura la configuración anterior con `VOLVER-A-FASE1.command` o `RESTAURAR-CONFIG-ANTERIOR.cmd`.
6. Consulta [`08-SOLUCION-DE-PROBLEMAS.md`](08-SOLUCION-DE-PROBLEMAS.md).

> Nunca borres particiones ni "reinstales" sin tener el pendrive de rescate y una copia del EFI a mano.

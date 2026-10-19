# 05 — Diagnóstico y resultados

## Scripts de diagnóstico

### `DIAGNOSTICO-SONOMA.command`

Ubicación: [`../scripts/macos/DIAGNOSTICO-SONOMA.command`](../scripts/macos/DIAGNOSTICO-SONOMA.command)

Es **de solo lectura**: no cambia nada del sistema. Recoge:

- Espacio en disco y desglose de volúmenes APFS.
- Hardware: CPU, RAM, GPU, pantalla, discos, Ethernet, USB, audio.
- Estado de las actualizaciones.
- Configuración de energía (`pmset`).
- Arranque (OpenCore, SIP, `boot-args`).
- Kexts cargados y errores relevantes del registro.

**Cómo usarlo:**

1. Conecta el pendrive `OCSONOMA`.
2. En macOS, doble clic en el archivo (si macOS no lo abre: clic derecho → Abrir → Abrir).
3. Espera 2–5 minutos (el HDD es lento). Se pedirá la contraseña de administrador.
4. El informe se guarda en el pendrive como `DIAGNOSTICO-SONOMA-1.txt`, `-2.txt`, etc.
5. Reinicia en Windows y revisa el archivo desde ahí.

### `APLICAR-AJUSTES-SONOMA.command`

Ubicación: [`../scripts/macos/APLICAR-AJUSTES-SONOMA.command`](../scripts/macos/APLICAR-AJUSTES-SONOMA.command)

Aplica **solo dos** ajustes seguros:

1. Desactiva las actualizaciones automáticas (sistema y usuario).
2. Desactiva la suspensión del disco duro (`disksleep 0`).

No toca EFI, OpenCore, OCLP, FileVault ni discos. Genera un registro `AJUSTES-SONOMA-FECHA.txt` en el pendrive con el *antes* y el *después*.

## Resultados reales del equipo

Datos extraídos del informe más reciente (`DIAGNOSTICO-SONOMA-2.txt`). La versión saneada está en [`ejemplos/RESULTADO-DIAGNOSTICO-SANITIZADO.txt`](ejemplos/RESULTADO-DIAGNOSTICO-SANITIZADO.txt) y el registro de ajustes en [`ejemplos/AJUSTES-SONOMA-EJEMPLO.txt`](ejemplos/AJUSTES-SONOMA-EJEMPLO.txt).

### Espacio en disco

| Concepto | Valor |
|---|---|
| Disco de macOS | `ST500LT012-1DG142` |
| Capacidad total | 499,9 GB (465,6 GiB) |
| Contenedor APFS | 499,9 GB |
| **Usado por macOS** | **33,8 GB (6,8 %)** |
| **Libre** | **466,1 GB (93,2 %)** |

Desglose por volumen APFS:

| Volumen | Tamaño |
|---|---|
| System | 12,0 GB |
| Data | 15,0 GB |
| Preboot | 5,4 GB |
| Recovery | 1,2 GB |
| VM | 1,1 MB |
| **Total** | **33,8 GB** |

Dentro del volumen **Data** (lo que más ocupa):

| Carpeta | Tamaño | Notas |
|---|---|---|
| `private` | 8,8 GB | Casi todo `sleepimage` (8,0 GB). |
| `Library` | 4,0 GB | KDKs 2,5 GB; Dortania 0,8 GB; Updates 0,4 GB; Caches 0,2 GB. |
| `System` | 0,8 GB | |
| `Users` | 0,3 GB | Desktop, Documents, Downloads y Movies vacíos; Pictures 3,6 MB. |
| `Previous Content` | 0,3 GB | |
| `Spotlight` | 15 MB | |

**Conclusión:** la instalación está muy limpia. No hace falta borrar nada para ganar espacio; sobran 466 GB.

### Estado del sistema

| Comprobación | Resultado |
|---|---|
| macOS | 14.8.9 (23J631), Darwin 23.6.0, SMBIOS `iMac13,2` |
| RAM | 16 GB, swap usado: 0 MB, sin presión de memoria |
| GPU | AMD Radeon RX 580, 8 GB VRAM, **Metal 2**, 1360 × 768 a 60 Hz |
| Ethernet | Realtek RTL8111 a **1 Gb/s** |
| Audio | VoodooHDA: salida, micrófono y SPDIF funcionando |
| SMART | `Verified` en todos los discos |
| FileVault | Desactivado |
| SIP | Personalizado por OCLP (`csr-active-config=03080000`) |
| `boot-args` | Fase 2 (correctos) |
| Kexts | Lilu 1.7.2, WhateverGreen 1.7.1, RestrictEvents 1.1.6, CryptexFixup 1.0.5, AMFIPass 1.4.1, VirtualSMC 1.3.8, VoodooHDA 3.7.0, RealtekRTL8111 3.0.4 |
| OCLP | 2.5.1, root patch aplicado |
| Bluetooth | D-Link DBT-122 detectado en USB, pero no funcional |
| Errores benignos | `IOTimeSyncFamily` y `AppleIPAppender` no cargan; no afectan |

### Actualizaciones

- Actualizaciones automáticas: **desactivadas** (sistema y usuario). Verificado en el registro.
- Actualizaciones pendientes que macOS ve:
  - **Safari 26.6.1** (opcional).
  - **Safari 18.6** (opcional).
  - **macOS Tahoe 26.7.1** → **NO INSTALAR**. No es compatible con Ivy Bridge/OCLP.
- Regla: **no instalar actualizaciones de macOS sin consultar**.

### Energía

Configuración actual (`pmset -g`):

| Ajuste | Valor |
|---|---|
| `disksleep` | **0** (disco siempre activo) |
| `sleep` | 10 min |
| `displaysleep` | 10 min |
| `powernap` | 0 |
| `standby` | 0 |
| `hibernatemode` | 0 |
| `autorestart` | 0 |

Si el PC duerme y despierta bien, se puede dejar así. Si aparecen fallos al despertar, desactiva el sueño con `sudo pmset -a sleep 0`.

### Snapshots y Time Machine

- Time Machine: sin destinos configurados.
- No hay snapshots locales de Time Machine.
- Hay **2 snapshots de sistema APFS** (`com.apple.os.update-...` y `com.apple.bless...`) necesarios para arrancar. **No borrar.**

## Recomendaciones derivadas del diagnóstico

1. No hay ninguna acción urgente: el sistema está sano.
2. Mantener las actualizaciones automáticas en OFF.
3. No instalar macOS Tahoe 26.7.1.
4. No pulsar "Build and Install OpenCore" en OCLP.
5. No activar FileVault ni instalar limpiadores/antivirus.
6. Mantener al menos un 15–20 % de disco libre (ahora sobra mucho).
7. Dejar los KDKs de OCLP (2,5 GB) por si hay que re-parchear.
8. Opcional: desactivar Spotlight en el pendrive OCSONOMA.
9. Opcional: liberar el `sleepimage` de 8 GB (no es necesario).
10. Backups: guardar el pendrive OCSONOMA, una copia del EFI y los archivos importantes en otro disco o en la nube.
11. La mejora real de rendimiento sigue siendo un **SSD SATA 2,5"** para sustituir el HDD. No es urgente.
12. El Bluetooth sigue aplazado; si se retoma, usar un adaptador moderno y compatible.

## Cómo interpretar un informe nuevo

- Compara el **espacio usado** con el de este informe: si crece mucho sin motivo, busca archivos grandes en `~/Downloads`, `~/Movies`, caches, etc.
- Revisa que los **kexts** sigan cargados y que `boot-args` siga siendo el de Fase 2.
- Si aparecen errores nuevos de disco (`I/O error`), haz copia de seguridad y revisa el disco.
- Los errores de `IOTimeSyncFamily` y `AppleIPAppender` son benignos y aparecen también en sistemas reales.

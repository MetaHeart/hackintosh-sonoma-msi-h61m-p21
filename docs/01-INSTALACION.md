# 01 — Guía de instalación paso a paso

> Esta es una versión resumida y ordenada del proceso. La guía original completa, con los textos exactos que se usaron, está en [`originales/GUIA-INSTALACION-SONOMA.txt`](originales/GUIA-INSTALACION-SONOMA.txt). Las rutas y scripts mencionados están en [`../scripts/`](../scripts/).

## Antes de empezar

**Hardware necesario**

- PC objetivo (en este caso: i7-3770 + MSI H61M-P21 + RX 580 + 16 GB RAM + disco de 500 GB).
- Un **pendrive de 8 GB o más** (se formatea completo; se pierde su contenido).
- Un **PC con Windows** para preparar el pendrive (o acceso a uno).
- Conexión a Internet (para descargar OpenCore, kexts y la imagen de recuperación de macOS).
- Un teclado y un ratón USB.

**Avisos importantes**

- Haz copia de seguridad de todo lo que haya en el pendrive.
- **No** modifiques las particiones EFI de Windows: este montaje añade su propia EFI en el disco de macOS.
- Ten a mano la guía original y este repositorio.

## Paso 1 — Preparar el pendrive desde Windows

Contenido que debe quedar en la raíz del pendrive (etiqueta `OCSONOMA`, FAT32):

```text
OCSONOMA\
├── EFI\                     # OpenCore con la configuración de Fase 1
├── com.apple.recovery.boot\ # Imagen de recuperación de macOS Sonoma
├── config-fase2.plist       # Configuración de Fase 2 (sin usar todavía)
├── EXTRAS\                  # Variantes de config y materiales auxiliares
└── *.command / *.txt        # Scripts y guías
```

En este repositorio tienes:

- [`../scripts/windows/PREPARAR-USB-SONOMA.cmd`](../scripts/windows/PREPARAR-USB-SONOMA.cmd) y [`../scripts/windows/preparar_usb_sonoma.py`](../scripts/windows/preparar_usb_sonoma.py): formatean el USB como FAT32 con la etiqueta `OCSONOMA` y copian los archivos. **Revisa y edita la ruta `SRC` dentro del `.py`** antes de ejecutarlo.
- Los `config.plist` saneados en [`../efi/configs/`](../efi/configs/). Recuerda: hay que generar el SMBIOS propio antes de usar cualquiera de ellos.
- La imagen de recuperación se obtiene con la utilidad oficial `macrecovery` (incluida en OpenCorePkg) o con OCLP; consulta [`09-REFERENCIAS.md`](09-REFERENCIAS.md).

## Paso 2 — Configurar la BIOS

Entra en la BIOS (tecla `Supr`/`Del` al encender) y revisa:

- **Modo de arranque:** UEFI (no Legacy/CSM).
- **SATA:** modo **AHCI**.
- **XHCI Hand-off / USB:** habilitado si existe la opción.
- **Arranque rápido (Fast Boot):** desactivado.
- **Orden de arranque:** el pendrive USB como primera opción (o usa la tecla `F11` para el menú de arranque).
- **Secure Boot:** desactivado (o no disponible, como en esta placa).
- **Gráficos integrados:** si la placa lo permite, deja la GPU dedicada como principal.

> En la MSI H61M-P21 puede que algunas opciones no existan. Con AHCI + UEFI suele ser suficiente.

## Paso 3 — Fase 1: instalar macOS

1. Conecta el pendrive `OCSONOMA` y arranca desde él (`F11` → entrada UEFI del pendrive).
2. Aparecerá el menú de OpenCore. Elige la entrada de **macOS Base System** o el instalador de Sonoma.
3. En Utilidades de macOS, abre **Utilidad de Discos**:
   - Selecciona el disco interno de 500 GB (`ST500LT012`).
   - Bórralo con formato **APFS** y esquema **GUID**.
4. Cierra Utilidad de Discos e instala macOS Sonoma en el disco recién borrado.
5. El equipo se reiniciará varias veces. **Mantén el pendrive conectado** y elige siempre la entrada correcta en OpenCore (instalador o disco interno, según corresponda).
6. Termina la configuración inicial:
   - **No** inicies sesión con Apple ID si no lo necesitas.
   - Crea el usuario local.
   - Puedes omitir Siri, análisis, etc.

La configuración de Fase 1 desactiva temporalmente la aceleración AMD (`-amd_no_dgpu_accel`) y AMFI (`amfi=0x80`), lo que permite instalar y parchear sin conflictos.

## Paso 4 — Root patch de OCLP (sigue en Fase 1)

Con macOS ya instalado y arrancando desde el disco interno (todavía con el pendrive puesto):

1. Copia/abre **OpenCore-Patcher** (OCLP 2.5.1) desde el pendrive o desde su ubicación.
2. Pulsa **Post-Install Root Patch** (root patch). **No** pulses "Build and Install OpenCore".
3. Espera a que termine (puede tardar bastante en un HDD). Si pide reiniciar, reinicia.
4. El root patch instala los componentes que permiten la aceleración Metal de la RX 580 en Sonoma sobre hardware no soportado. Requiere KDK (o el `KDKlessWorkaround` que ya está incluido en el EFI); el proceso concreto está en [`03-OCLP-Y-ACELERACION.md`](03-OCLP-Y-ACELERACION.md).

## Paso 5 — Fase 2: activar la aceleración

1. Asegúrate de que el pendrive está conectado y que estás en macOS.
2. Ejecuta [`../scripts/macos/CAMBIAR-A-FASE2.command`](../scripts/macos/CAMBIAR-A-FASE2.command) (doble clic). El script:
   - Guarda la configuración de Fase 1 en `EXTRAS/config-fase1-backup.plist`.
   - Copia `config-fase2.plist` a `EFI/OC/config.plist` del pendrive.
3. Reinicia y arranca de nuevo desde el pendrive.
4. Comprueba la aceleración:
   - Menú Apple → **Informe del sistema** → **Gráficos/Pantallas**: debe aparecer la **Radeon RX 580** y **Metal: Compatible**.
   - La interfaz debe ir fluida (transparencias del Dock, vídeos sin tirones).

Si algo falla, puedes volver a Fase 1 con [`../scripts/macos/VOLVER-A-FASE1.command`](../scripts/macos/VOLVER-A-FASE1.command) o probar la variante AMFI off (ver [`03-OCLP-Y-ACELERACION.md`](03-OCLP-Y-ACELERACION.md)).

## Paso 6 — Copiar el EFI al disco interno (arrancar sin pendrive)

1. En macOS, con el pendrive conectado, ejecuta [`../scripts/macos/COPIAR-EFI-INTERNO.command`](../scripts/macos/COPIAR-EFI-INTERNO.command).
2. El script monta la partición EFI del disco de macOS y copia la carpeta `EFI` del pendrive.
3. Reinicia con el pendrive puesto:
   - Pulsa `F11` y elige la entrada UEFI del **disco interno** (`ST500LT012`).
   - Debe aparecer el menú de OpenCore y arrancar macOS.
4. Si funciona, entra en la BIOS y pon esa entrada como **primera opción de arranque**.
5. Guarda el pendrive `OCSONOMA` en un lugar seguro: es tu sistema de rescate.

## Paso 7 — Ajustes posteriores

- Ejecuta [`../scripts/macos/APLICAR-AJUSTES-SONOMA.command`](../scripts/macos/APLICAR-AJUSTES-SONOMA.command) para desactivar actualizaciones automáticas y `disksleep`.
- Ejecuta [`../scripts/macos/DIAGNOSTICO-SONOMA.command`](../scripts/macos/DIAGNOSTICO-SONOMA.command) para generar un informe del estado y guárdalo junto al EFI.
- Revisa [`04-MANTENIMIENTO.md`](04-MANTENIMIENTO.md) y [`06-RENDIMIENTO-Y-ACTUALIZACIONES.md`](06-RENDIMIENTO-Y-ACTUALIZACIONES.md).

## Problemas durante la instalación

| Síntoma | Qué probar |
|---|---|
| El instalador dice que el modelo no es compatible | Usar la variante VMM/HV (`config-fase1-vmm-hv.plist`), que añade los parches `kern.hv_vmm_present` y `Reroute HW_BID`. |
| Pantalla negra o sin señal tras el root patch | Arrancar con el pendrive en Fase 1, o probar `config-fase2-amfi-off.plist`. |
| No aparece la entrada de arranque del disco interno | Revisar que la EFI se copió a la partición EFI correcta y que la BIOS está en UEFI. |
| El audio no suena | Comprobar que VoodooHDA está cargado y elegir la salida correcta en Ajustes de Sonido. |
| Sin Ethernet | Comprobar el kext RealtekRTL8111 y el cable; revisar `en0` en Informe del sistema. |

Más casos en [`08-SOLUCION-DE-PROBLEMAS.md`](08-SOLUCION-DE-PROBLEMAS.md).

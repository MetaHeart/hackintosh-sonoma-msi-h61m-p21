# 08 — Solución de problemas

> **Antes de tocar nada:** arranca desde el pendrive OCSONOMA. Si el sistema arranca desde el pendrive pero no desde el disco interno, el problema está en la EFI interna y se soluciona volviendo a copiarla ([`../scripts/macos/COPIAR-EFI-INTERNO.command`](../scripts/macos/COPIAR-EFI-INTERNO.command)). Ten siempre una copia del EFI.

## Arranque / OpenCore

| Síntoma | Causa probable | Solución |
|---|---|---|
| No aparece el menú de OpenCore | BIOS en Legacy/CSM, pendrive no UEFI, arranque rápido activo | BIOS → UEFI, desactivar Fast Boot, arrancar con `F11` y elegir la entrada UEFI. |
| El menú aparece pero no hay entrada de macOS | EFI sin los parches correctos o disco APFS no detectado | Usar el pendrive en Fase 2; comprobar `HfsPlus.efi` y que el disco está en APFS. |
| Se queda en el logo de Apple | Kexts o `boot-args` incorrectos | Arrancar con `-v` para ver dónde se detiene; probar Fase 1. |
| Señal de prohibido (círculo tachado) | Modelo no soportado / SMBIOS | Usar la variante VMM/HV en Fase 1; comprobar parches `Skip Board ID check`. |
| Reinicio en bucle | Kext incompatible o parche mal aplicado | Modo seguro (`-x`), revisar kexts recién añadidos, restaurar config anterior. |
| "OCB: StartImage failed" | EFI corrupta o driver mal | Restaurar la carpeta `EFI` completa desde la copia. |
| Pantalla de prohibido tras actualizar | Root patch perdido | Arrancar en Fase 1 y volver a aplicar el root patch de OCLP. |

## Instalación

| Síntoma | Causa probable | Solución |
|---|---|---|
| "Este modelo no es compatible" | SMBIOS no aceptado por el instalador | Usar `config-fase1-vmm-hv.plist`, que añade los parches `kern.hv_vmm_present` y `Reroute HW_BID`. |
| La instalación no termina o se queda parada | USB lento, HDD lento, poca paciencia | Esperar; usar USB 2.0 estable; revisar `-v` por si hay un error real. |
| No aparece el disco interno en Utilidad de Discos | SATA en RAID/IDE o disco con formato raro | BIOS → SATA **AHCI**; formatear APFS + GUID. |

## Gráficos

| Síntoma | Causa probable | Solución |
|---|---|---|
| Sin aceleración (Dock lento, vídeo a tirones) | Root patch no aplicado o Fase 1 activa | Volver a Fase 1, aplicar root patch, pasar a Fase 2. |
| Pantalla negra al arrancar Fase 2 | AMFI/GPU patch | Probar `config-fase2-amfi-off.plist`; revisar `agdpmod=vit9696` y `-wegnoigpu`. |
| Resolución incorrecta | EDID del TV/monitor | Ajustes → Pantallas; probar otro cable/puerto HDMI. |
| Parpadeos o artefactos | Cable/adaptador o GPU | Probar otro cable; vigilar temperaturas; comprobar que la RX 580 está bien alimentada. |

## Audio

| Síntoma | Causa probable | Solución |
|---|---|---|
| No hay sonido | Salida equivocada o VoodooHDA no cargado | Ajustes → Sonido → elegir salida; comprobar `kmutil showloaded | grep -i voodoo`. |
| Micrófono no funciona | Entrada no seleccionada | Ajustes → Sonido → Entrada. |
| Sonido con ruido | Ajuste de VoodooHDA | Probar a bajar la ganancia o usar SPDIF. |

## Ethernet

| Síntoma | Causa probable | Solución |
|---|---|---|
| "Ethernet desconectado" | Cable/switch o kext no cargado | Probar otro cable/puerto; comprobar `RealtekRTL8111`. |
| Velocidad baja | Negociación a 100 Mb/s | Cambiar cable/switch; comprobar en Informe del sistema → Ethernet. |
| Sin IP | DHCP o configuración manual | Ajustes → Red → Ethernet → Usar DHCP. |

## USB

| Síntoma | Causa probable | Solución |
|---|---|---|
| Un dispositivo USB no funciona | Mapa USB/SSDT | Comprobar `SSDT-EC-USBX.aml`; probar otro puerto. |
| El teclado/ratón falla en el menú de OpenCore | USB legacy | Activar USB legacy en BIOS o usar puertos USB 2.0. |
| El pendrive no monta | Formato | Usar FAT32 para el pendrive; APFS/HFS+ se ven en macOS. |

## Sueño y energía

| Síntoma | Causa probable | Solución |
|---|---|---|
| No despierta bien | Suspensión agresiva | `sudo pmset -a sleep 0` (mantener solo apagado de pantalla). |
| El sistema se congela al despertar | GPU/USB | Revisar registros; probar a desactivar `powernap`; mantener `hibernatemode 0`. |
| El HDD hace clics y esperas | `disksleep` | Ya está en `0`; si no, `sudo pmset -a disksleep 0`. |
| Se reinicia solo tras corte de luz | `autorestart 0` | `sudo pmset -a autorestart 1` si se desea. |

## OCLP y root patch

| Síntoma | Causa probable | Solución |
|---|---|---|
| "Post Install Root Patch" deshabilitado | Versión de macOS no soportada o ya parcheado | Comprobar versión; no actualizar macOS. |
| Error al descargar KDK | Red o Apple Developer | Reintentar; usar `KDKlessWorkaround`; descargar el KDK manualmente. |
| Tras un update se pierde la aceleración | OCLP necesita re-parchear | Aplicar root patch otra vez y reiniciar. |
| OCLP ofrece "actualizar OpenCore" | Función para Macs reales | **No aceptar**; puede reemplazar el EFI y dejar el sistema sin arrancar. |
| El sistema no arranca tras parchear | Parche incompatible | Arrancar desde el pendrive; volver a Fase 1; revertir root patch desde OCLP si es posible. |

## Actualizaciones

| Síntoma | Causa probable | Solución |
|---|---|---|
| Aparece macOS Tahoe 26.7.1 | La app de actualizaciones lo ofrece | **Ignorar**; no instalar. |
| Aparecen Safari 18.6 / 26.6.1 | Actualizaciones normales | Opcional; no afectan al arranque. |
| Aparece un Security Response Update | RSR | **No instalar** en pre-Haswell; fallará. |
| Se descargó algo sin querer | Actualizaciones automáticas | Comprobar que están OFF; borrar el instalador descargado desde Ajustes si aparece. |

## Windows y arranque dual

| Síntoma | Causa probable | Solución |
|---|---|---|
| Windows no arranca | Orden de arranque cambiado | `F11` → elegir Windows Boot Manager; ajustar orden en BIOS. |
| No quiero tocar la EFI de Windows | — | Este montaje usa la EFI del disco de macOS; no toques la de Windows. |
| Windows pide reparación | Cambio de orden o disco | Arranca Windows desde su propia entrada UEFI; no reinstales nada sin backup. |
| La hora cambia al pasar de macOS a Windows | macOS y Windows interpretan la hora de la BIOS de forma distinta | Ejecuta [`ARREGLAR-RELOJ-DUALBOOT.cmd`](../scripts/windows/ARREGLAR-RELOJ-DUALBOOT.cmd) como administrador y reinicia. |
| EarTrumpet da error de licencia CLiP o `0xc0ea000a` | Licencia de Microsoft Store invalidada | Reinstálalo desde el origen comunitario de winget; ver [EarTrumpet](#eartrumpet-error-de-licencia-clip). |
| El icono de Riot Vanguard está gris | El servicio `vgc` no arranca (error "Función incorrecta") | Repara o reinstala Vanguard; ver [Riot Vanguard](#riot-vanguard-icono-gris-o-servicio-vgc-detenido). |

### Hora desajustada al alternar macOS y Windows

**Síntoma:** al arrancar Windows después de usar macOS, la hora aparece desplazada (la diferencia de tu zona horaria: por ejemplo, 5 horas en Colombia) y se corrige sola al rato o al sincronizar.

**Causa:** macOS guarda el reloj de la BIOS/CMOS en **UTC**. Windows, por defecto, lo interpreta como **hora local**. Cada sistema escribe y lee la hora con un criterio distinto, así que al cambiar de sistema el reloj "baila".

**Solución (solo Windows):**

1. Ejecuta [`scripts/windows/ARREGLAR-RELOJ-DUALBOOT.cmd`](../scripts/windows/ARREGLAR-RELOJ-DUALBOOT.cmd) como administrador (doble clic; el script pide UAC).
2. Reinicia Windows.

El script:

- Crea `RealTimeIsUniversal = 1` (DWORD) en `HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation`, para que Windows también trate la BIOS como UTC.
- Desactiva el **Inicio rápido** (`HiberbootEnabled = 0`), recomendado en doble arranque.
- Pone el servicio `w32time` en automático y resincroniza la hora.

**Comprobación manual:**

```cmd
reg query "HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal
tzutil /g
w32tm /resync
```

**macOS no necesita ningún cambio:** siempre usa UTC. Si la hora sigue bailando unos minutos, comprueba que la zona horaria es la correcta y vuelve a ejecutar el script. Este arreglo es exclusivo de Windows y no toca OpenCore, el EFI ni macOS.

## Problemas secundarios de Windows

Estos fallos no afectan al arranque ni a macOS: son aplicaciones de Windows que pueden quedar en mal estado después de alternar sistemas, cambiar la hora o actualizarse. Se resuelven sin reinstalar Windows.

### EarTrumpet: error de licencia CLiP

**Síntoma:** EarTrumpet no arranca y muestra:

> "El id. de dispositivo de la licencia CLiP no coincide con el id. de dispositivo de la licencia de dispositivo enlazado."

Al intentar reinstalarlo desde la Store, winget puede fallar con `0xc0ea000a`.

**Causa:** la licencia de Microsoft Store está ligada al dispositivo y a la cuenta. Un desajuste de hora, un cambio de estado de la Store o una reinstalación pueden invalidarla. `ClipSVC` (Client License Service) es el servicio que gestiona esas licencias; no hace falta desactivarlo ni "repararlo" a mano.

**Solución recomendada — instalar sin pasar por la Store:**

```cmd
winget install --id File-New-Project.EarTrumpet --source winget --accept-package-agreements --accept-source-agreements
```

El origen `winget` descarga el paquete desde las *releases* de GitHub y lo instala como aplicación MSIX local: **no usa licencia de Store**, así que el error CLiP no puede aparecer. Para actualizarlo después:

```cmd
winget upgrade --id File-New-Project.EarTrumpet
```

**Alternativa con Microsoft Store:**

1. Comprueba que la hora y la zona horaria son correctas.
2. Ejecuta `WSReset.exe` (Win+R) y reinicia Windows.
3. Abre Microsoft Store, inicia sesión y ve a **Biblioteca → Obtener actualizaciones**.
4. Instala o actualiza EarTrumpet desde su página.
5. Si sigue fallando, ejecuta como administrador `DISM /Online /Cleanup-Image /RestoreHealth` y `sfc /scannow`, reinicia y reintenta.

También puedes usar [`scripts/windows/REPARAR-EARTRUMPET.cmd`](../scripts/windows/REPARAR-EARTRUMPET.cmd), que desinstala la versión actual e intenta primero la Store y luego el origen `winget`.

> La versión instalada por `winget` no se actualiza automáticamente desde la Store; usa el comando `winget upgrade` de arriba.

### Riot Vanguard: icono gris o servicio `vgc` detenido

**Síntoma:** el icono de Vanguard en la bandeja del sistema está gris y `sc query vgc` muestra el servicio detenido, aunque esté configurado en Automático.

**Causa:** el servicio `vgc` no arranca. En el registro de eventos de Windows suele aparecer el evento **7023**: "El servicio vgc se cerró con el siguiente error: Función incorrecta" (error 1). Normalmente indica una instalación corrupta o un driver `vgk` que no se carga.

**Comprobación:**

```cmd
sc query vgc
sc query vgk
```

Y, en PowerShell:

```powershell
Get-WinEvent -LogName System -MaxEvents 500 |
  Where-Object { $_.Message -match 'vgc|vgk' } |
  Select-Object -First 5 TimeCreated, Id, Message
```

**Solución:**

1. **Intentar repararlo** (como administrador):

   ```cmd
   sc config vgc start= auto
   net start vgc
   ```

   Si arranca, el icono debería volver a rojo.

2. **Si falla con "Función incorrecta"**, la instalación está dañada. Desinstala Vanguard con `C:\Program Files\Riot Vanguard\uninstall.exe`, reinicia Windows y abre **Riot Client → Valorant → Instalar**. Vanguard se instalará de nuevo junto con el juego; reinicia cuando lo pida.

3. **Si no juegas a Valorant**, desinstala Vanguard: es el único juego de Riot que lo usa (League of Legends y TFT no lo necesitan). Sin Valorant, el icono gris no aporta nada.

También puedes usar [`scripts/windows/REPARAR-VANGUARD.cmd`](../scripts/windows/REPARAR-VANGUARD.cmd), que muestra el estado de los servicios y ofrece un menú para reparar, reinstalar o desinstalar.

> **Nota:** Vanguard se instala junto con Valorant; no hay un instalador independiente. Si no tienes Valorant instalado, la forma limpia de dejar de ver el icono gris es desinstalarlo.

## Disco y espacio

| Síntoma | Causa probable | Solución |
|---|---|---|
| Poco espacio | Caches, descargas, `sleepimage` | Revisar `df -h /`; borrar `sleepimage` si quieres (opcional); no borrar snapshots. |
| Disco lento | HDD de 5400 RPM | Es normal; un SSD es la solución. |
| SMART no verificado | Disco degradado | Copia de seguridad inmediata y planifica sustitución. |
| Errores de E/S en el registro | Cable/ disco | Revisar cables SATA; hacer backup. |

## Recuperación de emergencia

1. **Arranca desde el pendrive OCSONOMA** (`F11` → entrada UEFI del USB).
2. Si el problema es de configuración, restaura la anterior:
   - Desde macOS: `VOLVER-A-FASE1.command`.
   - Desde Windows: `RESTAURAR-CONFIG-ANTERIOR.cmd` (ejecutándolo desde la raíz del pendrive).
3. Si el problema es la EFI interna, vuelve a copiarla con `COPIAR-EFI-INTERNO.command`.
4. Si el sistema no arranca ni desde el pendrive, prueba:
   - `-v` para ver el error.
   - `-x` (modo seguro).
   - La variante `config-fase1-vmm-hv.plist`.
   - Otra entrada del menú de OpenCore.
5. Como último recurso, reinstala macOS en un volumen nuevo (no borres el anterior hasta tener copia de tus datos).

> **Nunca** ejecutes comandos destructivos (`diskutil eraseDisk`, `rm -rf` sobre rutas del sistema, etc.) sin una copia de seguridad y sin entender exactamente qué hacen.

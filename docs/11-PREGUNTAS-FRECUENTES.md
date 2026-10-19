# 11 — Preguntas frecuentes (FAQ)

Respuestas rápidas a las dudas más habituales sobre este montaje. Para más detalle, sigue los enlaces de cada respuesta.

## General

### ¿Es legal instalar macOS en este PC?

Instalar macOS en hardware que no es de Apple puede infringir el contrato de licencia de Apple. Este repositorio es **documentación educativa**: no distribuye software de Apple ni binarios de terceros, y cada usuario es responsable de cómo use la información. No es asesoramiento legal.

### ¿Por qué macOS Sonoma y no Sequoia o Tahoe?

Porque **Sonoma 14.8.9 funciona de forma estable** en este hardware con OCLP 2.5.1. La migración a Sequoia se canceló para no romper un sistema que ya funcionaba, y **macOS Tahoe no es compatible** con Ivy Bridge/este conjunto de parches. Ver [`00-RESUMEN.md`](00-RESUMEN.md) y [`06-RENDIMIENTO-Y-ACTUALIZACIONES.md`](06-RENDIMIENTO-Y-ACTUALIZACIONES.md).

### ¿Puedo actualizar macOS a una versión mayor?

No. Cada actualización mayor puede invalidar el root patch de OCLP y dejar el sistema sin aceleración o sin arrancar. La regla es: **no actualizar sin comprobar antes la compatibilidad**. Ver [`06-RENDIMIENTO-Y-ACTUALIZACIONES.md`](06-RENDIMIENTO-Y-ACTUALIZACIONES.md).

### ¿Puedo instalar las actualizaciones de Safari?

Son opcionales y de bajo riesgo (Safari 18.6 y 26.6.1). No afectan al arranque ni al root patch. Si quieres, instálalas; si prefieres no tocar nada, el Safari actual sigue funcionando.

### ¿Puedo usar Apple ID, iMessage o FaceTime?

No están configurados y **no son necesarios** para el funcionamiento del equipo. Técnicamente pueden funcionar con un SMBIOS válido, pero no están garantizados y añaden complejidad. Este montaje se pensó para usarse sin Apple ID.

### ¿Funciona el Wi-Fi?

No hay Wi-Fi integrado; la placa usa **Ethernet Gigabit**. Para Wi-Fi habría que añadir una tarjeta PCIe o un adaptador USB compatible y kexts adicionales. Ver [`07-BLUETOOTH-DBT-122.md`](07-BLUETOOTH-DBT-122.md).

### ¿Funciona el Bluetooth?

Con el adaptador D-Link DBT-122, **no** (es demasiado antiguo). Con un adaptador USB moderno basado en Broadcom BCM20702, los kexts que ya están en el EFI deberían bastar. Ver [`07-BLUETOOTH-DBT-122.md`](07-BLUETOOTH-DBT-122.md).

## Rendimiento y hardware

### ¿Por qué el sistema va lento al arrancar o abrir aplicaciones?

Porque macOS está en un **HDD de 5400 RPM**. El resto del hardware está bien; el disco es el cuello de botella. La mejora real es un **SSD SATA de 2,5"**. Ver [`06-RENDIMIENTO-Y-ACTUALIZACIONES.md`](06-RENDIMIENTO-Y-ACTUALIZACIONES.md).

### ¿Merece la pena cambiar el HDD por un SSD?

Sí, es la única mejora de rendimiento realmente notable. Un SSD de 480 GB–1 TB SATA 2,5" (Crucial, Samsung, WD, Kingston) da mucha más fluidez. La placa es SATA II, así que no alcanzará máximos teóricos, pero la latencia mejora muchísimo.

### ¿Puedo clonar el HDD al SSD?

Se puede, pero **se recomienda instalación limpia** en el SSD (mismo proceso del USB) y luego copiar los datos. Con OCLP, la instalación limpia es más predecible que un clon. Ver [`06-RENDIMIENTO-Y-ACTUALIZACIONES.md`](06-RENDIMIENTO-Y-ACTUALIZACIONES.md).

### ¿Puedo ampliar la RAM?

No: la placa admite **16 GB como máximo** y ya están instalados (2 × 8 GB). Ver [`00-RESUMEN.md`](00-RESUMEN.md).

### ¿Puedo usar dos monitores?

La RX 580 tiene varias salidas; macOS suele manejarlas bien. Si aparece alguna rareza, revisa `agdpmod=vit9696` y WhateverGreen. No está probado en este equipo con dos pantallas.

### ¿Se pueden jugar juegos o usar Steam?

La RX 580 tiene aceleración Metal 2, así que muchos juegos de macOS funcionan con rendimiento moderado. No esperes milagros: el CPU es de 2012 y el disco es un HDD. Para jugar en serio, Windows.

## Arranque y problemas

### ¿Qué hago si macOS no arranca?

1. Arranca desde el pendrive `OCSONOMA`.
2. Restaura la configuración anterior (`VOLVER-A-FASE1.command` o `RESTAURAR-CONFIG-ANTERIOR.cmd`).
3. Si el problema es la EFI interna, vuelve a copiarla.
4. Revisa [`08-SOLUCION-DE-PROBLEMAS.md`](08-SOLUCION-DE-PROBLEMAS.md).

### ¿Puedo tener Windows y macOS en el mismo PC?

Sí. Están en discos distintos y se eligen desde el menú de arranque (F11 o el propio menú de OpenCore). **No toques la partición EFI de Windows**: este montaje usa la EFI del disco de macOS.

### ¿Puedo activar FileVault?

No es recomendable: complica el arranque, el root patch de OCLP y la recuperación. Si necesitas cifrado, valóralo con cuidado y con copias de seguridad.

### ¿Qué significa "Fase 1" y "Fase 2"?

**Fase 1** es la configuración para instalar macOS y aplicar el root patch (sin aceleración y con AMFI desactivado). **Fase 2** es la de uso diario (AMFI activo con AMFIPass y aceleración completa). Ver [`02-EFI-OPENCORE.md`](02-EFI-OPENCORE.md) y [`03-OCLP-Y-ACELERACION.md`](03-OCLP-Y-ACELERACION.md).

### ¿Qué es el "root patch" y por qué hacen falta los KDK?

El **root patch** de OCLP modifica componentes del sistema para devolver la aceleración gráfica (entre otras cosas) a hardware no soportado. Los **KDK** (Kernel Debug Kits) son necesarios para preparar esos parches; ocupan ~2,5 GB y conviene conservarlos. Ver [`03-OCLP-Y-ACELERACION.md`](03-OCLP-Y-ACELERACION.md).

## Mantenimiento y backups

### ¿Cada cuánto hay que hacer mantenimiento?

Con una rutina **mensual** de 5 minutos (espacio, SMART, actualizaciones, copia del EFI) es suficiente. Cada trimestre, ejecuta el diagnóstico. Ver [`04-MANTENIMIENTO.md`](04-MANTENIMIENTO.md).

### ¿Cómo hago una copia de seguridad del EFI?

Copia la carpeta `EFI` del pendrive o de la partición EFI interna a otro USB, a la nube o a otro disco. Es pequeño (unos MB) y es tu seguro si algo deja de arrancar. El pendrive `OCSONOMA` ya es una copia de rescate.

### ¿Puedo borrar el `sleepimage` o los KDKs?

El `sleepimage` (8 GB) se puede borrar, pero no es urgente y macOS puede recrearlo. Los KDKs **no** conviene borrarlos: se usan para re-parchear. Ver [`04-MANTENIMIENTO.md`](04-MANTENIMIENTO.md).

### ¿Puedo usar Time Machine?

Sí, con un disco externo. No requiere Apple ID. En este equipo no hay ningún destino configurado; si quieres, puedes añadir uno.

## Sobre el repositorio

### ¿Por qué no se incluye el EFI completo con los binarios?

Por tamaño, licencias y seguridad: OpenCore, los kexts, OCLP y la imagen de recuperación se descargan de sus fuentes oficiales. En el repositorio están los **configs saneados**, el SSDT y los scripts; también hay una **release** con un ZIP de los configs + SSDT. Ver [`09-REFERENCIAS.md`](09-REFERENCIAS.md).

### ¿Hay datos personales en el repositorio?

No: los números de serie, MLB, UUID y MAC reales se sustituyeron por marcadores, y la IP del informe se reemplazó por una de ejemplo. Ver [`10-LICENCIAS-Y-CREDITOS.md`](10-LICENCIAS-Y-CREDITOS.md).

### ¿Puedo contribuir o reportar un error?

Sí: abre un *issue* o un *pull request* en GitHub. No incluyas datos personales (seriales, MACs, UUIDs) en issues o PRs. Ver [`10-LICENCIAS-Y-CREDITOS.md`](10-LICENCIAS-Y-CREDITOS.md).

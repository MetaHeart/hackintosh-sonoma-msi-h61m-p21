# 06 — Rendimiento y actualizaciones

## El cuello de botella: el HDD

El sistema está instalado en un **Seagate ST500LT012 de 500 GB, 2,5" y 5400 RPM**. Es un disco correcto y con SMART `Verified`, pero es lento: arranque, apertura de aplicaciones y operaciones con muchos archivos pequeños se notan.

**La única mejora de rendimiento realmente significativa es sustituirlo por un SSD SATA de 2,5".**

### Qué esperar de un SSD

| Aspecto | HDD actual | SSD SATA (2,5") |
|---|---|---|
| Arranque de macOS | Decenas de segundos | Mucho más rápido |
| Apertura de apps | Lenta | Notablemente más rápida |
| Copiar muchos archivos | Muy lento | Gran mejora (sobre todo latencia) |
| Ruido / consumo | Tiene partes móviles | Silencioso y eficiente |

La placa es H61 (SATA II, hasta ~300 MB/s), así que un SSD no dará sus máximos teóricos, pero la ganancia en **latencia y operaciones por segundo** es enorme frente a un HDD de 5400 RPM.

### Qué SSD comprar

- Formato **2,5" SATA** (no M.2; esta placa no lo admite).
- Capacidad recomendada: **480 GB a 1 TB**.
- Marcas fiables: Crucial BX500/MX500, Samsung 870 EVO, WD Blue, Kingston KC600.
- Evita SSD genéricos sin marca o de dudosa procedencia.

### Cómo migrar (recomendado: instalación limpia)

> El HDD funciona; esto es opcional y no urgente. Antes de tocar nada, **copia tus datos y el EFI**.

1. Consigue el SSD y conéctalo (por SATA o por USB).
2. Arranca desde el pendrive `OCSONOMA`.
3. Instala macOS Sonoma en el SSD siguiendo el mismo proceso de [`01-INSTALACION.md`](01-INSTALACION.md) (APFS + GUID).
4. Aplica el root patch de OCLP en el SSD.
5. Copia la EFI al SSD (`COPIAR-EFI-INTERNO.command`) o restaura tu copia del EFI.
6. En la BIOS, pon el SSD como primera opción de arranque (o selecciónalo con `F11`).
7. Deja el HDD como disco de datos/backup o quítalo.

**Alternativa:** clonar el HDD al SSD con una herramienta específica (Carbon Copy Cloner, SuperDuper, etc.). Puede funcionar, pero la instalación limpia es más predecible, sobre todo con OCLP de por medio.

## Qué NO hace falta cambiar

- **RAM:** 16 GB (2 × 8 GB) es el máximo de la placa; ya está al tope.
- **CPU:** el i7-3770 sigue rindiendo bien para ofimática, navegación y multimedia.
- **GPU:** la RX 580 8 GB es perfecta para este equipo; no necesita VBIOS modificada.
- **Ventilación:** con un HDD de 5400 RPM y una RX 580, mantén la caja limpia y con buen flujo de aire.

## Política de actualizaciones

Esta es la parte más delicada de un Hackintosh con OCLP. Reglas claras:

1. **Actualizaciones automáticas: OFF.** Ya aplicado; evita sorpresas.
2. **No instalar macOS Tahoe 26.7.1.** No hay soporte para este hardware.
3. **No instalar actualizaciones de macOS** (ni menores) sin comprobar antes:
   - Que la versión de OCLP las soporta.
   - Que hay copia del EFI y del pendrive de rescate.
   - Que se sabe cómo volver atrás.
4. **Safari** (18.6 y 26.6.1) es opcional y de menor riesgo, pero tampoco es urgente. Puedes seguir usando el Safari actual o instalar Firefox/Chrome.
5. **Después de cualquier actualización de macOS**, OCLP pedirá volver a aplicar el root patch. Hazlo antes de dar el sistema por bueno.
6. **No instalar Security Response Updates (RSR)** en sistemas pre-Haswell: fallan. Si aparecen, ignóralos.
7. **Apple ID no es necesario** para nada de esto.

## Otras mejoras opcionales

| Mejora | Cómo | Impacto |
|---|---|---|
| Evitar que Spotlight indexe el pendrive | `sudo mdutil -i off /Volumes/OCSONOMA` | Menos actividad de disco. |
| Liberar 8 GB del `sleepimage` | `sudo rm -f /private/var/vm/sleepimage` | Más espacio (no urgente). |
| Desactivar el sueño si falla al despertar | `sudo pmset -a sleep 0` | Evita cuelgues al despertar. |
| Autoencendido tras corte de luz | `sudo pmset -a autorestart 1` | Útil si el equipo está desatendido. |
| Reducir transparencias | Ajustes → Accesibilidad → Pantalla → Reducir transparencia | Menos carga de GPU en un equipo antiguo. |
| Navegador alternativo | Firefox o Chrome | Menos dependencia de Safari. |

## Antes de cualquier cambio grande

- Copia la carpeta `EFI` completa.
- Ten el pendrive `OCSONOMA` conectado y probado.
- Apunta qué configuración tienes (Fase 1 o Fase 2) y qué `boot-args` usas.
- No hagas dos cambios a la vez: si algo falla, sabrás qué lo causó.

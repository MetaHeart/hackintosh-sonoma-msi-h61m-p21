# AVISO: version publica. Edita la ruta SRC de abajo antes de ejecutar.
# Este script formatea un USB (FAT32). Revisa que el disco elegido sea el correcto.

# -*- coding: utf-8 -*-
"""PREPARAR-USB-SONOMA
Formatea el pendrive USB (FAT32, etiqueta OCSONOMA) y copia los archivos
preparados en C:\\Users\\PC\\Documents\\Monterey-USB\\USB-sonoma
Se ejecuta con permisos de administrador (lo hace el .cmd de al lado).
"""
import ctypes
import json
import subprocess
import sys
import time
from pathlib import Path

SRC = Path(r'C:\ruta\a\tu\carpeta\USB-sonoma')
LABEL = 'OCSONOMA'
MAX_GB = 64  # seguridad: no formatear discos grandes por error

k32 = ctypes.windll.kernel32


def run_ps(cmd):
    return subprocess.run(['powershell', '-NoProfile', '-Command', cmd],
                          capture_output=True, text=True)


def usb_candidates():
    ps = (
        "$out = @(); "
        "foreach ($d in (Get-Disk | Where-Object { $_.BusType -eq 'USB' })) { "
        "  foreach ($p in ($d | Get-Partition | Where-Object { $_.DriveLetter })) { "
        "    $out += [pscustomobject]@{ letter = [string]$p.DriveLetter; "
        "      size = [long]$d.Size; name = [string]$d.FriendlyName } } }; "
        "$out | ConvertTo-Json -Compress"
    )
    r = run_ps(ps)
    if r.returncode != 0 or not r.stdout.strip():
        return []
    try:
        data = json.loads(r.stdout)
    except json.JSONDecodeError:
        return []
    if isinstance(data, dict):
        data = [data]
    return data


def vol_label(letter):
    buf = ctypes.create_unicode_buffer(261)
    fs = ctypes.create_unicode_buffer(261)
    s = ctypes.c_uint()
    m = ctypes.c_uint()
    f = ctypes.c_uint()
    ok = k32.GetVolumeInformationW(f'{letter}:\\', buf, 261, ctypes.byref(s),
                                   ctypes.byref(m), ctypes.byref(f), fs, 261)
    return (buf.value, fs.value) if ok else ('?', '?')


def human(n):
    n = float(n)
    for u in ('B', 'KB', 'MB', 'GB', 'TB'):
        if n < 1024:
            return f'{n:.1f} {u}'
        n /= 1024
    return '??? '


def is_admin():
    try:
        return bool(ctypes.windll.shell32.IsUserAnAdmin())
    except Exception:
        return False


def main():
    print('=' * 62)
    print(' PREPARAR PENDRIVE PARA macOS SONOMA (etiqueta OCSONOMA)')
    print('=' * 62)
    print()

    if not is_admin():
        print('ERROR: este script necesita permisos de administrador.')
        print('Cierra esta ventana y usa el archivo PREPARAR-USB-SONOMA.cmd')
        return 1
    if not SRC.exists():
        print(f'ERROR: no existe la carpeta preparada:\n  {SRC}')
        return 1

    cands = usb_candidates()
    if not cands:
        print('No se detecta ningun disco USB con letra de unidad.')
        print('Conecta el pendrive de ~8 GB y vuelve a ejecutar.')
        return 1

    print('Discos USB detectados (solo estos se pueden elegir):')
    print()
    for c in cands:
        letra = c['letter']
        etiqueta, fs = vol_label(letra)
        print(f"   [{letra}:]  etiqueta: {etiqueta or '(sin etiqueta)'}   "
              f"tamano: {human(c['size'])}   sistema: {fs}")
    print()
    print('AVISO: se borrara POR COMPLETO el disco USB que elijas.')
    print('       Debe ser el pendrive de ~8 GB dedicado a Sonoma.')
    print()
    sel = input('Escribe SOLO la letra del pendrive (ejemplo: Z) y Enter: ').strip().upper()
    elegido = None
    for c in cands:
        if c['letter'].upper() == sel:
            elegido = c
    if elegido is None:
        print('ERROR: letra no valida (no esta en la lista de arriba). Cancelado.')
        return 1

    if elegido['size'] > MAX_GB * 1024 ** 3:
        print(f"ERROR: ese disco es mas grande de {MAX_GB} GB "
              f"({human(elegido['size'])}). Por seguridad no lo formateo.")
        return 1

    etiqueta, fs = vol_label(sel)
    print()
    print(f"Vas a BORRAR la unidad [{sel}]:  etiqueta '{etiqueta or '(sin etiqueta)'}'  "
          f"tamano {human(elegido['size'])}")
    ans = input('Seguro? Escribe SI (en mayusculas) y pulsa Enter: ').strip()
    if ans != 'SI':
        print('Cancelado. No se ha tocado nada.')
        return 1

    # Re-comprobar por seguridad que sigue siendo un disco USB
    r = run_ps(f"((Get-Partition -DriveLetter {sel}) | Get-Disk).BusType")
    if r.returncode != 0 or 'USB' not in r.stdout.upper():
        print('ERROR: la comprobacion de seguridad fallo. Cancelado.')
        return 1

    print()
    print('Formateando en FAT32 con etiqueta OCSONOMA ...')
    ps = ("Format-Volume -DriveLetter {l} -FileSystem FAT32 "
          "-NewFileSystemLabel '{lab}' -Confirm:$false -Force | Out-Null")
    r = run_ps(ps.format(l=sel, lab=LABEL))
    if r.returncode != 0:
        print('ERROR al formatear:')
        print((r.stderr or r.stdout).strip())
        return 1

    time.sleep(1.5)
    etiqueta, fs = vol_label(sel)
    if fs.upper() != 'FAT32':
        print(f"ERROR: el formato no quedo en FAT32 (quedo: {fs}).")
        return 1
    print(f"   Formato OK: {fs}, etiqueta '{etiqueta}'.")

    print()
    print('Copiando archivos al pendrive (~1,5 GB; puede tardar unos minutos) ...')
    t0 = time.time()
    r = subprocess.run(['robocopy', str(SRC), f'{sel}:\\', '/E', '/NFL', '/NDL',
                        '/NJH', '/NJS', '/NP', '/R:2', '/W:1'],
                       capture_output=True, text=True)
    if r.returncode >= 8:
        print('ERROR durante la copia. Detalle (ultimas lineas):')
        print('\n'.join((r.stdout or '').splitlines()[-15:]))
        return 1
    print(f'   Copia terminada en {time.time() - t0:.0f} segundos.')

    print('Verificando archivos copiados ...')
    src_files = [p for p in SRC.rglob('*') if p.is_file()]
    problemas = []
    for p in src_files:
        rel = p.relative_to(SRC)
        dst = Path(f'{sel}:\\') / rel
        try:
            if (not dst.exists()) or dst.stat().st_size != p.stat().st_size:
                problemas.append(str(rel))
        except OSError:
            problemas.append(str(rel))
    if problemas:
        print('ERROR: faltan o no coinciden estos archivos:')
        for m in problemas[:20]:
            print('   ' + m)
        return 1
    print(f'   OK: {len(src_files)} archivos copiados y verificados.')

    print()
    print('=' * 62)
    print(' PENDRIVE LISTO (etiqueta OCSONOMA).')
    print()
    print(' Siguiente: apaga el PC, conecta el pendrive y sigue la GUIA')
    print(' (esta en el Escritorio y tambien dentro del pendrive).')
    print('=' * 62)
    return 0


if __name__ == '__main__':
    try:
        code = main()
    except KeyboardInterrupt:
        print('\nCancelado.')
        code = 1
    sys.exit(code)

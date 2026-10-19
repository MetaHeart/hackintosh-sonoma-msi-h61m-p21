# AVISO: archivo de ejemplo saneado para el repositorio publico.
# Los valores TU-SERIAL-AQUI / TU-MLB-AQUI / 00000000... son marcadores:
# genera tu propio SMBIOS antes de usar este script.

"""
build_config.py - Genera las configuraciones de OpenCore para Sonoma 14.8.9 + OCLP
sobre i7-3770 (Ivy Bridge, sin AVX2) + RX 580, placa MSI H61M-P21.

Salidas:
  USB-sonoma/EFI/OC/config.plist                  (FASE 1: instalar + root patch)
  USB-sonoma/config-fase2.plist                   (FASE 2: AMFI activo + AMFIPass)
  USB-sonoma/EXTRAS/config-fase1-backup.plist     (copia de seguridad de FASE 1)
  USB-sonoma/EXTRAS/config-fase1-hv.plist         (variante con spoof VMM estatico)
  USB-sonoma/EXTRAS/config-fase2-amfi-off.plist   (respaldo de FASE 2 con AMFI desactivado)
"""
import copy
import json
import plistlib
from pathlib import Path

BASE = Path(r'C:\ruta\a\Monterey-USB')
SAMPLE = BASE / 'tools' / 'oc' / 'Docs' / 'Sample.plist'
DUMP = BASE / 'tools' / 'refs' / 'patches-dump.json'
OCLP_CFG = BASE / 'tools' / 'refs' / 'oclp-config.plist'
OUT = BASE / 'USB-sonoma'

# ---------------------------------------------------------------- datos fijos
SERIAL = 'TU-SERIAL-AQUI'
MLB = 'TU-MLB-AQUI'
SYSUUID = '00000000-0000-0000-0000-000000000000'
ROM = bytes([0x00, 0x00, 0x00, 0x00, 0x00, 0x00])  # pon tu MAC o deja ceros

ARGS_F1 = ('-v keepsyms=1 debug=0x100 agdpmod=vit9696 -wegnoigpu -amfipassbeta '
           'ipc_control_port_options=0 amfi=0x80 -amd_no_dgpu_accel')
ARGS_F2 = 'agdpmod=vit9696 -wegnoigpu -amfipassbeta ipc_control_port_options=0'
ARGS_F2_AMFI_OFF = ARGS_F2 + ' amfi=0x80'

# kexts: (BundlePath, carpeta fuente, binario, MinKernel)
KEXTS = [
    ('Lilu.kext', r'tools\lilu\Lilu.kext', 'Lilu', ''),
    ('VirtualSMC.kext', r'tools\vsmc\Kexts\VirtualSMC.kext', 'VirtualSMC', ''),
    ('WhateverGreen.kext', r'tools\weg\WhateverGreen.kext', 'WhateverGreen', ''),
    ('RestrictEvents.kext', r'tools\restrictevents-x\RestrictEvents.kext', 'RestrictEvents', '20.4.0'),
    ('CryptexFixup.kext', r'tools\cryptexfixup-x\CryptexFixup.kext', 'CryptexFixup', '22.0.0'),
    ('AMFIPass.kext', r'tools\amfipass-x\AMFIPass.kext', 'AMFIPass', '21.0.0'),
    ('KDKlessWorkaround.kext', r'tools\kdkless\x\KDKlessWorkaround.kext', 'KDKlessWorkaround', '22.3.0'),
    ('AppleIntelCPUPowerManagementClient.kext', r'tools\aicpm-client-x\AppleIntelCPUPowerManagementClient.kext',
     'AppleIntelCPUPowerManagementClient', '22.0.0'),
    ('AppleIntelCPUPowerManagement.kext', r'tools\aicpm-x\AppleIntelCPUPowerManagement.kext',
     'AppleIntelCPUPowerManagement', '22.0.0'),
    ('RealtekRTL8111.kext', r'tools\rtl\RealtekRTL8111-V3.0.0\Release\RealtekRTL8111.kext',
     'RealtekRTL8111', ''),
    # Bluetooth USB Broadcom (DBT-122): firmware + parche BlueTool (Monterey+)
    ('BrcmFirmwareData.kext', r'tools\brcm\x\BrcmFirmwareData.kext', 'BrcmFirmwareData', ''),
    ('BrcmPatchRAM3.kext', r'tools\brcm\x\BrcmPatchRAM3.kext', 'BrcmPatchRAM3', '20.0.0'),
    ('BlueToolFixup.kext', r'tools\brcm\x\BlueToolFixup.kext', 'BlueToolFixup', '21.0.0'),
    # Audio onboard (codec VIA VT1708S de la MSI H61M-P21).
    # AppleALC no soporta codecs VIA; VoodooHDA si. Version 3.7.0 "BL"
    # (bootloader) con IOAudioFamily embebido: se inyecta desde OpenCore.
    ('VoodooHDA_BL.kext', r'tools\voodoo\efi\VoodooHDA_BL.kext', 'VoodooHDA_BL', ''),
]

# parches Kernel>Patch (por comentario) - config principal
KP_MAIN = [
    'Force FileVault on Broken Seal',
    'Disable Library Validation Enforcement',
    'Disable _csr_check() in _vnode_check_signature',
    'Disable Root Hash validation',
    'CaseySJ - Fix PCI bus enumeration (Ventura)',
    'Fix PCI bus enumeration (Sonoma)',
]
# parches extra de la variante hv (spoof VMM estatico)
KP_HV = [
    'Reroute kern.hv_vmm_present patch (1)',
    'Reroute kern.hv_vmm_present patch (2) Legacy',
    'Reroute kern.hv_vmm_present patch (2) Ventura',
    'Force IOGetVMMPresent',
]
BP_MAIN = ['Skip Board ID check']
BP_HV = ['Skip Board ID check', 'Reroute HW_BID to OC_BID']

# -------------------------------------------------------- utilidades de carga
dump = json.loads(DUMP.read_text())
OCLP_KP = dump['oclp']['kernel_patch']
OCLP_BP = dump['oclp']['booter_patch']


def hx(v):
    if isinstance(v, str) and v:
        return bytes.fromhex(v)
    return b''


def norm_kp(e):
    return {
        'Arch': e.get('Arch', 'Any'),
        'Base': e.get('Base', ''),
        'Comment': e.get('Comment', ''),
        'Count': int(e.get('Count', 0) or 0),
        'Enabled': True,
        'Find': hx(e.get('Find', '')),
        'Identifier': e.get('Identifier', ''),
        'Limit': int(e.get('Limit', 0) or 0),
        'Mask': hx(e.get('Mask', '')),
        'MaxKernel': e.get('MaxKernel', '') or '',
        'MinKernel': e.get('MinKernel', '') or '',
        'Replace': hx(e.get('Replace', '')),
        'ReplaceMask': hx(e.get('ReplaceMask', '')),
        'Skip': int(e.get('Skip', 0) or 0),
    }


def norm_bp(e):
    # Booter>Patch en OpenCore 1.0.8 no admite MinKernel/MaxKernel
    return {
        'Arch': e.get('Arch', 'Any'),
        'Comment': e.get('Comment', ''),
        'Count': int(e.get('Count', 0) or 0),
        'Enabled': True,
        'Find': hx(e.get('Find', '')),
        'Identifier': e.get('Identifier', ''),
        'Limit': int(e.get('Limit', 0) or 0),
        'Mask': hx(e.get('Mask', '')),
        'Replace': hx(e.get('Replace', '')),
        'ReplaceMask': hx(e.get('ReplaceMask', '')),
        'Skip': int(e.get('Skip', 0) or 0),
    }


def pick_kp(comments):
    out = []
    for want in comments:
        found = [e for e in OCLP_KP if e.get('Comment', '') == want]
        if not found:
            avail = [e.get('Comment', '') for e in OCLP_KP]
            raise SystemExit(f'Kernel patch no encontrado: {want!r}\nDisponibles: {avail}')
        out.append(norm_kp(found[0]))
    return out


def pick_bp(comments):
    out = []
    for want in comments:
        found = [e for e in OCLP_BP if e.get('Comment', '') == want]
        if not found:
            avail = [e.get('Comment', '') for e in OCLP_BP]
            raise SystemExit(f'Booter patch no encontrado: {want!r}\nDisponibles: {avail}')
        out.append(norm_bp(found[0]))
    return out


oclp_template = plistlib.load(open(OCLP_CFG, 'rb'))
ioskywalk_block = None
for e in oclp_template['Kernel']['Block']:
    if e.get('Identifier') == 'com.apple.iokit.IOSkywalkFamily':
        ioskywalk_block = copy.deepcopy(e)
        ioskywalk_block['Enabled'] = True
if ioskywalk_block is None:
    raise SystemExit('No se encontro el bloque IOSkywalkFamily en oclp-config.plist')

# ------------------------------------------------------ verificacion de kexts
print('== Verificacion de kexts fuente ==')
for bundle, src, binary, _ in KEXTS:
    p = BASE / src / 'Contents' / 'MacOS' / binary
    if not p.exists():
        candidates = [f.name for f in (BASE / src / 'Contents' / 'MacOS').glob('*')] \
            if (BASE / src / 'Contents' / 'MacOS').exists() else ['<carpeta MacOS no existe>']
        raise SystemExit(f'ERROR: {bundle}: no existe {p}\nCandidatos: {candidates}')
    print(f'   OK {bundle:45} -> {binary}')

# --------------------------------------------------------- construccion base
sample = plistlib.load(open(SAMPLE, 'rb'))


def base_config():
    cfg = copy.deepcopy(sample)

    # ACPI: solo SSDT-EC-USBX
    cfg['ACPI']['Add'] = [{
        'Comment': 'SSDT-EC-USBX-DESKTOP (EC falso + energia USB)',
        'Enabled': True, 'Path': 'SSDT-EC-USBX.aml',
    }]

    # DeviceProperties: codec de audio onboard (HDEF).
    # El audio de la placa lo maneja VoodooHDA (kext inyectado), no AppleALC.
    cfg['DeviceProperties']['Add'] = {
        'PciRoot(0x0)/Pci(0x1b,0x0)': {
            'layout-id': bytes([0x01, 0x00, 0x00, 0x00]),
        },
    }

    # Kernel > Add
    cfg['Kernel']['Add'] = [{
        'Arch': 'Any',
        'BundlePath': bundle,
        'Comment': '',
        'Enabled': True,
        'ExecutablePath': 'Contents/MacOS/' + binary,
        'MaxKernel': '',
        'MinKernel': mk,
        'PlistPath': 'Contents/Info.plist',
    } for bundle, _, binary, mk in KEXTS]

    # Kernel > Quirks (ajustes para Ivy Bridge / H61)
    kq = cfg['Kernel']['Quirks']
    kq['AppleCpuPmCfgLock'] = True       # MSR 0xE2 bloqueado en BIOS MSI H61
    kq['AppleXcpmCfgLock'] = False       # Ivy usa AICPUPM, no XCPM
    kq['DisableIoMapper'] = True         # evitar problemas de VT-d/DMAR
    kq['DisableLinkeditJettison'] = True # requerido por Lilu en macOS modernos
    kq['PanicNoKextDump'] = True
    kq['PowerTimeoutKernelPanic'] = True
    kq['XhciPortLimit'] = False

    # Misc > Boot
    mb = cfg['Misc']['Boot']
    mb['ShowPicker'] = True
    mb['Timeout'] = 10
    mb['HideAuxiliary'] = False
    mb['PickerMode'] = 'Builtin'
    mb['PickerAttributes'] = 0
    mb['PickerVariant'] = 'Auto'
    mb['TakeoffDelay'] = 0
    mb['PickerAudioAssist'] = False

    # Misc > Security
    ms = cfg['Misc']['Security']
    ms['SecureBootModel'] = 'Disabled'
    ms['Vault'] = 'Optional'
    ms['ScanPolicy'] = 0
    ms['DmgLoading'] = 'Signed'
    ms['BlacklistAppleUpdate'] = True
    ms['AllowSetDefault'] = True
    ms['EnablePassword'] = False
    ms['AuthRestart'] = False
    ms['ApECID'] = 0

    # NVRAM > Delete (incluye claves de OCLP para evitar residuos)
    cfg['NVRAM']['Delete'] = {
        '4D1EDE05-38C7-4A6A-9CC6-4BCCA8B38C14': ['DefaultBackgroundColor'],
        '4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102': [
            'rtc-blacklist', 'revpatch', 'revblock', 'OCLP-Settings', 'OCLP-Version',
            'OCLP-Model', 'OCLP-Spoofed-SN', 'OCLP-Spoofed-MLB',
        ],
        '7C436110-AB2A-4BBB-A880-FE41995C9F82': ['boot-args', 'ForceDisplayRotationInEFI'],
        'FA4CE28D-B62F-4C99-9CC3-6815686E30F9': [],
    }

    # NVRAM > Add
    cfg['NVRAM']['Add'] = cfg['NVRAM'].get('Add', {})
    cfg['NVRAM']['Add']['7C436110-AB2A-4BBB-A880-FE41995C9F82'] = {
        'bluetoothExternalDongleFailed': b'\x00',
        'bluetoothInternalControllerInfo': bytes(14),
        'csr-active-config': bytes([0x03, 0x08, 0x00, 0x00]),  # 0x803
    }
    cfg['NVRAM']['Add']['4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102'] = {
        'OCLP-Settings': '-allow_fv -allow_amfi',
        'revpatch': 'sbvmm,f16c,asset',
        'revblock': 'media',
    }

    # PlatformInfo
    gen = cfg['PlatformInfo']['Generic']
    gen['SystemProductName'] = 'iMac13,2'
    gen['SystemSerialNumber'] = SERIAL
    gen['MLB'] = MLB
    gen['SystemUUID'] = SYSUUID
    gen['ROM'] = ROM
    gen['ProcessorType'] = 0
    gen['SpoofVendor'] = True
    cfg['PlatformInfo']['Automatic'] = True
    cfg['PlatformInfo']['UpdateSMBIOSMode'] = 'Create'

    # UEFI > Drivers
    cfg['UEFI']['Drivers'] = [
        {'Arguments': '', 'Comment': 'HFS+ (Apple)', 'Enabled': True,
         'HideVerbose': False, 'LoadEarly': False, 'Path': 'HfsPlus.efi'},
        {'Arguments': '', 'Comment': 'OpenCore runtime', 'Enabled': True,
         'HideVerbose': False, 'LoadEarly': False, 'Path': 'OpenRuntime.efi'},
        {'Arguments': '--preserve-boot', 'Comment': 'Reset NVRAM en el selector',
         'Enabled': True, 'HideVerbose': False, 'LoadEarly': False, 'Path': 'ResetNvramEntry.efi'},
    ]

    # UEFI > Quirks
    uq = cfg['UEFI']['Quirks']
    uq['IgnoreInvalidFlexRatio'] = True  # Sandy/Ivy: MSR FLEX_RATIO invalido
    uq['RequestBootVarRouting'] = True

    # UEFI > Output
    cfg['UEFI']['Output']['Resolution'] = 'Max'
    cfg['UEFI']['Output']['ProvideConsoleGop'] = True

    return cfg


def apply_bootargs(cfg, args):
    cfg['NVRAM']['Add']['7C436110-AB2A-4BBB-A880-FE41995C9F82']['boot-args'] = args


def cfg_fase1():
    cfg = base_config()
    cfg['Booter']['Patch'] = pick_bp(BP_MAIN)
    cfg['Kernel']['Patch'] = pick_kp(KP_MAIN)
    cfg['Kernel']['Block'] = [ioskywalk_block]
    apply_bootargs(cfg, ARGS_F1)
    return cfg


def cfg_fase2(args):
    cfg = base_config()
    cfg['Booter']['Patch'] = pick_bp(BP_MAIN)
    cfg['Kernel']['Patch'] = pick_kp(KP_MAIN)
    cfg['Kernel']['Block'] = [ioskywalk_block]
    apply_bootargs(cfg, args)
    return cfg


def cfg_fase1_hv():
    cfg = base_config()
    cfg['Booter']['Patch'] = pick_bp(BP_HV)
    cfg['Kernel']['Patch'] = pick_kp(KP_HV + KP_MAIN)
    cfg['Kernel']['Block'] = [ioskywalk_block]
    apply_bootargs(cfg, ARGS_F1)
    return cfg


# -------------------------------------------------------------------- salidas
OUT.mkdir(exist_ok=True)
(OUT / 'EFI' / 'OC').mkdir(parents=True, exist_ok=True)
(OUT / 'EXTRAS').mkdir(exist_ok=True)

outputs = {
    OUT / 'EFI' / 'OC' / 'config.plist': cfg_fase1(),
    OUT / 'config-fase2.plist': cfg_fase2(ARGS_F2),
    OUT / 'EXTRAS' / 'config-fase1-backup.plist': cfg_fase1(),
    OUT / 'EXTRAS' / 'config-fase1-hv.plist': cfg_fase1_hv(),
    OUT / 'EXTRAS' / 'config-fase2-amfi-off.plist': cfg_fase2(ARGS_F2_AMFI_OFF),
}

for path, cfg in outputs.items():
    with open(path, 'wb') as f:
        plistlib.dump(cfg, f)
    print(f'\nESCRITO: {path}')

# ------------------------------------------------------------------- resumen
print('\n================= RESUMEN =================')
for path, cfg in outputs.items():
    args = cfg['NVRAM']['Add']['7C436110-AB2A-4BBB-A880-FE41995C9F82'].get('boot-args')
    kp = [e['Comment'] for e in cfg['Kernel']['Patch']]
    bp = [e['Comment'] for e in cfg['Booter']['Patch']]
    ka = [e['BundlePath'] for e in cfg['Kernel']['Add']]
    print(f'\n--- {path.name} ---')
    print(f'  boot-args: {args}')
    print(f'  Kernel>Add ({len(ka)}): {ka}')
    print(f'  Kernel>Patch: {kp}')
    print(f'  Booter>Patch: {bp}')
    print(f'  Kernel>Block: {[e["Comment"] for e in cfg["Kernel"]["Block"]]}')
    csr = cfg['NVRAM']['Add']['7C436110-AB2A-4BBB-A880-FE41995C9F82']['csr-active-config']
    print(f'  csr-active-config: {csr.hex()}')
    print(f'  OCLP-Settings: {cfg["NVRAM"]["Add"]["4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102"]["OCLP-Settings"]}')
print('\nListo.')

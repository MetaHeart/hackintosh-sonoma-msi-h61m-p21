# =====================================================================
#  INSTALAR-ARRANQUE-INTERNO
#  Copia la EFI de OpenCore (que esta en el pendrive OCSONOMA) a la
#  particion EFI (200 MB) del disco interno donde esta macOS.
#  Asi el PC arranca sin pendrive.
#
#  NO toca macOS, ni Windows, ni tus datos:
#  solo escribe archivos en la particion de arranque EFI del disco de macOS.
# =====================================================================

$ErrorActionPreference = 'Continue'

function Pausa([int]$code) {
    Write-Host ''
    Read-Host 'Pulsa Enter para salir' | Out-Null
    exit $code
}

function Desmontar($diskNum, $partNum, $mount) {
    try { Remove-PartitionAccessPath -DiskNumber $diskNum -PartitionNumber $partNum -AccessPath $mount -ErrorAction SilentlyContinue | Out-Null } catch {}
    try { & mountvol $mount /D 2>$null | Out-Null } catch {}
}

Write-Host '========================================================'
Write-Host ' INSTALAR EL ARRANQUE (OpenCore) EN EL DISCO INTERNO'
Write-Host '========================================================'
Write-Host ''

# --- 1) localizar el pendrive OCSONOMA ------------------------------- 
$usb = Get-Volume -ErrorAction SilentlyContinue |
       Where-Object { $_.FileSystemLabel -eq 'OCSONOMA' -and $_.DriveLetter } |
       Select-Object -First 1
if (-not $usb) {
    Write-Host 'ERROR: no encuentro ningun pendrive con la etiqueta OCSONOMA.'
    Pausa 1
}
$usbRoot = $usb.DriveLetter + ':\'
$src = Join-Path $usbRoot 'EFI'
if (-not (Test-Path (Join-Path $src 'OC\OpenCore.efi'))) {
    Write-Host ('ERROR: el pendrive ' + $usbRoot + ' no contiene EFI\OC\OpenCore.efi.')
    Pausa 1
}
Write-Host ('Pendrive OCSONOMA : ' + $usbRoot)

# --- 2) localizar el disco con macOS (APFS) y su particion EFI -------
$apfsGuid = '{7c3457ef-0000-11aa-aa11-00306543ecac}'
$efiGuid  = '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}'

$apfs = Get-Partition | Where-Object { $_.GptType -eq $apfsGuid } | Select-Object -First 1
if (-not $apfs) {
    Write-Host 'ERROR: no encuentro ningun disco con macOS (particion APFS).'
    Pausa 1
}
$disk = Get-Disk -Number $apfs.DiskNumber
if ($disk.BusType -eq 'USB') {
    Write-Host 'ERROR: el disco APFS esta conectado por USB; no continuo por seguridad.'
    Pausa 1
}
$esp = Get-Partition -DiskNumber $apfs.DiskNumber | Where-Object { $_.GptType -eq $efiGuid } | Select-Object -First 1
if (-not $esp) {
    Write-Host 'ERROR: el disco de macOS no tiene particion EFI.'
    Pausa 1
}
if ($esp.Size -gt 1GB) {
    Write-Host 'ERROR: la particion EFI es anormalmente grande; no continuo por seguridad.'
    Pausa 1
}
Write-Host ('Disco de macOS    : ' + $disk.FriendlyName + ' (' + [math]::Round($disk.Size/1GB,1) + ' GB, disco n. ' + $disk.Number + ')')
Write-Host ('Particion EFI     : n. ' + $esp.PartitionNumber + ' (' + [math]::Round($esp.Size/1MB,0) + ' MB)')
Write-Host ''

# --- 3) montar la particion EFI con una letra temporal ---------------
$letter = $null
foreach ($L in 'Y','W','X','V','U','T') {
    if (-not (Get-Volume -DriveLetter $L -ErrorAction SilentlyContinue)) { $letter = $L; break }
}
if (-not $letter) {
    Write-Host 'ERROR: no hay ninguna letra de unidad libre (Y, W, X, V...).'
    Pausa 1
}
$mount = $letter + ':\'

Write-Host ('Montando la particion EFI en ' + $mount + ' ...')
$montado = $false
try {
    Add-PartitionAccessPath -DiskNumber $apfs.DiskNumber -PartitionNumber $esp.PartitionNumber -AccessPath $mount -ErrorAction Stop
    $montado = $true
} catch {
    Write-Host ('  Metodo 1 no funciono: ' + $_.Exception.Message)
}
if (-not $montado) {
    $guid = ($esp.AccessPaths | Where-Object { $_ -like '\\?\Volume{*' } | Select-Object -First 1)
    if ($guid) {
        Write-Host ('  Probando metodo 2 (mountvol ' + $guid + ') ...')
        & mountvol $mount $guid 2>&1 | Write-Host
        if (Test-Path $mount) { $montado = $true }
    }
}
if (-not $montado) {
    Write-Host 'ERROR: no pude montar la particion EFI. No se ha modificado nada.'
    Pausa 1
}
Write-Host '  Montada correctamente.'
Write-Host ''

# --- 4) comprobar que se puede leer (si no, reparar solo esa particion)
$legible = $true
try { $null = Get-ChildItem $mount -Force -ErrorAction Stop } catch { $legible = $false }
if (-not $legible) {
    Write-Host 'AVISO: la particion EFI no se puede leer (parece danada).'
    Write-Host 'Se puede volver a formatear SOLO esa particion de arranque (200 MB).'
    Write-Host 'Eso NO afecta a macOS ni a tus archivos.'
    $r = Read-Host 'Escribe SI para formatear y continuar (o pulsa Enter para cancelar)'
    if ($r -ne 'SI') {
        Desmontar $apfs.DiskNumber $esp.PartitionNumber $mount
        Write-Host 'Cancelado. No se ha modificado nada.'
        Pausa 1
    }
    try {
        Format-Volume -Partition $esp -FileSystem FAT32 -NewFileSystemLabel 'EFI' -Confirm:$false -Force -ErrorAction Stop | Out-Null
    } catch {
        Write-Host ('ERROR al formatear: ' + $_.Exception.Message)
        Desmontar $apfs.DiskNumber $esp.PartitionNumber $mount
        Pausa 1
    }
    if (-not (Test-Path $mount)) {
        $esp = Get-Partition -DiskNumber $apfs.DiskNumber | Where-Object { $_.GptType -eq $efiGuid } | Select-Object -First 1
        try {
            Add-PartitionAccessPath -DiskNumber $apfs.DiskNumber -PartitionNumber $esp.PartitionNumber -AccessPath $mount -ErrorAction Stop
        } catch {
            $guid = ($esp.AccessPaths | Where-Object { $_ -like '\\?\Volume{*' } | Select-Object -First 1)
            if ($guid) { & mountvol $mount $guid 2>&1 | Write-Host }
        }
    }
    if (-not (Test-Path $mount)) {
        Write-Host 'ERROR: la particion sigue sin poder montarse.'
        Pausa 1
    }
    Write-Host '  Particion reparada y montada.'
}

# --- 5) copia de seguridad de lo que hubiera en la EFI ---------------
if (Test-Path (Join-Path $mount 'EFI')) {
    $backup = Join-Path $usbRoot ('EXTRAS\EFI-interno-backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
    Write-Host ('Guardando copia de seguridad del contenido anterior en:')
    Write-Host ('  ' + $backup)
    & robocopy (Join-Path $mount 'EFI') $backup /E /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
}

# --- 6) copiar la EFI nueva ------------------------------------------
Write-Host 'Copiando la EFI nueva al disco interno...'
& robocopy $src (Join-Path $mount 'EFI') /E /R:2 /W:1 /NFL /NDL /NJH /NJS | Out-Null
$rc = $LASTEXITCODE
Write-Host ('  robocopy termino con codigo ' + $rc)
if ($rc -ge 8) {
    Write-Host 'ERROR: la copia fallo. Vuelve a intentarlo o avisa por el chat.'
    Desmontar $apfs.DiskNumber $esp.PartitionNumber $mount
    Pausa 1
}

# --- 7) verificar -----------------------------------------------------
$checks = @(
    'EFI\BOOT\BOOTx64.efi',
    'EFI\OC\OpenCore.efi',
    'EFI\OC\config.plist',
    'EFI\OC\Drivers\HfsPlus.efi',
    'EFI\OC\Kexts\Lilu.kext\Contents\MacOS\Lilu',
    'EFI\OC\Kexts\VoodooHDA_BL.kext\Contents\MacOS\VoodooHDA_BL'
)
$falta = @()
foreach ($c in $checks) { if (-not (Test-Path (Join-Path $mount $c))) { $falta += $c } }
$a = (Get-Item (Join-Path $src 'OC\OpenCore.efi')).Length
$b = (Get-Item (Join-Path $mount 'EFI\OC\OpenCore.efi')).Length
if (($falta.Count -gt 0) -or ($a -ne $b)) {
    Write-Host 'ERROR: la verificacion fallo.'
    if ($falta.Count -gt 0) { $falta | ForEach-Object { Write-Host ('   falta: ' + $_) } }
    if ($a -ne $b) { Write-Host ('   OpenCore.efi distinto (' + $a + ' vs ' + $b + ')') }
    Desmontar $apfs.DiskNumber $esp.PartitionNumber $mount
    Pausa 1
}
Write-Host '  Verificacion OK: todos los archivos estan en su sitio.'
Write-Host ''

# --- 8) desmontar -----------------------------------------------------
Desmontar $apfs.DiskNumber $esp.PartitionNumber $mount
Write-Host 'Particion EFI desmontada (queda invisible, como debe estar).'
Write-Host ''
Write-Host '========================================================'
Write-Host ' LISTO: OpenCore ya esta instalado en el disco interno.'
Write-Host '========================================================'
Write-Host ''
Write-Host 'SIGUIENTE:'
Write-Host ' 1) Reinicia el PC (puedes dejar el pendrive puesto).'
Write-Host ' 2) Pulsa F11 y elige la entrada UEFI del disco ST500LT012'
Write-Host '    (aparece como "UEFI: ST500LT012..." o similar).'
Write-Host ' 3) Si aparece el menu de OpenCore y macOS funciona bien,'
Write-Host '    entra al BIOS (Supr) y pon esa entrada como primera.'
Write-Host ''
Pausa 0

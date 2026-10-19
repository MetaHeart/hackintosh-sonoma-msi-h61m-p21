# 07 — Bluetooth: D-Link DBT-122

## Summary

| Item | Value |
|---|---|
| Adapter | D-Link DBT-122 (USB) |
| Chipset | Broadcom **BCM2045** |
| Standard | Bluetooth 1.2 (very old) |
| Status in macOS | The device **is detected over USB**, but **does not work** as Bluetooth. |
| Decision | Shelved. It is not worth any more time. |

## What was tried

The usual kexts for Broadcom USB adapters were added to the EFI:

- `BrcmFirmwareData.kext` 2.7.2
- `BrcmPatchRAM3.kext` 2.7.2
- `BlueToolFixup.kext` 2.7.2

The adapter shows up in the USB tree, but the system does not recognize it as a Bluetooth controller: it cannot be enabled, there are no devices, and there is no working Bluetooth menu.

## Why it does not work

- **BrcmPatchRAM** (and its variants) supports modern Broadcom chipsets such as **BCM2070, BCM20702, BCM20703, BCM43602**, etc.
- The **BCM2045** of the DBT-122 is from the Bluetooth 1.2 generation (early 2000s), much older than those chipsets. Its firmware and its protocol do not fit the modern macOS Bluetooth stack.
- Even if USB enumerates it, macOS does not find a compatible controller and the Bluetooth service does not start.

In short: it is not an EFI configuration problem, it is **hardware that is too old**.

## Current status

- Kexts present in the EFI (they are not in the way, but they do not help for this adapter either).
- The adapter is stored away.
- No more time will be invested unless the user wants to change hardware.

## If real Bluetooth is ever wanted

Recommended options, from simplest to most complete:

### 1. Modern and compatible USB Bluetooth dongle/adapter

Look for one based on **Broadcom BCM20702**, for example:

- IOGEAR GBU521
- ASUS USB-BT400
- Plugable USB-BT4LE
- CSR 4.0 adapters (CSR8510) usually work too

With a BCM20702, the kexts `BrcmFirmwareData`, `BrcmPatchRAM3` and `BlueToolFixup` already in the EFI are exactly the ones needed. You would only need to:

1. Connect the adapter.
2. Verify that the system recognizes it.
3. Restart if needed.
4. Check in Settings → Bluetooth.

### 2. PCIe Wi-Fi + Bluetooth card

Cards based on **BCM94360** (for example, Fenvi ones) work very well in Hackintosh, but:

- They need antennas and a free PCIe slot.
- They require additional kexts for Wi-Fi on Sonoma (IOSkywalk, IO80211FamilyLegacy).
- It is more work; it only makes sense if you also want Wi-Fi.

## Diagnosis (in case it is revisited)

```bash
# Does the adapter show up in USB?
system_profiler SPUSBDataType | grep -A 12 -i "D-Link\|Bluetooth"

# What does macOS report about Bluetooth?
system_profiler SPBluetoothDataType

# Driver status in IORegistry
ioreg -l | grep -i -E "bluetooth|brcm"

# Loaded Bluetooth kexts
kmutil showloaded | grep -i -E "brcm|bluetool"

# Recent bluetoothd log
log show --predicate 'process == "bluetoothd"' --last 5m --style compact
```

If the adapter appears in USB but `system_profiler SPBluetoothDataType` is empty or says "not available", it confirms that the chipset is not compatible.

## Conclusion

The Bluetooth on this machine is **ruled out with the current hardware**. To have it, you must change the adapter for a compatible one. The rest of the system (Ethernet, audio, graphics) does not depend on it.

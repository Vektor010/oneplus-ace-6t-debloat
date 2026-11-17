# Known Issues & Troubleshooting

This document lists known edge cases, platform quirks, and troubleshooting procedures for **AceDebloat**.

---

## 1. ADB Authorization & Connection Quirks

### Issue: `device unauthorized`
* **Symptoms**: The console reports the device is connected, but commands return authorization errors.
* **Root Cause**: The ADB RSA key fingerprint has not been accepted on the smartphone.
* **Resolution**: 
  1. Unlock the phone screen.
  2. In the pop-up dialog *"Allow USB debugging?"*, check *"Always allow from this computer"*.
  3. Tap **Allow**.
  4. Press Enter in the script console to retry.

---

## 2. Windows Driver & Port Detection

### Issue: Device not listed in `adb devices`
* **Symptoms**: Phone is connected via USB cable, but the console reports no devices found.
* **Troubleshooting**:
  1. **USB Mode**: Ensure the USB connection mode in the Android notification shade is set to **File Transfer** (MTP), not "Charging only".
  2. **Driver Installation**:
     - Press `Win + X` ➔ **Device Manager**.
     - Look for an unknown device or an item with a yellow exclamation point (`OnePlus` or `ADB Interface`).
     - Right-click ➔ **Update driver** ➔ **Browse my computer** ➔ **Let me pick from a list** ➔ **Have Disk...** ➔ Select `Drivers\usb_driver\android_winusb.inf` ➔ choose **Android ADB Interface**.
  3. **Cable/Port**: Use a direct USB port on the motherboard/chassis rather than an unpowered USB hub.

---

## 3. Post-OTA Update Behavior

### Issue: Some bloatware apps reappear after a major OS update
* **Root Cause**: When ColorOS applies a major Android system update (e.g. Android 16 to 17), the OS package manager may re-register default system applications.
* **Resolution**: Simply reconnect the smartphone to the PC and run `Run_Debloat.bat` (Option `[1]`). The profile will be reapplied in ~20 seconds. User data and settings remain completely intact.

---

## 4. Multi-Device Collision (Emulators)

### Issue: `error: more than one device/emulator`
* **Symptoms**: Running BlueStacks, LDPlayer, or Android Studio emulators simultaneously with a physical phone causes ADB collisions.
* **Mitigation**: AceDebloat v4.1+ automatically discovers and isolates the physical hardware serial number (`$Global:TargetDeviceSerial`) and routes all ADB calls through `-s <serial>`. If conflicts persist, close any running Android emulators.

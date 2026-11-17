# Architecture Decision Records (ADRs)

This document records key architectural and design decisions for **AceDebloat**, including the context, rationale, and consequences of each choice.

---

## ADR 001: Hybrid Deactivation (`pm suspend` + AppOps) vs. Destructive `pm uninstall`

### Status: Accepted
### Context:
Users seeking to debloat Android often resort to `pm uninstall -k --user 0 <package>`. In modern ColorOS (14, 15, 16, and 17), vendor-protected services such as `com.heytap.market` and `com.heytap.browser` reject uninstallation with `DELETE_FAILED_INTERNAL_ERROR`. Furthermore, running `pm disable-user --user 0` on protected packages results in a silent reversion to `default` state (`enabled=0`).

### Decision:
1. For standard system apps, use `pm disable-user --user 0`.
2. For protected vendor services, use `pm suspend --user 0` combined with **AppOps Hardening** (`cmd appops set <pkg> RUN_IN_BACKGROUND ignore`, `BOOT_COMPLETED ignore`, `POST_NOTIFICATION ignore`).

### Consequences:
- **Pros**: 100% success rate without root; zero risk of system partition corruption; zero bootloop risk; apps cannot wake up or consume battery.
- **Cons**: Package remains physically present in system partition (negligible disk consumption).

---

## ADR 002: Decoupling Package Installer via `com.oplus.appdetail`

### Status: Accepted
### Context:
ColorOS CN routes `.apk` installation dialogs through `com.oplus.appdetail` (Secure App Installation), which triggers Chinese account password prompts, cloud scanning delays, and marketing prompts to redirect to HeyTap Market.

### Decision:
Disable `com.oplus.appdetail` via `pm disable-user --user 0` and set system properties `install_non_market_apps = 1` and `package_verifier_enable = 0`.

### Consequences:
- **Pros**: Direct, instantaneous Android Package Installer dialog without account requirements or telemetry.
- **Cons**: Users must exercise normal discretion when downloading APK files from the internet.

---

## ADR 003: Strict Hardware & Firmware Lock (`PLR110_CN01`)

### Status: Accepted
### Context:
Debloat scripts shared across internet forums are frequently executed blindly on different models (e.g. OnePlus 12, Realme GT, Oppo Find) or global firmwares, risking unexpected feature regressions.

### Decision:
Mandate runtime verification of `ro.product.model == PLR110` and `ro.build.display.id` containing `CN01`.

### Consequences:
- **Pros**: 100% deterministic testing; zero collateral damage on unintended hardware.
- **Cons**: Users with different devices cannot run the script without intentionally adapting the database.

---

## ADR 004: Zero-Dependency Portable Distribution

### Status: Accepted
### Context:
Novice users frequently fail at setting up Android platform tools, configuring Windows PATH environment variables, or resolving driver signature issues in Device Manager.

### Decision:
Distribute the toolkit as a self-contained release zip (`OnePlus_Ace6T_Debloat_Tool.zip`) containing:
1. Official Google `platform-tools` (ADB binaries).
2. Signed Google WinUSB drivers (`Drivers/usb_driver`).
3. Single-click batch launcher (`Run_Debloat.bat`).

### Consequences:
- **Pros**: Download, extract, and run in 30 seconds with 0 external installations.
- **Cons**: Release archive size is ~12.7 MB instead of a bare few-kilobyte script.

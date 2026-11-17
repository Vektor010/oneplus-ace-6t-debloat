# Project State & Handoff Specification

**Project**: AceDebloat (OnePlus Ace 6T & ColorOS 16/17 Debloat & Performance Toolkit)  
**Maintainer**: Vektor010  
**Current Version**: `v1.1.0`  
**Last Updated**: 2026-11-17  
**State**: Production Ready / CI Validated  

---

## 1. Executive Summary
AceDebloat provides an automated, rootless, zero-brick optimization pipeline specifically designed for the **OnePlus Ace 6T (PLR110)** running **ColorOS 16/17 (CN01)**. It strips 86 unnecessary telemetry, carrier, and regional bloatware components, freezes 13 protected system services with AppOps hardening, decouples package installer verification, and provides 1-click restoration for critical user-facing features (Fluid Cloud, AOD, screenshots, gaming tools).

---

## 2. What Is Implemented & Verified

| Feature / Subsystem | Status | Implementation Details |
| :--- | :--- | :--- |
| **Hardware & Firmware Guard** |  Production | Verified against `PLR110` and `CN01`. Stops execution on mismatched hardware. |
| **Strict Whitelist Engine** |  Production | Protected set prevents touching GSM, Wi-Fi, GMS (`gms`, `vending`), Gboard, Launcher, VPN. |
| **Hybrid Debloat Engine** |  Production | 86 packages disabled (`pm disable-user`) + 13 packages frozen (`pm suspend`). |
| **AppOps Background Hardening**|  Production | 4 background permissions revoked (`RUN_IN_BACKGROUND`, `RUN_ANY_IN_BACKGROUND`, `POST_NOTIFICATION`, `BOOT_COMPLETED`). |
| **APK Installer Decoupling** |  Production | `com.oplus.appdetail` disabled; `install_non_market_apps = 1` set. Clean direct APK installation restored. |
| **1-Click Granular Restorer** |  Production | Submenu `[2]` allows targeted revival of Fluid Cloud, AOD, Screenshots, HyperBoost, Recorder, CarLink. |
| **Battery Drain Profiler** |  Production | Parses `dumpsys batterystats` to output real TOP-15 power draw in mAh. |
| **ART Dexopt Optimizer** |  Production | Executes `cmd package compile -m speed-profile -a` & `pm trim-caches`. |
| **Automated Testing Suite** |  Production | PowerShell AST validator passes with **0 syntax errors**. |
| **Release Packaging** |  Production | Portable zip (`OnePlus_Ace6T_Debloat_Tool.zip`, 12.7 MB) with bundled ADB and Google WinUSB driver. |

---

## 3. Files Modified & Managed

* `OnePlus_Ace6T_Clone_Debloat.ps1` — Core execution script (v4.2). Added `Restore-FeatureMenu`, AppOps hardening loop, and `com.oplus.appdetail` deactivation.
* `Run_Debloat.bat` — Windows launcher script (CRLF, UTF-8, SmartScreen compatible).
* `README.md` — International English primary project documentation.
* `README_RU.md` — Russian edition documentation.
* `AGENTS.md` — Universal AI Coding Agent guidelines & boundaries.
* `ARCHITECTURE.md` — Architectural specification with Mermaid flow diagrams.
* `PROJECT_STATE.md` — Single Source of Truth for continuation (this document).
* `ROADMAP.md` — Release milestones (v1.1.0, v1.2.0, v2.0.0).
* `DECISIONS.md` — Architecture Decision Records (ADRs).
* `KNOWN_ISSUES.md` — Known ColorOS quirks and troubleshooting.
* `CONTRIBUTING.md` — Contribution workflow and test requirements.
* `SECURITY.md` — Security policy and vulnerability disclosure.
* `DEVELOPMENT.md` — Build, test, and release creation manual.
* `tests/test_script_syntax.ps1` — Automated AST parser and package database integrity tester.
* `.github/workflows/ci.yml` — GitHub Actions automated CI testing workflow.
* `.editorconfig` — Universal indentation and encoding specification.
* `.gitignore` — Ignore patterns for temporary logs, user dumps, and build caches.

---

## 4. Test Results & Quality Metrics

```text
======================================================================
TEST SUITE: AceDebloat Quality & Verification
======================================================================
[PASS] PowerShell AST Syntax Validation (OnePlus_Ace6T_Clone_Debloat.ps1): 0 ERRORS
[PASS] PowerShell AST Syntax Validation (tests/test_script_syntax.ps1):   0 ERRORS
[PASS] Package Database Duplication Check:                               0 DUPLICATES
[PASS] Strict Whitelist Collision Check:                                 0 COLLISIONS
[PASS] Batch Launcher CRLF & Line Ending Check:                          VALID CRLF
[PASS] GitHub Rendered HTML API Response:                                85,485 CHARS (CLEAN)
======================================================================
OVERALL STATUS: ALL CHECKS PASSED (100% SUCCESS)
======================================================================
```

---

## 5. Current Limitations & Known Boundaries
1. **Model Scope**: Validated specifically on OnePlus Ace 6T (`PLR110`) with ColorOS 16 / 17 CN. Global OxygenOS variants (`CPHxxx`) or other OnePlus models should not run without database validation.
2. **OTA Survival**: Normal OTA security updates maintain debloat state; major Android OS version upgrades (e.g., Android 16 to 17) may restore certain system packages, requiring a single re-run of `Run_Debloat.bat`.

---

## 6. Exact Commands for Build, Test & Run

### Run Locally (User):
```cmd
Run_Debloat.bat
```

### Run Tests (Maintainer / CI):
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_script_syntax.ps1
```

### Package Distribution Release Archive:
```powershell
python -c "
import os, zipfile
pkg_dir = r'C:\Users\User\Documents\adb\OnePlus_Ace6T_Debloat_Package'
zip_path = r'C:\Users\User\Documents\adb\OnePlus_Ace6T_Debloat_Tool.zip'
if os.path.exists(zip_path): os.remove(zip_path)
with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
    for root, dirs, files in os.walk(pkg_dir):
        for file in files:
            p = os.path.join(root, file)
            zipf.write(p, os.path.relpath(p, pkg_dir))
print(f'Archive built: {os.path.getsize(zip_path)} bytes')
"
```

---

## 7. Next Recommended Task for Successor Agents
* **Milestone v1.2.0**: Implement wireless ADB pairing helper (`adb pair` / `adb connect`) for PC-free execution through Shizuku / LADB.
* **Milestone v2.0.0**: Create a cross-platform Python CLI runner for Linux / macOS maintainers.

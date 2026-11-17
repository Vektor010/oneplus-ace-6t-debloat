# AGENTS.md — Universal Guidelines for AI Assistants & Autonomous Agents

This document is the **Single Source of Truth (SSOT)** for any artificial intelligence system, language model, coding agent (ChatGPT, Claude Code, Gemini CLI, GitHub Copilot, Cursor, Windsurf, Aider), or human maintainer working on **AceDebloat**.

---

## 1. Project Overview & Identity
- **Repository**: `Vektor010/oneplus-ace-6t-debloat`
- **Product Name**: **AceDebloat** (OnePlus Ace 6T & ColorOS 16/17 Debloat & Performance Toolkit)
- **Primary Target Device**: OnePlus Ace 6T (`PLR110`)
- **Primary Firmware**: ColorOS 16 CN (`CN01`) & ColorOS 17 CN
- **Execution Architecture**: Non-destructive, zero-root Android Debug Bridge (ADB) automation
- **Core Engine**: PowerShell 5.1+ (`OnePlus_Ace6T_Clone_Debloat.ps1`) wrapped by Windows Batch (`Run_Debloat.bat`)

---

## 2. Inviolable Safety Boundaries (Hard Rules)
Any AI modifying this codebase **must** adhere to the following constraints without exception:

1. **Zero-Brick Architecture (Rootless User-Space Only)**:
   - Never write commands modifying system partitions (`/system`, `/vendor`, `/product`, `remount`, `dm-verity`).
   - All package actions are restricted to current user context: `--user 0`.
2. **Strict Whitelist Inviolability**:
   - The following components must **never** be added to disable or suspend lists:
     - Core OS & Framework: `android`, `com.android.systemui`, `com.android.settings`
     - Telephony & Connectivity: `com.android.phone`, `com.android.server.telecom`, SIM/eSIM stacks, Wi-Fi daemons
     - Primary IME Keyboard: active input methods (e.g. `com.google.android.inputmethod.latin` / Gboard)
     - Primary System Launcher: default home screen launcher
     - Google Play Framework: `com.google.android.gms` (GMS), `com.android.vending` (Play Store)
     - Core User VPN: `com.happproxy`
3. **Evidence Before Assertions**:
   - Never claim a package is safe or dangerous without verifying its flags via `adb shell dumpsys package <package_name>`.
4. **Encoding & Line Ending Discipline**:
   - `.ps1` and `.bat` files: **CRLF** line endings, pure **UTF-8 without BOM**.
   - `.md`, `.yml`, `.json`: **LF** line endings, pure **UTF-8 without BOM**.
   - Always validate PowerShell syntax with `[System.Management.Automation.Language.Parser]::ParseFile()` before committing.

---

## 3. ColorOS Package Management Rules

### Hybrid Deactivation Architecture:
- **Category A (Unprotected System Apps - 86 packages)**:
  - Command: `pm disable-user --user 0 <package>`
  - Result: Package enters `COMPONENT_ENABLED_STATE_DISABLED_USER` (`enabled=2`).
- **Category B (Protected System Apps - 13 packages)**:
  - Examples: `com.heytap.market`, `com.heytap.browser`, `com.coloros.securityguard`, `com.opos.ads`.
  - Condition: ColorOS blocks `pm disable-user` on these packages.
  - Solution: Use `pm suspend --user 0 <package>` combined with **AppOps Hardening**:
    ```powershell
    cmd appops set <package> RUN_IN_BACKGROUND ignore
    cmd appops set <package> RUN_ANY_IN_BACKGROUND ignore
    cmd appops set <package> POST_NOTIFICATION ignore
    cmd appops set <package> BOOT_COMPLETED ignore
    ```
- **Category C (Package Installer Decoupling)**:
  - `com.oplus.appdetail` must be disabled (`pm disable-user`) to prevent ColorOS from redirecting `.apk` installs into the Chinese App Market.
  - System flags `install_non_market_apps = 1` and `package_verifier_enable = 0` must be set in Android settings.

---

## 4. Universal Documentation Map
All AI coding agents (ChatGPT, Claude Code, Gemini, Copilot, Cursor, Windsurf) and human contributors must refer to documentation in `docs/`:

- **Architecture & Design**: [`docs/architecture/ARCHITECTURE.md`](docs/architecture/ARCHITECTURE.md)
- **Architecture Decision Records (ADRs)**: [`docs/architecture/DECISIONS.md`](docs/architecture/DECISIONS.md)
- **Current Project State (SSOT)**: [`docs/project/PROJECT_STATE.md`](docs/project/ROADMAP.md)
- **Public Roadmap**: [`docs/project/ROADMAP.md`](docs/project/ROADMAP.md)
- **Changelog**: [`docs/project/CHANGELOG.md`](docs/project/CHANGELOG.md)
- **Contribution Guidelines**: [`docs/development/CONTRIBUTING.md`](docs/development/CONTRIBUTING.md)
- **Development & Packaging**: [`docs/development/DEVELOPMENT.md`](docs/development/DEVELOPMENT.md)
- **Known Issues & FAQ**: [`docs/guides/KNOWN_ISSUES.md`](docs/guides/KNOWN_ISSUES.md)
- **Support & Community**: [`docs/guides/SUPPORT.md`](docs/guides/SUPPORT.md)
- **Security Policy**: [`docs/security/SECURITY.md`](docs/security/SECURITY.md)

## 5. Documentation Synchronization Protocol
Whenever code or package databases are modified:
1. Update `OnePlus_Ace6T_Clone_Debloat.ps1` package arrays.
2. Update `README.md` (English) and `README_RU.md` (Russian).
3. Update `PROJECT_STATE.md` with exact metrics and test results.
4. Update `CHANGELOG.md` under `[Unreleased]` or the new version tag.
5. Run `tests/test_script_syntax.ps1` to verify AST validity.

---

## 6. Build & Packaging Instructions
- Distribution Archive: `OnePlus_Ace6T_Debloat_Tool.zip`
- Source folder: `OnePlus_Ace6T_Debloat_Package/`
- Archive must contain:
  - `platform-tools/` (portable `adb.exe`, `AdbWinApi.dll`, `AdbWinUsbApi.dll`)
  - `Drivers/usb_driver/` (official Google WinUSB driver)
  - `OnePlus_Ace6T_Clone_Debloat.ps1`
  - `Run_Debloat.bat`
  - `ИНСТРУКЦИЯ_ДЛЯ_НОВИЧКОВ.txt`
  - `README.md`
  - `LICENSE`

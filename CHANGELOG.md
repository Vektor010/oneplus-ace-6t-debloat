# Changelog

All notable changes to the **AceDebloat (OnePlus Ace 6T & ColorOS 16/17 Toolkit)** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.1.0] - 2026-11-17

### Added
- **1-Click Granular Feature Restorer (`Restore-FeatureMenu`)**:
  - Interactive restoration submenu directly in `Run_Debloat.bat`:
    - `[1]` «Остров» (Fluid Cloud / Dynamic Island notification capsule)
    - `[2]` Always-On Display (AOD)
    - `[3]` 3-finger screenshots & native screen recorder
    - `[4]` Smart Sidebar (ColorOS edge panel)
    - `[5]` Game Toolkit (HyperBoost gaming engine)
    - `[6]` Native Sound Recorder & Compass
    - `[7]` CarLink & OCar connected vehicle services
    - `[8]` HeyTap Browser & App Market unfreeze
- **AppOps Background Hardening**:
  - Multi-tier background suppression for suspended services:
    - `RUN_IN_BACKGROUND ignore`
    - `RUN_ANY_IN_BACKGROUND ignore`
    - `POST_NOTIFICATION ignore`
    - `BOOT_COMPLETED ignore`
  - Guarantees packages cannot wake up or consume battery even after ColorOS OTA updates.
- **Package Installer Decoupling**:
  - Added `com.oplus.appdetail` to disabled database to eliminate Chinese password prompts and restore direct native Android APK installation.
  - Automatic `install_non_market_apps = 1` and `package_verifier_enable = 0` configuration.
- **Safe App Acquisition Guide**:
  - Direct verified links to official Google Play Store (APKMirror), RuStore, Aurora Store, and official banking domains.
- **Automated CI/CD Pipeline**:
  - GitHub Actions workflow testing PowerShell AST syntax, strict whitelist integrity, and package count.

### Changed
- Re-architected console UI with clean, modern Russian language (eliminated robotic translation calques).
- Optimized release archive to 12.7 MB including zero-config portable ADB and official Google WinUSB drivers.

---

## [1.0.0] - 2026-11-16

### Initial Release
- **Hardware Lock**: Strict `PLR110` model and `CN01` regional firmware validation.
- **Core Debloat Engine**:
  - 82 bloatware packages disabled via `pm disable-user --user 0`.
  - 13 system services frozen via `pm suspend --user 0`.
- **Safety Whitelist**: Strict protection for GMS, Gboard, default launcher, telephony, Wi-Fi, and VPN (`com.happproxy`).
- **Battery Drain Profiler**: Native parser for `dumpsys batterystats` reporting TOP-15 app consumption in mAh.
- **System Optimization**: Automated `pm trim-caches` and ART Dexopt compilation (`cmd package compile -m speed-profile -a`).
- **One-Click Rollback**: 100% reversible restoration via user-level ADB calls.

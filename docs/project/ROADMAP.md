# Project Roadmap

This document outlines planned milestones, technical objectives, and future feature implementations for **AceDebloat**.

---

## 🎯 Release Milestones

### [v1.0.0] - Foundation Release (Completed)
- [x] Initial hardware & firmware lock for OnePlus Ace 6T (`PLR110_CN01`).
- [x] Strict whitelist protection (GMS, telephony, default launcher, Gboard, VPN).
- [x] 82 disabled packages via `pm disable-user`.
- [x] 13 frozen system packages via `pm suspend`.
- [x] Battery drain analyzer (real mAh extraction from `dumpsys batterystats`).
- [x] 1-click full rollback mechanism.

### [v1.1.0] - Hardening & Granular Control (Completed)
- [x] **1-Click Granular Feature Restorer** (Fluid Cloud, AOD, screenshots, HyperBoost, recorder, vehicle services).
- [x] **AppOps Background Hardening** (revoking background execution, notifications, and boot completion from suspended packages).
- [x] **APK Installer Decoupling** (disabling `com.oplus.appdetail` to eliminate Chinese security prompts and restore native Android installation).
- [x] **Safe App Acquisition Guide** (direct links to verified Google Play Store APKMirror, RuStore, Aurora Store).
- [x] Standardized CI/CD pipeline and automated PowerShell AST test suite.

### [v1.2.0] - Usability & Wireless Execution (Planned)
- [ ] **Wireless ADB Companion**: Automated QR / Pairing Code workflow (`adb pair` / `adb connect`) for PC-free debugging.
- [ ] **Dynamic Package Inventory**: Real-time detection of newly introduced vendor packages during OTA incremental updates.
- [ ] **Automated Backup Exporter**: 1-click JSON export of exact package states before and after optimization.

### [v2.0.0] - ColorOS 17 & Multi-Platform Engine (Future)
- [ ] Full compatibility validation for **ColorOS 17** (Android 17).
- [ ] **Cross-Platform CLI Engine**: Python-based runner for native Linux, macOS, and Termux environments.
- [ ] **Shizuku / Canta Integration**: Direct on-device debloat without requiring a secondary PC.

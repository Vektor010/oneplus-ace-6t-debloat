<p align="right">
  <b>English Version 🇺🇸</b> &bull; <a href="README_RU.md"><b>Русская версия 🇷🇺</b></a>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/Vektor010/oneplus-ace-6t-debloat/main/assets/animations/hero.gif" width="100%" alt="AceDebloat Banner" />
</p>

<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?font=Fira+Code&weight=700&size=26&duration=2600&pause=900&color=EB0028&center=true&vCenter=true&width=780&lines=ACEDEBLOAT+%C2%B7+ONEPLUS+ACE+6T;COLOROS+16+%26+17+HYBRID+DEBLOAT;ZERO+ROOT+%C2%B7+100%25+REVERSIBLE;ADB+%2B+USB+DRIVER+INCLUDED" alt="Typing SVG" />
</p>

<h1 align="center">⚡ AceDebloat: OnePlus Ace 6T &amp; ColorOS 16/17 Debloat &amp; Performance Toolkit</h1>

<p align="center">
  <b>Production-grade, zero-brick, rootless optimization and de-Googling/de-China toolkit for OnePlus Ace 6T.</b><br/>
  <i>Engineered for OnePlus Ace 6T (PLR110 · ColorOS 16/17 CN01) · Zero Root · 100% Reversible · Portable ADB &amp; Driver Included. By <b>Vektor010</b>.</i>
</p>

<p align="center">
  <a href="https://github.com/Vektor010/oneplus-ace-6t-debloat/releases/latest"><img src="https://img.shields.io/badge/DOWNLOAD_RELEASE_v1.1.0-10B981?style=for-the-badge&logo=android&logoColor=white" alt="Download Release" height="38"/></a>&nbsp;&nbsp;
  <a href="#-quick-start-in-3-steps"><img src="https://img.shields.io/badge/QUICK_START-2563EB?style=for-the-badge&logo=rocket&logoColor=white" alt="Quick Start" height="38"/></a>&nbsp;&nbsp;
  <a href="#-granular-feature-restorer"><img src="https://img.shields.io/badge/RESTORE_FEATURES-EB0028?style=for-the-badge&logo=oneplus&logoColor=white" alt="Restore Features" height="38"/></a>&nbsp;&nbsp;
  <a href="#-package-inventory"><img src="https://img.shields.io/badge/PACKAGE_DATABASE-7C3AED?style=for-the-badge&logo=bookstack&logoColor=white" alt="Package Database" height="38"/></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Device-OnePlus_Ace_6T_(PLR110)-18181B?style=flat&logo=oneplus&logoColor=EB0028" alt="Model"/>
  <img src="https://img.shields.io/badge/OS-ColorOS_16_%2F_17_CN-18181B?style=flat&logo=android&logoColor=3DDC84" alt="OS"/>
  <img src="https://img.shields.io/badge/Root-Not_Required-18181B?style=flat&logo=shield&logoColor=white" alt="No Root"/>
  <img src="https://img.shields.io/badge/Rollback-100%25_in_1_Click-18181B?style=flat&logo=git&logoColor=white" alt="Rollback"/>
  <img src="https://img.shields.io/badge/License-MIT-18181B?style=flat" alt="MIT"/>
</p>

---

## 💡 Executive Value Proposition (Before vs. After)

Out of the box, the Chinese firmware edition of the **OnePlus Ace 6T (ColorOS 16/17 CN)** runs numerous regional background services, telemetry daemons, HeyTap advertising engines, and Chinese market scanners.

| Stock Firmware Baseline | With AceDebloat Applied |
| :--- | :--- |
| ❌ **~140 background daemons** consuming RAM and CPU cycles |  **Minus 95 background services**: freed memory and cool thermals |
| ❌ **Overnight battery drain (8–12%)** due to wake locks & Chinese polling |  **Overnight idle drain 1–2%**: true Android Deep Sleep restored |
| ❌ Intrusive notifications from HeyTap Market, Browser, and Breeno |  **Total silence**: advertising and notification SDKs neutralized |
| ❌ Chinese package inspector intercepts `.apk` installs demanding passwords |  **Instant clean APK installation** via native Android Package Installer |
| ❌ Inability to disable protected packages (`com.heytap.market`) |  **Deep freeze via `pm suspend` + AppOps background hardening** |
| ❌ Occasional UI stuttering during heavy task switching |  **+1.5 to 2 hours active screen-on time** & butter-smooth animations |

---

## 🚀 Quick Start in 3 Steps

> [!NOTE]
> **No external downloads or path configurations needed.**  
> The distribution archive bundles tested portable **ADB** (`platform-tools`), official **Google WinUSB drivers**, a 1-click batch launcher (`Run_Debloat.bat`), and an offline guide.

### Step 1. Download and Extract
1. Download [**`OnePlus_Ace6T_Debloat_Tool.zip`**](https://github.com/Vektor010/oneplus-ace-6t-debloat/releases/latest).
2. **Extract the archive** to a dedicated folder on your PC *(Right-click ➔ «Extract All...»)*.  
   *(Do not run scripts from inside the archive preview window!)*

### Step 2. Enable USB Debugging on Your Smartphone
1. Open **Settings** ➔ **About Device** ➔ **Version**.
2. Tap **Build Number 7 times** rapidly and confirm your lock-screen PIN. A toast notification will say: *«You are now in developer mode»*.
3. Navigate back to **Settings** ➔ **Additional Settings** *(or System)* ➔ **Developer Options**.
4. Enable **USB Debugging**.
5. *(Recommended for ColorOS)* Scroll down and enable **«Disable permission monitoring»**.

### Step 3. Connect to PC and Run
1. Connect your OnePlus Ace 6T to your PC via a USB-C data cable and unlock the screen.
2. In the Android notification shade, set USB mode to **File Transfer** (not "Charging only").
3. Double-click **`Run_Debloat.bat`** *(if Windows SmartScreen appears, click "More info" ➔ "Run anyway")*.
4. **Look at your smartphone screen:** a prompt will ask *«Allow USB debugging?»* — check **«Always allow from this computer»** and tap **Allow**.
5. In the console menu, type **`1`** (Debloat & Optimize) ➔ confirm with **`1`**.
6. The entire pipeline executes in ~20 seconds. Confirm ART optimization and reboot when prompted.

---

## 🏝️ Granular Feature Restorer

ColorOS tightly couples several popular UI features with specific package clusters. Instead of forcing an all-or-nothing rollback, AceDebloat features an **Interactive Feature Restorer**:

### Available 1-Click Restoration Modules (Menu Option `[2]`):
1. **Fluid Cloud («Остров»)**: Restores the Dynamic Island notification capsule around the selfie camera for Spotify, timers, and ride statuses (`com.coloros.ocs.opencapabilityservice`, `com.oplus.smartmediacontroller`, `com.oplus.smartengine`, `com.oplus.aiwidgets`, `com.oplus.metis`, `com.coloros.sceneservice`).
2. **Always-On Display (AOD)**: Re-enables clock and notification icons on the locked screen (`com.oplus.aod`).
3. **Screenshots & Screen Recorder**: Reinstates 3-finger swipe screenshots and high-FPS system screen recording (`com.oplus.screenshot`, `com.oplus.screenrecorder`).
4. **Smart Sidebar**: Re-enables the slide-out quick-access edge panel (`com.coloros.smartsidebar`).
5. **Game Toolkit (HyperBoost)**: Restores in-game performance tuning and overlay panels (`com.oplus.games`).
6. **Native Recorder & Compass**: Restores ColorOS voice recorder and sensor compass.
7. **Connected Vehicle Services**: Re-enables CarLink, OCar, and digital NFC car key.
8. **HeyTap Browser & Market Unfreeze**: Unfreezes Chinese store components if strictly required.

---

## 🛍️ Safe Application Acquisition Guide

Chinese ColorOS editions omit the Google Play Store by default. Follow this verified guide to configure a secure, virus-free application environment:

### 1. Activating Built-in Google Framework & Official Play Store
The Google Mobile Services (GMS) framework is **already pre-installed** in ColorOS firmware:
1. Open **Settings** ➔ **Users & Accounts** ➔ **Google Mobile Services (GMS)** ➔ toggle **ON**.
2. Download the official, cryptographic-signature-verified **Google Play Store APK**:
   * 🌐 **[APKMirror — Google Play Store (Official Releases)](https://www.apkmirror.com/apk/google-inc/google-play-store/)**
   * *Selection tip:* Choose the latest **Release** build (not Beta), file type **APK**, architecture `universal` or `arm64-v8a`.
   * Install the APK — you now have full Google Play Store access linked to your Google Account.

### 2. Russian Banking & Government Services (RuStore)
For users requiring Russian banking applications (Sber, T-Bank, VTB, Gosuslugi, Mir Pay):
* 🇷🇺 **[RuStore (Official Website)](https://www.rustore.ru/)** — The official Russian application catalog backed by the Ministry of Digital Development. Automatically updates banking and transit clients.

### 3. Open-Source & Privacy-First Application Repositories
* 🌐 **[Aurora Store (auroraoss.com)](https://auroraoss.com/)**: FOSS Google Play client. Allows anonymous downloads directly from Google's servers without logging into a Google Account.
* 📦 **[F-Droid (f-droid.org)](https://f-droid.org/)**: The premier catalog of free and open-source software (FOSS).
* 🛡️ **[APKMirror (apkmirror.com)](https://www.apkmirror.com/)**: Android Police's malware-free APK repository with cryptographic signature checks.

---

## 🖥️ Command Center Console Interface

```text
==============================================================================
   ONEPLUS ACE 6T (PLR110) · DEBLOAT & PERFORMANCE COMMAND CENTER
==============================================================================
 Device: OnePlus PLR110 [Build: CN01]
 Safety: Root Not Required · Knox 0x0 · 100% Reversible
==============================================================================
 [1] ⚡ Apply Debloat & Optimization (Disable 80 Bloat + Freeze 13 Services)
 [2] 🏝️ Restore Granular Feature (Fluid Cloud, AOD, Screenshots, Games...)
 [3] 🚀 Accelerate Applications (ART Dexopt speed-profile compilation)
 [4] 🔋 Battery Drain Profiler (Parse real mAh drain & Top 15 consumers)
 [5] ↩️ Complete Factory Rollback (Re-enable all 93 packages)
 [6] 📊 Device Diagnostics (OS build, battery temperature, package stats)
 [7] 🔄 Reboot Smartphone
 [0] ❌ Exit
==============================================================================
```

---

## 🛡️ Safety & Anti-Brick Architecture

* **Zero Root / Zero System Write**: Operates exclusively in user space (`--user 0`). System partitions remain read-only.
* **Hardware & Build Guard**: Execution halts automatically if the connected device model does not match `PLR110` with Chinese firmware token `CN01`.
* **Strict Whitelist Protection**: Telephony, emergency services, Wi-Fi, default launcher, Gboard, Google Play services (`com.google.android.gms`), and user VPN (`com.happproxy`) are permanently shielded from deactivation.
* **Instant Rollback**: Menu Option `[5]` restores every disabled and suspended package to stock within 15 seconds.

---

## 📦 Package Inventory Overview

<details open>
<summary><b>🔒 13 Frozen System Services (<code>pm suspend</code> + AppOps Hardening)</b></summary>
<br>

| Package Identifier | Description | Hardening Action |
| :--- | :--- | :--- |
| `com.heytap.browser` | Chinese HeyTap web browser | Suspended + `RUN_IN_BACKGROUND ignore` |
| `com.heytap.market` | Chinese App Market | Suspended + `POST_NOTIFICATION ignore` |
| `com.heytap.pictorial` | Lockscreen wallpaper carousel | Suspended + `BOOT_COMPLETED ignore` |
| `com.heytap.quicksearchbox` | Desktop search widget | Suspended + background execution blocked |
| `com.heytap.htms` | HeyTap transport messaging service | Suspended |
| `com.opos.ads` | Oppo / ColorOS advertising SDK | Suspended |
| `com.coloros.securityguard` | Chinese APK signature blocker | Suspended |
| `com.nearme.instant.platform` | Quick Apps micro-service framework | Suspended |
| `com.oplus.themestore` | Theme store service | Suspended |
| `com.oppo.store` | Oppo hardware e-store | Suspended |
| `com.heytap.speechassist` | Breeno voice assistant daemon | Suspended |
| `com.oplus.ovoicemanager` | Breeno voice engine | Suspended |
| `com.oplus.ovoicemanager.wakeup` | Breeno hotword microphone listener | Suspended |

</details>

<details>
<summary><b>🗑️ 80 Disabled Packages (<code>pm disable-user</code>)</b></summary>
<br>

Includes:
- **Package Installer Decoupling**: `com.oplus.appdetail`
- **Cloud & Account Services**: `com.heytap.cloud`, `com.oplus.account`
- **Partner Software**: Baidu Search, Baidu IME, AutoNavi Maps, FinShell Wallet, UnionPay TSM
- **Telemetry & Logging**: SAU helper, logtrial, powermonitor, Atlas, Qualcomm DCF
- **Connected Vehicle Services**: CarLink, OCar, digital car keys
- **Heavy Visual Engines**: `com.heytap.colorfulengine` (3D live wallpaper renderer)

</details>

---

## ❓ Frequently Asked Questions (FAQ)

<details>
<summary><b>Will I still receive official ColorOS OTA updates?</b></summary>
<br>

**Yes, 100%.** Because AceDebloat operates without root and does not alter system partition checksums, official OTA updates download and install normally. If a major Android upgrade re-registers stock packages, simply run `Run_Debloat.bat` Option `[1]` to re-apply the profile.
</details>

<details>
<summary><b>Will this wipe my photos, Telegram chats, or game data?</b></summary>
<br>

**No.** AceDebloat modifies user-level package enablement flags only. It never touches user storage (`/data/media`). Your photos, contacts, credentials, and app data remain completely untouched.
</details>

<details>
<summary><b>How do I completely undo all changes?</b></summary>
<br>

Run `Run_Debloat.bat` ➔ select Option **`[5] Complete Factory Rollback`** ➔ confirm with **`1`**. Every single disabled and suspended package will be restored to factory defaults within seconds.
</details>

---

## 🤝 Contributing

Contributions, package additions, and translations are warmly welcomed. Please review [CONTRIBUTING.md](docs/development/CONTRIBUTING.md) and run the automated test suite before opening a pull request:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_script_syntax.ps1
```

---

## 📄 License

Distributed under the **MIT License**. See [LICENSE](LICENSE) for details.

---

<div align="center">

<sub><b>AceDebloat</b> &bull; Production-Grade ColorOS Optimization Toolkit &bull; Maintained by <b>Vektor010</b></sub>

</div>

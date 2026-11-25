<p align="right">
  <b>English Version 🇺🇸</b> &bull; <a href="README_RU.md"><b>Русская версия 🇷🇺</b></a>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/Vektor010/oneplus-ace-6t-debloat/main/assets/animations/hero.gif" width="100%" alt="AceDebloat Banner" />
</p>

<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?font=Fira+Code&weight=700&size=26&duration=2600&pause=900&color=EB0028&center=true&vCenter=true&width=780&lines=ACEDEBLOAT+%C2%B7+ONEPLUS+ACE+6T;COLOROS+16+%26+17+HYBRID+DEBLOAT;ZERO+ROOT+%C2%B7+ZERO+APP+DELETION;100%25+REVERSIBLE+IN+1+CLICK" alt="Typing SVG" />
</p>

<h1 align="center">⚡ AceDebloat: OnePlus Ace 6T &amp; ColorOS 16/17 Debloat &amp; Performance Toolkit</h1>

<p align="center">
  <b>Rootless, non-destructive optimization and Chinese bloatware deactivation toolkit for OnePlus Ace 6T.</b><br/>
  <i>Built for OnePlus Ace 6T (PLR110 · ColorOS 16/17 CN) · Bilingual Console UI (EN/RU) · Portable ADB &amp; Google USB Driver Included. By <b>Vektor010</b>.</i>
</p>

<p align="center">
  <a href="https://github.com/Vektor010/oneplus-ace-6t-debloat/releases/latest"><img src="https://img.shields.io/badge/DOWNLOAD_ARCHIVE-10B981?style=for-the-badge&logo=android&logoColor=white" alt="Download Release" height="38"/></a>&nbsp;&nbsp;
  <a href="#-clarification-frozen-vs-disabled-vs-deleted"><img src="https://img.shields.io/badge/WHAT_GETS_FROZEN%3F-F59E0B?style=for-the-badge&logo=shield&logoColor=white" alt="Clarifications" height="38"/></a>&nbsp;&nbsp;
  <a href="#-quick-start-in-3-steps"><img src="https://img.shields.io/badge/QUICK_START-2563EB?style=for-the-badge&logo=rocket&logoColor=white" alt="Quick Start" height="38"/></a>&nbsp;&nbsp;
  <a href="#-complete-package-inventory-all-95-packages"><img src="https://img.shields.io/badge/ALL_95_PACKAGES-7C3AED?style=for-the-badge&logo=bookstack&logoColor=white" alt="All 95 Packages" height="38"/></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Device-OnePlus_Ace_6T_(PLR110)-18181B?style=flat&logo=oneplus&logoColor=EB0028" alt="Model"/>
  <img src="https://img.shields.io/badge/OS-ColorOS_16_%2F_17_CN-18181B?style=flat&logo=android&logoColor=3DDC84" alt="OS"/>
  <img src="https://img.shields.io/badge/Console_UI-English_%2B_Russian-18181B?style=flat" alt="Bilingual"/>
  <img src="https://img.shields.io/badge/Deletion-ZERO_(Non--Destructive)-18181B?style=flat" alt="No Deletion"/>
  <img src="https://img.shields.io/badge/License-MIT-18181B?style=flat" alt="MIT"/>
</p>

---

## 🛡️ Clarification: Frozen vs. Disabled vs. Deleted

> [!IMPORTANT]
> **NOTHING IS DELETED FROM YOUR PHONE (`pm uninstall` is NEVER used).**  
> All system APK binaries remain safely untouched inside your read-only `/system` partition. Every single change runs purely in user space (`--user 0`) and is **100% reversible in 1 click** (Menu Option `[5]`) or via a standard factory reset.

Here is the exact technical difference between the two methods AceDebloat uses on ColorOS:

| Method Used | Count | ADB Commands Executed | Why & How It Works | Reversible? |
| :--- | :---: | :--- | :--- | :--- |
| **1. Disabled** *(User-Space Disable)* | **82** | `pm disable-user --user 0 <pkg>` | Sets `enabled=2` (`DISABLED_USER`). Launcher icons are hidden and background services cannot start. | ✅ **Yes** (`pm enable --user 0 <pkg>`) |
| **2. Frozen** *(Deep Suspend + AppOps)* | **13** | `pm suspend --user 0 <pkg>` + `cmd appops set <pkg> ... ignore` | ColorOS actively blocks `pm disable-user` on vendor-protected apps (`com.heytap.market`, `com.heytap.browser`, `com.opos.ads`, Breeno). `pm suspend` safely places them into Android's **suspended state** (`suspended=true`) while AppOps revokes background wake locks (`RUN_IN_BACKGROUND`, `POST_NOTIFICATION`, `BOOT_COMPLETED`). | ✅ **Yes** (`pm unsuspend` + AppOps reset to `default`) |
| **3. Deleted** *(Uninstall)* | **0** | *(None — Never used)* | Avoids `DELETE_FAILED_INTERNAL_ERROR`, prevents ColorOS settings crashes, and preserves full OTA update compatibility. | N/A |

👉 **Full transparency:** Expand the **[Complete Package Inventory](#-complete-package-inventory-all-95-packages)** below to inspect **every single one of the 82 disabled and 13 frozen packages** by exact package ID and description.

---

## 💡 Before vs. After Optimization

| Stock ColorOS CN Baseline | With AceDebloat Applied |
| :--- | :--- |
| ❌ **~140 background daemons** consuming RAM and CPU cycles | ✅ **95 bloat/telemetry packages deactivated** cleanly |
| ❌ **Overnight battery drain (8–12%)** due to CN wake locks | ✅ **Overnight idle drain 1–2%**: true Android Deep Sleep |
| ❌ Ads and push spam from HeyTap Market, Browser, and Breeno | ✅ **Silent background**: ads & tracking services frozen |
| ❌ Chinese `appdetail` intercepts `.apk` installs demanding passwords | ✅ **Clean direct APK installation** via native Android installer |
| ❌ Fixed Russian-only scripts crash or confuse non-RU users | ✅ **Auto-bilingual Console UI (English + Russian)** + Auto-ADB downloader |

---

## 🚀 Quick Start in 3 Steps

> [!NOTE]
> **Everything works out of the box.**  
> Download [**`OnePlus_Ace6T_Debloat_Tool.zip`**](https://github.com/Vektor010/oneplus-ace-6t-debloat/releases/latest) *(includes portable ADB + Google WinUSB driver)*.  
> *Even if you cloned/downloaded raw source code without `platform-tools`, `Run_Debloat.bat` now offers 1-click automatic download of official Google ADB!*

### Step 1. Extract the Archive
1. Download [**`OnePlus_Ace6T_Debloat_Tool.zip`**](https://github.com/Vektor010/oneplus-ace-6t-debloat/releases/latest).
2. **Extract all files** into a regular folder *(Right-click ➔ "Extract All...")*. Do not run inside the ZIP preview window.

### Step 2. Enable USB Debugging on OnePlus Ace 6T
1. Open **Settings** ➔ **About Device** ➔ **Version**.
2. Tap **Build Number 7 times** and confirm your PIN.
3. Return to **Settings** ➔ **Additional Settings** ➔ **Developer Options**.
4. Enable **USB Debugging** and *(recommended for ColorOS)* **Disable permission monitoring**.

### Step 3. Connect via USB & Run `Run_Debloat.bat`
1. Connect your phone via USB-C and unlock the screen. Set USB notification mode to **File Transfer (MTP)**.
2. Double-click **`Run_Debloat.bat`** *(on Windows SmartScreen, click "More info" ➔ "Run anyway")*.
3. **Look at your phone screen:** check **"Always allow from this computer"** and tap **Allow**.
4. In the console *(auto-selects English or Russian; press **`L`** anytime to switch)*, press **`1`** ➔ confirm with **`1`**.

<details>
<summary><b>Troubleshooting: Phone Not Detected / Driver Setup</b></summary>
<br>

Windows 10/11 includes WinUSB natively. If `adb devices` does not see your phone:
1. Check **This PC** ➔ virtual CD drive `OnePlus Drivers` ➔ run `OnePlus_USB_Drivers_Setup.exe`.
2. Or install the included driver: `Win + X` ➔ **Device Manager** ➔ right-click your unknown `OnePlus` / `ADB Interface` device ➔ **Update driver** ➔ **Browse my computer** ➔ **Let me pick from a list** ➔ **Have Disk...** ➔ select `Drivers/usb_driver/android_winusb.inf` ➔ **Android ADB Interface**.

</details>

---

## 🏝️ Granular Feature Restorer (Menu Option `[2]`)

Want to disable Chinese bloatware but keep specific ColorOS features? You do **not** need a full rollback: run `Run_Debloat.bat` ➔ press **`2`** to restore any feature in 1 second:

1. **Fluid Cloud («Остров»)**: Live notification capsule around the camera cutout (`com.coloros.ocs.opencapabilityservice`, `com.oplus.smartmediacontroller`, `com.oplus.smartengine`, `com.oplus.aiwidgets`, `com.oplus.metis`, `com.coloros.sceneservice`).
2. **Always-On Display (AOD)**: Lockscreen clock (`com.oplus.aod`).
3. **3-Finger Screenshots & Screen Recorder**: (`com.oplus.screenshot`, `com.oplus.screenrecorder`).
4. **Smart Sidebar**: Edge quick-access panel (`com.coloros.smartsidebar`).
5. **Game Toolkit (HyperBoost)**: In-game optimization overlay (`com.oplus.games`).
6. **Native Recorder & Compass**: (`com.coloros.soundrecorder`, `com.coloros.compass2`).
7. **CarLink / OCar / Digital Car Key**: Connected vehicle suite.
8. **HeyTap Browser / App Market / Theme Store**: Cleanly unfreezes AND resets their AppOps permissions.
9. **ColorOS APK Inspector (`appdetail`) & HeyTap Cloud**: Restores ColorOS stock APK verification if desired.

---

## 🛍️ Safe Clean App Setup (Google Play, Aurora Store, RuStore)

1. **Enable Built-in Google Mobile Services (GMS):**  
   **Settings** ➔ **Users & Accounts** ➔ **Google Mobile Services (GMS)** ➔ toggle **ON**.
2. **Install Official Google Play Store APK:**  
   Download the verified release APK (`universal` or `arm64-v8a`) from [**APKMirror — Google Play Store**](https://www.apkmirror.com/apk/google-inc/google-play-store/).
3. **Privacy-First & Open-Source Catalogs:**
   * 🌐 **[Aurora Store](https://auroraoss.com/)** — Open-source anonymous Play Store client.
   * 📦 **[F-Droid](https://f-droid.org/)** — Free and open-source Android software repository.
   * 🇷🇺 **[RuStore](https://www.rustore.ru/)** — Official Russian app catalog (Sber, T-Bank, VTB, Gosuslugi).

---

## 🖥️ Command Center Interface

```text
======================================================================
   ACEDEBLOAT v5.0  |  ONEPLUS ACE 6T (PLR110)  |  COLOROS 16 / 17    
======================================================================
 >>> DEBLOAT & PERFORMANCE COMMAND CENTER
----------------------------------------------------------------------
  Device: OnePlus PLR110 | Build: PLR110_16.0.10.500(CN01) | Android 16
  Safety: Zero Root · Zero System Deletion · 100% Reversible

 [1] Apply Debloat & Optimization (Disable 82 + Freeze 13 Services)
 [2] Restore Specific Feature (Fluid Cloud, AOD, Screenshots, Games...)
 [3] Accelerate Apps (ART Dexopt speed-profile) & Trim Caches
 [4] Battery Drain Profiler (Top-15 Apps in mAh)
 [5] Complete Rollback (Re-enable & Unfreeze all 95 Packages)
 [6] Device Diagnostics (OS Version, Package Stats, Battery)
 [7] Reboot Smartphone
 [L] Сменить язык / Language: EN -> RU
 [0] Exit
```

---

## 📦 Complete Package Inventory (All 95 Packages)

<details>
<summary><b>🔒 13 Frozen Protected Services (<code>pm suspend</code> + AppOps Hardening — Expand to View All 13)</b></summary>
<br>

| Package ID | What It Does | Action Taken |
| :--- | :--- | :--- |
| `com.heytap.pictorial` | Lockscreen wallpaper magazine carousel (heavy battery & data drain) | Frozen (`pm suspend`) + AppOps `ignore` |
| `com.oplus.themestore` | ColorOS Theme Store (paid CN themes & ads) | Frozen (`pm suspend`) + AppOps `ignore` |
| `com.heytap.market` | Chinese App Market (protected against disable-user; frozen safely) | Frozen (`pm suspend`) + AppOps `ignore` |
| `com.coloros.securityguard` | Chinese APK security blocker (interrupts sideloaded APK installs) | Frozen (`pm suspend`) + AppOps `ignore` |
| `com.heytap.speechassist` | Chinese Breeno Voice Assistant UI | Frozen (`pm suspend`) + AppOps `ignore` |
| `com.opos.ads` | Primary OPPO / ColorOS system advertising SDK | Frozen (`pm suspend`) + AppOps `ignore` |
| `com.heytap.browser` | Preinstalled Chinese HeyTap Web Browser (ad-heavy) | Frozen (`pm suspend`) + AppOps `ignore` |
| `com.heytap.quicksearchbox` | Chinese homescreen search bar | Frozen (`pm suspend`) + AppOps `ignore` |
| `com.oppo.store` | OPPO Store China hardware shopping app | Frozen (`pm suspend`) + AppOps `ignore` |
| `com.nearme.instant.platform` | Chinese Quick Apps instant-run platform | Frozen (`pm suspend`) + AppOps `ignore` |
| `com.oplus.ovoicemanager.wakeup` | Always-on microphone hotword listener for Breeno | Frozen (`pm suspend`) + AppOps `ignore` |
| `com.heytap.htms` | HeyTap background push & transport service | Frozen (`pm suspend`) + AppOps `ignore` |
| `com.oplus.ovoicemanager` | Breeno speech recognition engine | Frozen (`pm suspend`) + AppOps `ignore` |

</details>

<details>
<summary><b>⏸️ 82 Disabled Packages (<code>pm disable-user --user 0</code> — Expand to View All 82)</b></summary>
<br>

| Package ID | What It Does | Action Taken |
| :--- | :--- | :--- |
| `com.oplus.appdetail` | Secure App Installation scanner (redirects APKs to Chinese App Market) | Disabled (`pm disable-user`) |
| `com.heytap.cloud` | HeyTap / Oppo Chinese Cloud backup & sync | Disabled (`pm disable-user`) |
| `andes.oplus.documentsreader` | Built-in Andes PDF/Office viewer | Disabled (`pm disable-user`) |
| `com.android.adservices.api` | Android Privacy Sandbox advertising telemetry API | Disabled (`pm disable-user`) |
| `com.android.cellbroadcastreceiver` | Emergency Cell Broadcast alerts | Disabled (`pm disable-user`) |
| `com.android.cts.priv.ctsshim` | Factory Compatibility Test Suite (CTS) shim | Disabled (`pm disable-user`) |
| `com.android.DeviceAsWebcam` | Use smartphone as wired USB webcam for PC | Disabled (`pm disable-user`) |
| `com.android.dynsystem` | Dynamic System Updates (DSU) developer loader | Disabled (`pm disable-user`) |
| `com.android.federatedcompute.services` | On-device federated ML analytics telemetry | Disabled (`pm disable-user`) |
| `com.android.healthconnect.controller` | Android Health Connect fitness aggregator | Disabled (`pm disable-user`) |
| `com.android.hotspot2.osulogin` | Enterprise Wi-Fi Passpoint (Hotspot 2.0) login | Disabled (`pm disable-user`) |
| `com.android.musicfx` | Legacy AOSP MusicFX equalizer | Disabled (`pm disable-user`) |
| `com.android.ondevicepersonalization.services` | On-device ad targeting & personalization | Disabled (`pm disable-user`) |
| `com.android.printspooler` | Android wireless print spooler service | Disabled (`pm disable-user`) |
| `com.android.simappdialog` | Carrier SIM Toolkit popup menu (frequent spam source) | Disabled (`pm disable-user`) |
| `com.android.virtualization.terminal` | Experimental Android Linux terminal VM | Disabled (`pm disable-user`) |
| `com.android.wallpaper.livepicker.overlay` | Live wallpaper picker system overlay | Disabled (`pm disable-user`) |
| `com.autonavi.minimap` | Chinese AutoNavi / Amap navigation maps | Disabled (`pm disable-user`) |
| `com.baidu.input_oppo` | Chinese Baidu IME keyboard (Gboard stays active) | Disabled (`pm disable-user`) |
| `com.baidu.searchbox` | Chinese Baidu Search & web portal | Disabled (`pm disable-user`) |
| `com.coloros.codebook` | Built-in Chinese ColorOS password manager | Disabled (`pm disable-user`) |
| `com.coloros.compass2` | Built-in ColorOS Compass app (restorable via [2]->[6]) | Disabled (`pm disable-user`) |
| `com.coloros.digitalwellbeing` | ColorOS Digital Wellbeing usage tracker | Disabled (`pm disable-user`) |
| `com.coloros.karaoke` | Microphone audio feedback for Chinese karaoke apps | Disabled (`pm disable-user`) |
| `com.coloros.mapcom.frame` | Auxiliary framework for Chinese maps | Disabled (`pm disable-user`) |
| `com.coloros.ocs.opencapabilityservice` | Fluid Cloud ('Island') OCS capability bus (restorable via [2]->[1]) | Disabled (`pm disable-user`) |
| `com.coloros.oshare` | OPPO/OnePlus local OShare file transfer | Disabled (`pm disable-user`) |
| `com.coloros.remoteguardservice` | Chinese RemoteGuard parental control daemon | Disabled (`pm disable-user`) |
| `com.coloros.sceneservice` | Fluid Cloud ('Island') scene scenario processor (restorable via [2]->[1]) | Disabled (`pm disable-user`) |
| `com.coloros.securepay` | Chinese payment security scanner (Alipay/WeChat) | Disabled (`pm disable-user`) |
| `com.coloros.sharescreen` | Remote screen sharing utility | Disabled (`pm disable-user`) |
| `com.coloros.smartlock` | Legacy ColorOS SmartLock service | Disabled (`pm disable-user`) |
| `com.coloros.smartsidebar` | Slide-out Smart Sidebar edge panel (restorable via [2]->[4]) | Disabled (`pm disable-user`) |
| `com.coloros.soundrecorder` | Built-in ColorOS voice recorder (restorable via [2]->[6]) | Disabled (`pm disable-user`) |
| `com.finshell.wallet` | Chinese FinShell Wallet / HeyTap Pay | Disabled (`pm disable-user`) |
| `com.gamma.scan` | Preinstalled Chinese document scanner | Disabled (`pm disable-user`) |
| `com.google.android.gm` | Gmail email client (reinstallable from Play Store) | Disabled (`pm disable-user`) |
| `com.google.android.googlequicksearchbox` | Google Search companion app | Disabled (`pm disable-user`) |
| `com.google.android.projection.gearhead` | Android Auto car projection | Disabled (`pm disable-user`) |
| `com.google.ar.lens` | Google Lens visual search | Disabled (`pm disable-user`) |
| `com.heytap.accessory` | HeyTap Chinese Bluetooth accessory pairing daemon | Disabled (`pm disable-user`) |
| `com.heytap.colorfulengine` | Heavy 3D OpenGL live wallpaper engine (high GPU/RAM drain) | Disabled (`pm disable-user`) |
| `com.heytap.music` | Chinese HeyTap Music streaming app | Disabled (`pm disable-user`) |
| `com.heytap.opluscarlink` | Chinese CarLink car infotainment bridge (restorable via [2]->[7]) | Disabled (`pm disable-user`) |
| `com.heytap.themestore` | HeyTap legacy Theme Store package | Disabled (`pm disable-user`) |
| `com.heytap.vip` | HeyTap VIP loyalty & subscription club | Disabled (`pm disable-user`) |
| `com.heytap.yoli` | Chinese HeyTap Yoli video streaming app | Disabled (`pm disable-user`) |
| `com.microsoftsdk.crossdeviceservicebroker` | Microsoft 'Link to Windows' background broker | Disabled (`pm disable-user`) |
| `com.oplus.account` | Chinese OPPO / HeyTap Cloud account service | Disabled (`pm disable-user`) |
| `com.oplus.aiwidgets` | Fluid Cloud ('Island') AI widgets & cards (restorable via [2]->[1]) | Disabled (`pm disable-user`) |
| `com.oplus.aod` | Always-On Display lockscreen clock (restorable via [2]->[2]) | Disabled (`pm disable-user`) |
| `com.oplus.atlas` | Atlas subsystem diagnostic telemetry | Disabled (`pm disable-user`) |
| `com.oplus.cardigitalkey` | Digital NFC/BLE car key (restorable via [2]->[7]) | Disabled (`pm disable-user`) |
| `com.oplus.consumerIRApp` | IR remote blaster controller app | Disabled (`pm disable-user`) |
| `com.oplus.dfs` | OPPO Distributed File System cross-device sync | Disabled (`pm disable-user`) |
| `com.oplus.eyeprotect` | ColorOS Eye Comfort display overlay | Disabled (`pm disable-user`) |
| `com.oplus.games` | ColorOS Game Space & Game Toolkit (restorable via [2]->[5]) | Disabled (`pm disable-user`) |
| `com.oplus.logtrial` | Continuous debug log & crash dump collector | Disabled (`pm disable-user`) |
| `com.oplus.melody` | Chinese HeyMelody earphone companion stub | Disabled (`pm disable-user`) |
| `com.oplus.metis` | Fluid Cloud ('Island') Metis context planner (restorable via [2]->[1]) | Disabled (`pm disable-user`) |
| `com.oplus.ocar` | Chinese OCar automotive UI (restorable via [2]->[7]) | Disabled (`pm disable-user`) |
| `com.oplus.owkservice` | OWK background wake & sync scheduler | Disabled (`pm disable-user`) |
| `com.oplus.owork` | Chinese OWork enterprise container | Disabled (`pm disable-user`) |
| `com.oplus.phonenoareainquire` | Chinese province lookup for phone numbers | Disabled (`pm disable-user`) |
| `com.oplus.powermonitor` | Background battery analytics collector | Disabled (`pm disable-user`) |
| `com.oplus.sauhelper` | Silent App Update (SAU) & background telemetry agent | Disabled (`pm disable-user`) |
| `com.oplus.screenrecorder` | Built-in ColorOS screen recorder (restorable via [2]->[3]) | Disabled (`pm disable-user`) |
| `com.oplus.screenshot` | ColorOS scrolling & 3-finger screenshots (restorable via [2]->[3]) | Disabled (`pm disable-user`) |
| `com.oplus.smartengine` | Fluid Cloud ('Island') SmartEngine triggers (restorable via [2]->[1]) | Disabled (`pm disable-user`) |
| `com.oplus.smartmediacontroller` | Fluid Cloud ('Island') camera cutout media player (restorable via [2]->[1]) | Disabled (`pm disable-user`) |
| `com.oplus.sos` | Mainland China SOS emergency routing service | Disabled (`pm disable-user`) |
| `com.oplus.stdsp` | STDSP signal analytics service | Disabled (`pm disable-user`) |
| `com.oplus.subsys` | Subsys background hardware monitor daemon | Disabled (`pm disable-user`) |
| `com.oplus.travelengine` | Chinese flight/train/hotel card assistant | Disabled (`pm disable-user`) |
| `com.oplus.vdc` | Virtual Display Controller (VDC) helper | Disabled (`pm disable-user`) |
| `com.oplus.viewtalk` | In-car video calling ViewTalk bridge | Disabled (`pm disable-user`) |
| `com.oppo.ctautoregist` | China Telecom SIM background auto-registration | Disabled (`pm disable-user`) |
| `com.oppo.instant.local.service` | Local Quick Apps CN mini-program service | Disabled (`pm disable-user`) |
| `com.qti.dcf` | Qualcomm Device Configuration Framework telemetry | Disabled (`pm disable-user`) |
| `com.qualcomm.qti.powersavemode` | Legacy Qualcomm power save module | Disabled (`pm disable-user`) |
| `com.ted.number` | Chinese Ted spam caller-ID database | Disabled (`pm disable-user`) |
| `com.unionpay.tsmservice` | Chinese UnionPay NFC TSM payment daemon | Disabled (`pm disable-user`) |

</details>

---

## 🤝 Documentation, Architecture & Contributing

* **Architecture & Decision Records**: [`docs/architecture/ARCHITECTURE.md`](docs/architecture/ARCHITECTURE.md), [`docs/architecture/DECISIONS.md`](docs/architecture/DECISIONS.md)
* **Troubleshooting & Known Issues**: [`docs/guides/KNOWN_ISSUES.md`](docs/guides/KNOWN_ISSUES.md), [`docs/guides/SUPPORT.md`](docs/guides/SUPPORT.md)
* **Contributing & Running Tests**: [`docs/development/CONTRIBUTING.md`](docs/development/CONTRIBUTING.md)
  ```powershell
  powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_script_syntax.ps1
  python tests/test_markdown_links.py
  ```
* **License**: Distributed under the **MIT License**. See [`LICENSE`](LICENSE).

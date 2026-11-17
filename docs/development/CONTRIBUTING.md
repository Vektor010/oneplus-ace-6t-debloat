# Contributing to AceDebloat

Thank you for your interest in contributing to **AceDebloat (OnePlus Ace 6T & ColorOS Debloat Toolkit)**!

We welcome contributions from developers, reverse engineers, and OnePlus users worldwide. To maintain high code quality, stability, and zero-brick safety guarantees, please review the following guidelines before submitting code or package suggestions.

---

## 🎯 Contribution Principles

1. **Zero-Brick Priority**: Every modification must be 100% reversible without Root access.
2. **Evidence Before Assertions**: Never submit a package to the disable/suspend database without verifying its exact package name and behavior via `adb shell dumpsys package <package_name>`.
3. **Strict Whitelist Protection**: Core telephony, GMS framework (`com.google.android.gms`), Play Store (`com.android.vending`), active IME keyboards, default launcher, and system UI must remain untouchable.

---

## 🛠️ Development Workflow

### 1. Fork and Clone
```bash
git clone https://github.com/Vektor010/oneplus-ace-6t-debloat.git
cd oneplus-ace-6t-debloat
```

### 2. Verify Syntax Locally
Before creating a pull request, run the automated syntax and AST validator:
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_script_syntax.ps1
```
All tests must pass with **0 errors**.

### 3. Adding or Modifying Packages
When suggesting a new package for debloat or restoration:
* Document the package name accurately (e.g. `com.example.service`).
* Classify whether it requires `pm disable-user` or `pm suspend` (for protected ColorOS packages).
* Add a human-readable description in both Russian and English.
* Verify whether the package affects visible UI features (AOD, gestures, Fluid Cloud, camera).

---

## 🧪 Testing Checklist
- [ ] PowerShell AST syntax parsed with 0 errors.
- [ ] No hardcoded personal paths or credentials.
- [ ] Line endings preserved (CRLF for `.bat` and `.ps1`, LF for `.md` and `.yml`).
- [ ] Character encoding is pure **UTF-8 without BOM**.
- [ ] Hardware safety check (`PLR110` / `CN01`) remains intact.

---

## 📬 Submitting a Pull Request
1. Branch from `main`: `git checkout -b feature/your-feature-name`.
2. Commit with descriptive conventional commit messages:
   - `feat: add package X to debloat database`
   - `fix: prevent timeout on slow ADB devices`
   - `docs: update troubleshooting guide`
3. Open a Pull Request referencing any related issues.

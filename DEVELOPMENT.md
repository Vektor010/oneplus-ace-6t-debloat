# Development & Engineering Manual

This manual details how to clone, modify, validate, and package **AceDebloat**.

---

## 1. Prerequisites

- **Host OS**: Windows 10 / 11 (64-bit)
- **PowerShell**: Version 5.1 or later (PowerShell Core 7+ fully supported)
- **Python**: Version 3.10+ (for release packaging and automated verification scripts)
- **Git**: Installed with standard CLI tools

---

## 2. Setting Up the Local Workspace

```bash
git clone https://github.com/Vektor010/oneplus-ace-6t-debloat.git
cd oneplus-ace-6t-debloat
```

---

## 3. Running Automated Tests

AceDebloat includes an automated AST and database integrity validator. Run it from the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_script_syntax.ps1
```

### What the test validates:
1. **PowerShell AST Parsing**: Ensures zero syntax errors or unescaped tokens.
2. **Package Database Integrity**: Checks for duplicated package entries across `$DisablePackages` and `$SuspendPackages`.
3. **Whitelist Protection**: Asserts that no critical system package has been accidentally added to deactivation arrays.
4. **Line Ending Verification**: Validates Windows CRLF formatting on `.bat` and `.ps1` files.

---

## 4. Release Packaging Pipeline

To package the production release zip (`OnePlus_Ace6T_Debloat_Tool.zip`):

```powershell
python -c "
import os, zipfile
pkg_dir = r'OnePlus_Ace6T_Debloat_Package'
zip_path = r'OnePlus_Ace6T_Debloat_Tool.zip'
if os.path.exists(zip_path): os.remove(zip_path)
with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
    for root, dirs, files in os.walk(pkg_dir):
        for file in files:
            p = os.path.join(root, file)
            zipf.write(p, os.path.relpath(p, pkg_dir))
print(f'Archive successfully built: {os.path.getsize(zip_path)} bytes')
"
```

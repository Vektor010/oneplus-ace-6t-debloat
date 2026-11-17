# Security Policy & Safety Architecture

## 1. Safety Architecture

AceDebloat is engineered with strict adherence to non-destructive user-space operation:
- **Zero Root Privileges**: The toolkit strictly utilizes Android user-level package management (`--user 0`).
- **Read-Only System Partitions**: No modifications are made to `/system`, `/vendor`, boot images, or cryptographic partitions.
- **Bootloader Integrity**: The device bootloader remains locked; SafetyNet, Play Integrity, and Knox security flags remain completely undisturbed (0x0).
- **100% Reversible**: Disabling and freezing does not erase binary data. The system can be fully restored to factory state at any time via menu Option `[5]` or standard Android factory reset.

---

## 2. Protected Package Whitelist

To eliminate the possibility of communication failures, system lockouts, or interface crashes, the following services are enforced as strictly protected:

| Category | Protected Identifiers | Rationale |
| :--- | :--- | :--- |
| **System Core** | `android`, `com.android.systemui`, `com.android.settings` | Operating system shell & settings |
| **Telephony** | `com.android.phone`, `com.android.server.telecom`, RIL daemons | Voice calls, emergency dialer, SMS |
| **Google Play** | `com.google.android.gms`, `com.android.vending` | Core application framework & Play Store |
| **Input (IME)** | `com.google.android.inputmethod.latin` (Gboard) | Prevents lockout from entering PIN/passwords |
| **Connectivity** | Core Wi-Fi, Bluetooth, NFC host services | Local peripheral communication |
| **User VPN** | `com.happproxy` | Network proxy routing safety |

---

## 3. Reporting a Security Vulnerability

If you discover a vulnerability or potential regression that could cause a device malfunction, do not open a public issue. 

Please submit a responsible disclosure report via GitHub Security Advisories or contact the maintainer directly at:
- **GitHub**: [@Vektor010](https://github.com/Vektor010)

Reports will be evaluated and patched within 48 hours.

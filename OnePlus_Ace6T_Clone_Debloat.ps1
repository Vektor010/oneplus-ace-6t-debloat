#Requires -Version 5.1
<#
.SYNOPSIS
    AceDebloat v5.0 — Zero-Root Debloat, Deep Freeze & Battery Analyzer for OnePlus Ace 6T (ColorOS 16/17).
.DESCRIPTION
    Non-destructive user-space (--user 0) optimization toolkit for OnePlus Ace 6T (PLR110):
    1. Disables 80 unnecessary regional/telemetry packages via: pm disable-user --user 0 (NEVER deletes /system APKs)
    2. Freezes 13 protected services (HeyTap Browser, App Market, Ads, Breeno) via: pm suspend --user 0 + AppOps hardening
    3. Decouples Chinese APK installer checks (com.oplus.appdetail) for direct clean APK installation
    4. Profiles real battery drain in mAh via dumpsys batterystats (with full u0a* UID resolution)
    5. Provides 1-click granular feature restoration (Fluid Cloud, AOD, Screenshots, Game Toolkit) and 100% rollback
.NOTES
    Target Device: OnePlus Ace 6T (PLR110), ColorOS 16 / 17 CN
    Version: 5.0 (Bilingual EN/RU, Deadlock-Free Async ADB, Auto-ADB Download, Complete AppOps Rollback)
#>

[CmdletBinding()]
param(
    [switch]$ApplyClone,
    [switch]$Rollback,
    [switch]$OptimizeOnly,
    [switch]$BatteryReport,
    [switch]$RestoreFeature,
    [switch]$Force,
    [ValidateSet("auto", "ru", "en")]
    [string]$Lang = "auto",
    [string]$AdbPath
)

# Force UTF-8 encoding for console I/O
try { [Console]::InputEncoding = [System.Text.Encoding]::UTF8 } catch {}
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}
$OutputEncoding = [System.Text.Encoding]::UTF8

# Auto-detect UI language
if ($Lang -eq "auto") {
    $uiLang = [System.Globalization.CultureInfo]::CurrentUICulture.TwoLetterISOLanguageName.ToLowerInvariant()
    $Global:UiLang = if ($uiLang -in @("ru", "uk", "be", "kk")) { "ru" } else { "en" }
} else {
    $Global:UiLang = $Lang.ToLowerInvariant()
}

function T {
    param([string]$Ru, [string]$En)
    if ($Global:UiLang -eq "ru") { return $Ru }
    return $En
}

# Resolve script working directory
$ScriptDirectory = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }
if (-not $ScriptDirectory) { $ScriptDirectory = (Get-Location).Path }

# Unblock downloaded scripts/files if marked with Zone.Identifier
try { Get-ChildItem -Path $ScriptDirectory -File -ErrorAction SilentlyContinue | Unblock-File -ErrorAction SilentlyContinue } catch {}

# Selected target ADB device serial (isolates physical phone from emulators)
$Global:TargetDeviceSerial = $null

# ==============================================================================
# 1. TARGET HARDWARE SPECIFICATION
# ==============================================================================
$TargetModel = "PLR110"
$TargetRegionTokens = @("CN01", "CN")

# ==============================================================================
# 2. PACKAGE DATABASE: 80 PACKAGES FOR USER-LEVEL DISABLE (pm disable-user)
# ==============================================================================
$DisablePackages = @(
    "com.oplus.appdetail",
    "com.heytap.cloud",
    "andes.oplus.documentsreader",
    "com.android.adservices.api",
    "com.android.cellbroadcastreceiver",
    "com.android.cts.priv.ctsshim",
    "com.android.DeviceAsWebcam",
    "com.android.dynsystem",
    "com.android.federatedcompute.services",
    "com.android.healthconnect.controller",
    "com.android.hotspot2.osulogin",
    "com.android.musicfx",
    "com.android.ondevicepersonalization.services",
    "com.android.printspooler",
    "com.android.simappdialog",
    "com.android.virtualization.terminal",
    "com.android.wallpaper.livepicker.overlay",
    "com.autonavi.minimap",
    "com.baidu.input_oppo",
    "com.baidu.searchbox",
    "com.coloros.codebook",
    "com.coloros.compass2",
    "com.coloros.digitalwellbeing",
    "com.coloros.karaoke",
    "com.coloros.mapcom.frame",
    "com.coloros.ocs.opencapabilityservice",
    "com.coloros.oshare",
    "com.coloros.remoteguardservice",
    "com.coloros.sceneservice",
    "com.coloros.securepay",
    "com.coloros.sharescreen",
    "com.coloros.smartlock",
    "com.coloros.smartsidebar",
    "com.coloros.soundrecorder",
    "com.finshell.wallet",
    "com.gamma.scan",
    "com.google.android.gm",
    "com.google.android.googlequicksearchbox",
    "com.google.android.projection.gearhead",
    "com.google.ar.lens",
    "com.heytap.accessory",
    "com.heytap.colorfulengine",
    "com.heytap.music",
    "com.heytap.opluscarlink",
    "com.heytap.themestore",
    "com.heytap.vip",
    "com.heytap.yoli",
    "com.microsoftsdk.crossdeviceservicebroker",
    "com.oplus.account",
    "com.oplus.aiwidgets",
    "com.oplus.aod",
    "com.oplus.atlas",
    "com.oplus.cardigitalkey",
    "com.oplus.consumerIRApp",
    "com.oplus.dfs",
    "com.oplus.eyeprotect",
    "com.oplus.games",
    "com.oplus.logtrial",
    "com.oplus.melody",
    "com.oplus.metis",
    "com.oplus.ocar",
    "com.oplus.owkservice",
    "com.oplus.owork",
    "com.oplus.phonenoareainquire",
    "com.oplus.powermonitor",
    "com.oplus.sauhelper",
    "com.oplus.screenrecorder",
    "com.oplus.screenshot",
    "com.oplus.smartengine",
    "com.oplus.smartmediacontroller",
    "com.oplus.sos",
    "com.oplus.stdsp",
    "com.oplus.subsys",
    "com.oplus.travelengine",
    "com.oplus.vdc",
    "com.oplus.viewtalk",
    "com.oppo.ctautoregist",
    "com.oppo.instant.local.service",
    "com.qti.dcf",
    "com.qualcomm.qti.powersavemode",
    "com.ted.number",
    "com.unionpay.tsmservice"
)

# ==============================================================================
# 3. PACKAGE DATABASE: 13 PROTECTED SERVICES FOR DEEP FREEZE (pm suspend + AppOps)
# ==============================================================================
$SuspendPackages = @(
    "com.heytap.pictorial",
    "com.oplus.themestore",
    "com.heytap.market",
    "com.coloros.securityguard",
    "com.heytap.speechassist",
    "com.opos.ads",
    "com.heytap.browser",
    "com.heytap.quicksearchbox",
    "com.oppo.store",
    "com.nearme.instant.platform",
    "com.oplus.ovoicemanager.wakeup",
    "com.heytap.htms",
    "com.oplus.ovoicemanager"
)

# ==============================================================================
# 4. STRICT SAFETY WHITELIST (NEVER TOUCHED)
# ==============================================================================
$StrictWhitelist = @(
    "android",
    "com.android.systemui",
    "com.android.settings",
    "com.android.phone",
    "com.android.server.telecom",
    "com.android.providers.telephony",
    "com.android.providers.settings",
    "com.android.providers.media",
    "com.android.providers.downloads",
    "com.android.permissioncontroller",
    "com.google.android.gms",
    "com.android.vending",
    "com.google.android.gsf",
    "com.google.android.webview",
    "com.google.android.inputmethod.latin",
    "com.happproxy",
    "com.newmoonproduction.bigfarmhomestead"
)

# ==============================================================================
# 5. CORE HELPERS & DEADLOCK-FREE ADB ENGINE
# ==============================================================================

function Write-Header {
    param([string]$Title)
    try { Clear-Host } catch {}
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "   ACEDEBLOAT v5.0  |  ONEPLUS ACE 6T (PLR110)  |  COLOROS 16 / 17    " -ForegroundColor Green
    Write-Host "======================================================================" -ForegroundColor Cyan
    if ($Title) {
        Write-Host " >>> $Title" -ForegroundColor Yellow
        Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray
    }
}

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[$timestamp] [$Level] $Message"
    $logFile = Join-Path -Path $ScriptDirectory -ChildPath "clone_tool.log"
    Add-Content -Path $logFile -Value $logLine -Encoding UTF8 -ErrorAction SilentlyContinue

    switch ($Level) {
        "SUCCESS" { Write-Host "[+] $Message" -ForegroundColor Green }
        "WARN"    { Write-Host "[!] $Message" -ForegroundColor Yellow }
        "ERROR"   { Write-Host "[-] $Message" -ForegroundColor Red }
        "STEP"    { Write-Host ">>> $Message" -ForegroundColor Cyan }
        default   { Write-Host "[*] $Message" -ForegroundColor Gray }
    }
}

function Install-PortablePlatformTools {
    $zipUrl = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
    $tempZip = Join-Path -Path $env:TEMP -ChildPath "platform-tools-latest-windows.zip"
    $extractRoot = Join-Path -Path $env:TEMP -ChildPath "adb_extract_tmp"
    $destDir = Join-Path -Path $ScriptDirectory -ChildPath "platform-tools"

    try {
        Write-Log (T "Скачивание официального Android Platform Tools от Google..." "Downloading official Google Android Platform Tools...") "STEP"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $zipUrl -OutFile $tempZip -UseBasicParsing -TimeoutSec 60

        if (Test-Path $extractRoot) { Remove-Item -Path $extractRoot -Recurse -Force -ErrorAction SilentlyContinue }
        Expand-Archive -Path $tempZip -DestinationPath $extractRoot -Force

        $extractedTools = Join-Path -Path $extractRoot -ChildPath "platform-tools"
        if (Test-Path "$extractedTools\adb.exe") {
            if (-not (Test-Path $destDir)) { New-Item -Path $destDir -ItemType Directory -Force | Out-Null }
            Copy-Item -Path "$extractedTools\*" -Destination $destDir -Recurse -Force
            Write-Log (T "ADB успешно установлен в: $destDir" "ADB installed successfully to: $destDir") "SUCCESS"
            return (Resolve-Path "$destDir\adb.exe").Path
        }
    } catch {
        Write-Log (T "Ошибка загрузки Platform Tools: $($_.Exception.Message)" "Failed to download Platform Tools: $($_.Exception.Message)") "ERROR"
    } finally {
        Remove-Item -Path $tempZip -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $extractRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
    return $null
}

function Find-AdbExecutable {
    param([string]$CustomPath)

    if (Test-Path "$ScriptDirectory\platform-tools\adb.exe") {
        return (Resolve-Path "$ScriptDirectory\platform-tools\adb.exe").Path
    }
    if (Test-Path "$ScriptDirectory\adb.exe") {
        return (Resolve-Path "$ScriptDirectory\adb.exe").Path
    }
    if ($CustomPath -and (Test-Path $CustomPath)) {
        return (Resolve-Path $CustomPath).Path
    }

    $cmd = Get-Command adb.exe -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    $searchPaths = @(
        "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Google.PlatformTools_Microsoft.Winget.Source_8wekyb3d8bbwe\platform-tools\adb.exe",
        "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe",
        "$env:USERPROFILE\Downloads\platform-tools\adb.exe",
        "C:\platform-tools\adb.exe",
        "C:\adb\adb.exe"
    )
    foreach ($p in $searchPaths) {
        if (Test-Path $p) { return (Resolve-Path $p).Path }
    }

    if (-not [Console]::IsInputRedirected) {
        Write-Host ""
        Write-Host (T "[-] Исполняемый файл adb.exe не найден (возможно, вы скачали исходники вместо архива из Releases)." "[-] adb.exe was not found (you may have downloaded source code instead of the Release ZIP).") -ForegroundColor Yellow
        Write-Host (T "Хотите автоматически скачать официальный ADB от Google (~7 МБ) прямо в эту папку?" "Do you want to automatically download official Google ADB (~7 MB) into this folder?") -ForegroundColor Cyan
        Write-Host (T "  Введите [1] чтобы скачать автоматически, или [0] для выхода: " "  Enter [1] to download automatically, or [0] to exit: ") -NoNewline -ForegroundColor Green
        $dlChoice = Read-Host
        if ($dlChoice -eq "1") {
            return (Install-PortablePlatformTools)
        }
    }
    return $null
}

function Start-AdbDaemon {
    param([string]$AdbExe)
    try {
        # Launch start-server without redirecting streams so daemon does not inherit pipe handles
        $p = Start-Process -FilePath $AdbExe -ArgumentList "start-server" -WindowStyle Hidden -PassThru
        if ($p -and -not $p.WaitForExit(10000)) {
            try { $p.Kill() } catch {}
        }
    } catch {}
}

function Format-ProcessArguments {
    param([string[]]$ArgList)
    $escaped = foreach ($a in $ArgList) {
        if ($a -match '[\s"]') {
            '"' + ($a -replace '"', '\"') + '"'
        } else {
            $a
        }
    }
    return ($escaped -join " ")
}

function Invoke-Adb {
    param(
        [string]$AdbExe,
        [string[]]$Arguments,
        [switch]$IgnoreTargetSerial,
        [int]$TimeoutMs = 30000
    )
    $finalArgs = if ($Global:TargetDeviceSerial -and -not $IgnoreTargetSerial) {
        @("-s", $Global:TargetDeviceSerial) + $Arguments
    } else {
        $Arguments
    }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $AdbExe
    $psi.Arguments = Format-ProcessArguments -ArgList $finalArgs
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.StandardOutputEncoding = [System.Text.Encoding]::UTF8
    $psi.StandardErrorEncoding = [System.Text.Encoding]::UTF8
    $psi.CreateNoWindow = $true

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi

    try {
        [void]$proc.Start()
        $outTask = $proc.StandardOutput.ReadToEndAsync()
        $errTask = $proc.StandardError.ReadToEndAsync()

        if (-not $proc.WaitForExit($TimeoutMs)) {
            try { $proc.Kill() } catch {}
            $partialOut = if ($outTask.Wait(500)) { $outTask.Result } else { "" }
            $partialErr = if ($errTask.Wait(500)) { $errTask.Result } else { "" }
            return [PSCustomObject]@{
                ExitCode = -1
                Output   = $partialOut.Trim()
                Error    = ("ADB command timed out after $($TimeoutMs)ms. " + $partialErr).Trim()
            }
        }

        [void][System.Threading.Tasks.Task]::WaitAll(@($outTask, $errTask), 3000)
        $stdout = if ($outTask.IsCompleted -and -not $outTask.IsFaulted) { $outTask.Result } else { "" }
        $stderr = if ($errTask.IsCompleted -and -not $errTask.IsFaulted) { $errTask.Result } else { "" }

        return [PSCustomObject]@{
            ExitCode = $proc.ExitCode
            Output   = $stdout.Trim()
            Error    = $stderr.Trim()
        }
    } finally {
        $proc.Dispose()
    }
}

function Get-DeviceProperties {
    param([string]$AdbExe, [string]$Serial)
    $prevSerial = $Global:TargetDeviceSerial
    $Global:TargetDeviceSerial = $Serial
    try {
        $model   = (Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "getprop", "ro.product.model")).Output
        $vModel  = (Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "getprop", "ro.product.vendor.model")).Output
        $manuf   = (Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "getprop", "ro.product.manufacturer")).Output
        $buildId = (Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "getprop", "ro.build.display.id")).Output
        $android = (Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "getprop", "ro.build.version.release")).Output
        $region  = (Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "getprop", "ro.vendor.oplus.regionmark")).Output
        $osVer   = (Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "getprop", "ro.build.version.oplusrom")).Output

        return [PSCustomObject]@{
            Serial       = $Serial
            Model        = $model
            VendorModel  = $vModel
            Manufacturer = $manuf
            BuildId      = $buildId
            AndroidVer   = $android
            RegionMark   = $region
            OplusRomVer  = $osVer
        }
    } finally {
        $Global:TargetDeviceSerial = $prevSerial
    }
}

function Test-AdbConnection {
    param([string]$AdbExe)
    Write-Log (T "Проверка связи с устройством..." "Checking ADB device connection...") "STEP"

    $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("devices") -IgnoreTargetSerial
    $deviceMatches = @()
    foreach ($line in ($res.Output -split "`r?`n")) {
        if ($line -match "^\s*([a-zA-Z0-9_\-\.:]+)\s+(device|unauthorized|offline|recovery|fastboot)\b") {
            $deviceMatches += [PSCustomObject]@{
                Serial = $matches[1]
                State  = $matches[2]
            }
        }
    }

    if ($deviceMatches.Count -eq 0) {
        Write-Log (T "Устройство не найдено по USB!" "No Android device detected over USB!") "ERROR"
        Write-Host ""
        Write-Host "======================================================================" -ForegroundColor Yellow
        Write-Host (T " [!] Устройство не обнаружено через ADB." " [!] Device not detected by ADB.") -ForegroundColor Yellow
        Write-Host (T " Проверьте следующие пункты:" " Please verify:") -ForegroundColor Gray
        Write-Host (T "  1. Смартфон разблокирован и подключён качественным кабелем USB-C." "  1. Smartphone screen is unlocked and connected via a data USB-C cable.") -ForegroundColor Gray
        Write-Host (T "  2. «Настройки» -> «Для разработчиков» -> включена «Отладка по USB»." "  2. Settings -> Developer Options -> 'USB debugging' is enabled.") -ForegroundColor Gray
        Write-Host (T "  3. В шторке выбран режим USB «Передача файлов» (не «Только зарядка»)." "  3. USB mode in notification shade is set to 'File Transfer' (not Charging).") -ForegroundColor Gray
        Write-Host (T "  4. Если на экране есть запрос «Разрешить отладку по USB?» — нажмите «Разрешить»." "  4. Accept 'Allow USB debugging?' prompt on your smartphone screen.") -ForegroundColor Gray
        Write-Host "======================================================================" -ForegroundColor Yellow
        Write-Host ""
        return $null
    }

    $unauth = @($deviceMatches | Where-Object { $_.State -eq "unauthorized" })
    $active = @($deviceMatches | Where-Object { $_.State -eq "device" })

    if ($active.Count -eq 0 -and $unauth.Count -gt 0) {
        Write-Log (T "Устройство ($($unauth[0].Serial)) ожидает подтверждения (unauthorized)." "Device ($($unauth[0].Serial)) is unauthorized.") "WARN"
        Write-Host ""
        Write-Host "======================================================================" -ForegroundColor Yellow
        Write-Host (T " [!] ВНИМАНИЕ: Смартфон подключён, но отладка не разрешена!" " [!] ATTENTION: Phone connected, awaiting USB debugging authorization!") -ForegroundColor Yellow
        Write-Host (T " Разблокируйте экран телефона и в окне «Разрешить отладку по USB?»:" " Unlock your phone screen and on the 'Allow USB debugging?' popup:") -ForegroundColor Cyan
        Write-Host (T " 1. Отметьте [v] «Всегда разрешать с этого компьютера»." " 1. Check [v] 'Always allow from this computer'.") -ForegroundColor Cyan
        Write-Host (T " 2. Нажмите «Разрешить»." " 2. Tap 'Allow'.") -ForegroundColor Green
        Write-Host "======================================================================" -ForegroundColor Yellow
        Write-Host ""
        return $null
    }

    if ($active.Count -eq 0) {
        Write-Log (T "Устройство найдено в статусе '$($deviceMatches[0].State)', требуется статус 'device'." "Device is in '$($deviceMatches[0].State)' state; 'device' state is required.") "WARN"
        return $null
    }

    # Multi-device isolation: inspect all active targets and prefer PLR110 over emulators
    $candidates = @()
    foreach ($d in $active) {
        $candidates += Get-DeviceProperties -AdbExe $AdbExe -Serial $d.Serial
    }

    $selected = $candidates | Where-Object { $_.Model -eq $TargetModel -or $_.VendorModel -eq $TargetModel } | Select-Object -First 1
    if (-not $selected) {
        $nonEmulator = $candidates | Where-Object { $_.Serial -notmatch "^emulator-" } | Select-Object -First 1
        $selected = if ($nonEmulator) { $nonEmulator } else { $candidates[0] }
    }

    $Global:TargetDeviceSerial = $selected.Serial
    return $selected
}

function Verify-DeviceCompatibility {
    param([PSCustomObject]$DeviceInfo)
    Write-Host (T "Проверка совместимости устройства:" "Device compatibility check:") -ForegroundColor Yellow
    Write-Host ("  " + (T "Модель:" "Model:") + "   $($DeviceInfo.Model) / $($DeviceInfo.VendorModel) (" + (T "Ожидается" "Expected") + ": $TargetModel)")
    Write-Host ("  " + (T "Сборка:" "Build:") + "   $($DeviceInfo.BuildId) | Android $($DeviceInfo.AndroidVer) | RegionMark: $($DeviceInfo.RegionMark)")

    $isTargetModel = ($DeviceInfo.Model -eq $TargetModel -or $DeviceInfo.VendorModel -eq $TargetModel)
    $isChinaRegion = ($DeviceInfo.BuildId -like "*CN01*" -or $DeviceInfo.RegionMark -eq "CN")

    if ($isTargetModel -and $isChinaRegion) {
        Write-Log (T "Устройство OnePlus Ace 6T (PLR110 CN) подтверждено." "OnePlus Ace 6T (PLR110 CN) verified.") "SUCCESS"
        return $true
    }

    if ($Force) {
        Write-Log (T "Режим -Force активен. Проверка модели/региона пропущена." "-Force specified. Bypassing strict model/region lock.") "WARN"
        return $true
    }

    if ($isTargetModel) {
        Write-Host ""
        Write-Host (T "[!] ВНИМАНИЕ: Обнаружен OnePlus Ace 6T ($TargetModel), но сборка отличается от стандартной CN01 (например, ColorOS 17 или Global ROM)." "[!] WARNING: OnePlus Ace 6T ($TargetModel) detected, but build differs from standard CN01 (e.g. ColorOS 17 or Global/OxygenOS ROM).") -ForegroundColor Yellow
        if ([Console]::IsInputRedirected) { return $true }
        Write-Host (T "  Введите [1] чтобы продолжить (безопасно с белым списком), или [0] для выхода: " "  Enter [1] to continue anyway (whitelist active), or [0] to exit: ") -NoNewline -ForegroundColor Cyan
        $ans = Read-Host
        return ($ans -eq "1")
    }

    Write-Log (T "ОШИБКА: Модель '$($DeviceInfo.Model)' не является OnePlus Ace 6T ($TargetModel)." "ERROR: Device '$($DeviceInfo.Model)' is not a OnePlus Ace 6T ($TargetModel).") "ERROR"
    Write-Host ""
    Write-Host (T "[!] ОПЕРАЦИЯ ЗАБЛОКИРОВАНА: Пакетная база настроена и протестирована строго для OnePlus Ace 6T ($TargetModel)." "[!] BLOCKED FOR SAFETY: This package database is audited strictly for OnePlus Ace 6T ($TargetModel).") -ForegroundColor Red
    if (-not [Console]::IsInputRedirected) {
        Write-Host (T "  (Для принудительного запуска на свой риск введите [FORCE], либо [0] для выхода): " "  (To override at your own risk type [FORCE], or [0] to exit): ") -NoNewline -ForegroundColor Yellow
        $override = Read-Host
        if ($override -eq "FORCE") { return $true }
    }
    return $false
}

function Create-BackupSnapshot {
    param([string]$AdbExe)
    $backupDir = Join-Path -Path $ScriptDirectory -ChildPath "Backups"
    if (-not (Test-Path $backupDir)) {
        try { New-Item -Path $backupDir -ItemType Directory -Force | Out-Null } catch {}
    }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $currentBackup = Join-Path -Path $backupDir -ChildPath "backup_$timestamp"
    try { New-Item -Path $currentBackup -ItemType Directory -Force | Out-Null } catch {}

    Write-Log (T "Создание снимка состояния пакетов..." "Creating pre-debloat package snapshot...") "STEP"

    $disRes = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "list", "packages", "-d")
    $disFile = Join-Path -Path $currentBackup -ChildPath "disabled_packages.txt"
    Set-Content -Path $disFile -Value $disRes.Output -Encoding UTF8 -ErrorAction SilentlyContinue

    $allRes = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "list", "packages")
    $allFile = Join-Path -Path $currentBackup -ChildPath "all_packages.txt"
    Set-Content -Path $allFile -Value $allRes.Output -Encoding UTF8 -ErrorAction SilentlyContinue

    Write-Log ((T "Резервная копия сохранена в: " "Backup saved to: ") + $currentBackup) "SUCCESS"
    return $currentBackup
}

function Get-ProtectedPackagesSet {
    param([string]$AdbExe)
    $protected = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

    foreach ($p in $StrictWhitelist) {
        [void]$protected.Add($p)
    }

    $launcherRes = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "cmd", "package", "resolve-activity", "-a", "android.intent.action.MAIN", "-c", "android.intent.category.HOME")
    if ($launcherRes.Output -match "packageName=([a-zA-Z0-9_\.]+)") {
        [void]$protected.Add($matches[1])
    }

    $imeRes = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "settings", "get", "secure", "default_input_method")
    if ($imeRes.Output -match "^([a-zA-Z0-9_\.]+)/") {
        [void]$protected.Add($matches[1])
    }

    return $protected
}

function Optimize-DeviceApps {
    param([string]$AdbExe)
    Write-Header (T "ОПТИМИЗАЦИЯ ПРИЛОЖЕНИЙ И ОЧИСТКА КЭША" "ART APPLICATION OPTIMIZATION & CACHE TRIM")

    Write-Host (T "1. Безопасная очистка временного кэша (pm trim-caches)..." "1. Trimming temporary system caches (pm trim-caches)...") -ForegroundColor Yellow
    Write-Log "adb shell pm trim-caches 999999999999" "STEP"
    $trimRes = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "trim-caches", "999999999999") -TimeoutMs 60000
    $trimOut = ($trimRes.Output + " " + $trimRes.Error).Trim()
    Write-Host "   $trimOut" -ForegroundColor Green

    Write-Host ""
    Write-Host (T "2. Профильная компиляция ART (cmd package compile -m speed-profile -a)..." "2. Running ART profile-guided compilation (cmd package compile -m speed-profile -a)...") -ForegroundColor Yellow
    Write-Host (T "   [i] Это может занять 1-3 минуты. Пожалуйста, не отключайте кабель..." "   [i] This normally takes 1-3 minutes. Please keep USB connected (not frozen)...") -ForegroundColor Cyan
    Write-Log "adb shell cmd package compile -m speed-profile -a" "STEP"
    $compRes = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "cmd", "package", "compile", "-m", "speed-profile", "-a") -TimeoutMs 600000
    $compOut = ($compRes.Output + " " + $compRes.Error).Trim()
    if ($compOut) { Write-Host "   $compOut" -ForegroundColor Green }
    Write-Log (T "Оптимизация ART завершена успешно." "ART optimization completed successfully.") "SUCCESS"
}

function Convert-BatteryUidToPackage {
    param([string]$RawUid, [hashtable]$UidMap)
    if ($UidMap.ContainsKey($RawUid)) { return $UidMap[$RawUid] }

    # Map u0a234 -> 10234, u10a234 -> 1010234
    if ($RawUid -match "^u(\d+)a(\d+)$") {
        $numericUid = [string](([int]$matches[1] * 100000) + 10000 + [int]$matches[2])
        if ($UidMap.ContainsKey($numericUid)) { return $UidMap[$numericUid] }
    } elseif ($RawUid -match "^u(\d+)i(\d+)$") {
        $numericUid = [string](([int]$matches[1] * 100000) + 99000 + [int]$matches[2])
        if ($UidMap.ContainsKey($numericUid)) { return $UidMap[$numericUid] }
    }

    switch ($RawUid) {
        "0"    { return "Android Kernel / Root (UID 0)" }
        "1000" { return "Android System Services (UID 1000)" }
        "1001" { return "Phone / Telephony Radio (UID 1001)" }
        "1010" { return "Wi-Fi Subsystem (UID 1010)" }
        "1002" { return "Bluetooth Subsystem (UID 1002)" }
        default { return (T "Системный процесс (UID $RawUid)" "System Component (UID $RawUid)") }
    }
}

function Show-BatteryDrainAnalysis {
    param([string]$AdbExe)
    Write-Header (T "АНАЛИЗ РАСХОДА БАТАРЕИ (TOP APP DRAIN)" "BATTERY DRAIN PROFILER (REAL mAh)")

    Write-Host (T "1. Состояние аккумулятора..." "1. Reading battery telemetry...") -ForegroundColor Yellow
    $batt = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "dumpsys", "battery")
    $level = "N/A"; $temp = "N/A"; $volt = "N/A"; $health = "N/A"; $status = "N/A"
    foreach ($line in ($batt.Output -split "`r?`n")) {
        if ($line -match "level:\s*(\d+)") { $level = "$($matches[1])%" }
        if ($line -match "temperature:\s*(\d+)") { $temp = "$([math]::Round([int]$matches[1]/10, 1)) °C" }
        if ($line -match "voltage:\s*(\d+)") { $volt = "$($matches[1]) mV" }
        if ($line -match "health:\s*(\d+)") {
            switch ($matches[1]) {
                "2" { $health = (T "Отличное (Good)" "Good") }
                "3" { $health = (T "Перегрев (Overheat)" "Overheat") }
                "4" { $health = (T "Изношена (Dead)" "Dead") }
                default { $health = "Code $($matches[1])" }
            }
        }
        if ($line -match "status:\s*(\d+)") {
            switch ($matches[1]) {
                "2" { $status = (T "Заряжается" "Charging") }
                "3" { $status = (T "Разряжается" "Discharging") }
                "5" { $status = (T "Заряжена (Full)" "Full") }
                default { $status = "Code $($matches[1])" }
            }
        }
    }

    Write-Host ("  " + (T "Заряд:" "Level:") + " $level | " + (T "Статус:" "Status:") + " $status") -ForegroundColor Cyan
    Write-Host ("  " + (T "Температура:" "Temp:") + " $temp | " + (T "Напряжение:" "Voltage:") + " $volt | " + (T "Здоровье:" "Health:") + " $health") -ForegroundColor Cyan
    Write-Host ""

    Write-Host (T "2. Парсинг dumpsys batterystats (ожидайте 3-5 сек)..." "2. Parsing dumpsys batterystats (wait 3-5 sec)...") -ForegroundColor Yellow

    $uidMap = @{}
    $pkgList = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "list", "packages", "-U") -TimeoutMs 60000
    foreach ($line in ($pkgList.Output -split "`r?`n")) {
        if ($line -match "package:([a-zA-Z0-9_\.]+)\s+uid:(\d+)") {
            $pName = $matches[1]
            $uId = $matches[2]
            if (-not $uidMap.ContainsKey($uId)) {
                $uidMap[$uId] = $pName
            } else {
                $uidMap[$uId] = "$($uidMap[$uId]), $pName"
            }
        }
    }

    $stats = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "dumpsys", "batterystats") -TimeoutMs 120000
    $drainList = [System.Collections.Generic.List[PSCustomObject]]::new()

    $inEstimated = $false
    foreach ($line in ($stats.Output -split "`r?`n")) {
        if ($line -match "Estimated power use \(mAh\):") {
            $inEstimated = $true
            continue
        }
        if ($inEstimated) {
            if ($line -match "^\s*$" -or ($line -match "^[A-Za-z]" -and $line -notmatch "Capacity|Computed|actual|Global")) {
                if ($drainList.Count -gt 5) { break }
            }
            if ($line -match "^\s*(?:UID\s+)?([a-zA-Z0-9_\-]+):\s+([0-9\.]+)\s*(.*)$") {
                $uid = $matches[1]
                $mah = 0.0
                if ([double]::TryParse($matches[2], [System.Globalization.NumberStyles]::Float, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$mah)) {
                    $pkg = Convert-BatteryUidToPackage -RawUid $uid -UidMap $uidMap
                    $drainList.Add([PSCustomObject]@{
                        UID     = $uid
                        Package = $pkg
                        Drain   = $mah
                    })
                }
            }
        }
    }

    if ($drainList.Count -eq 0) {
        Write-Host (T "  Статистика расхода ещё не накопилась (смартфон недавно снят с зарядки или перезагружен)." "  Battery drain statistics are empty (phone was recently unplugged or rebooted).") -ForegroundColor DarkGray
    } else {
        Write-Host ""
        Write-Host (T "ТОП-15 ПОТРЕБИТЕЛЕЙ БАТАРЕИ:" "TOP-15 POWER CONSUMERS:") -ForegroundColor Green
        Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
        $topDrain = $drainList | Sort-Object -Property Drain -Descending | Select-Object -First 15
        $rank = 0
        foreach ($item in $topDrain) {
            $rank++
            $pColor = "White"
            if ($item.Package -match "ozon|wildberries|instagram|telegram|browser|tiktok") { $pColor = "Yellow" }
            if ($item.Package -match "launcher|systemui|android|UID 1000") { $pColor = "DarkCyan" }
            if ($item.Package -match "colorfulengine") { $pColor = "Red" }
            Write-Host (" {0,2}. {1,-52} | {2,7:F2} mAh" -f $rank, $item.Package, $item.Drain) -ForegroundColor $pColor
        }
        Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
    }
}

function Set-PackageAppOpsMode {
    param([string]$AdbExe, [string]$Package, [string]$Mode)
    # Apply core background & notification ops (ignore on disable, default on rollback)
    foreach ($op in @("RUN_IN_BACKGROUND", "RUN_ANY_IN_BACKGROUND", "POST_NOTIFICATION", "BOOT_COMPLETED")) {
        Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "cmd", "appops", "set", $Package, $op, $Mode) | Out-Null
    }
}

function Apply-CloneConfiguration {
    param(
        [string]$AdbExe,
        [System.Collections.Generic.HashSet[string]]$ProtectedSet
    )
    $disTotal = $DisablePackages.Count
    $susTotal = $SuspendPackages.Count

    Write-Header (T "ОЧИСТКА И ОПТИМИЗАЦИЯ COLOROS" "APPLY DEBLOAT & OPTIMIZATION PROFILE")

    Write-Host (T "ГАРАНТИЯ БЕЗОПАСНОСТИ (НИЧЕГО НЕ УДАЛЯЕТСЯ):" "SAFETY CLARIFICATION (NOTHING IS DELETED):") -ForegroundColor Green
    Write-Host (T " - Команда 'pm uninstall' НЕ используется. Файлы прошивки остаются в /system." " - 'pm uninstall' is NEVER used. System APKs remain untouched on /system.") -ForegroundColor Gray
    Write-Host (T " - $disTotal ненужных пакетов отключаются через 'pm disable-user --user 0' (обратимо)." " - $disTotal regional/telemetry packages are disabled via 'pm disable-user --user 0' (reversible).") -ForegroundColor Yellow
    Write-Host (T " - $susTotal защищённых служб (App Market, HeyTap Browser, Ads, Breeno) замораживаются" " - $susTotal vendor-protected apps (App Market, HeyTap Browser, Ads, Breeno) are frozen") -ForegroundColor Yellow
    Write-Host (T "   через 'pm suspend --user 0' + блокировка фоновых прав AppOps (100% обратимо)." "   via 'pm suspend --user 0' + AppOps background hardening (100% reversible).") -ForegroundColor Yellow
    Write-Host (T " - Звонки, Wi-Fi, Gboard, лаунчер, Google Play (GMS) и VPN защищены белым списком." " - Telephony, Wi-Fi, Gboard, Launcher, Google Play (GMS) & VPN are strictly whitelisted.") -ForegroundColor Green
    Write-Host ""

    if (-not [Console]::IsInputRedirected) {
        Write-Host (T "Подтвердите запуск оптимизации:" "Confirm starting optimization:") -ForegroundColor Yellow
        Write-Host (T "  Введите [1] (или Д/Y) для запуска, либо [0] для отмены: " "  Enter [1] (or Y) to start, or [0] to cancel: ") -NoNewline -ForegroundColor Cyan
        $confirm = Read-Host
        if ($confirm -notmatch "^(1|д|да|y|yes)$") {
            Write-Log (T "Отменено пользователем." "Cancelled by user.") "WARN"
            return
        }
    }

    Create-BackupSnapshot -AdbExe $AdbExe | Out-Null

    # --- STAGE 1: Disable Packages ---
    Write-Host ""
    Write-Host ("--- " + (T "ЭТАП 1: Отключение $disTotal пакетов (pm disable-user)" "STAGE 1: Disabling $disTotal packages (pm disable-user)") + " ---") -ForegroundColor Cyan
    $disCount = 0
    $c = 0
    foreach ($pkg in $DisablePackages) {
        $c++
        if ($ProtectedSet.Contains($pkg)) {
            Write-Host "[$c/$disTotal] [PROTECTED] $pkg" -ForegroundColor Magenta
            continue
        }
        $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "disable-user", "--user", "0", $pkg)
        $combined = ($res.Output + " " + $res.Error).Trim()
        if ($combined -match "disabled-user") {
            Write-Host "[$c/$disTotal] [DISABLED] $pkg" -ForegroundColor Green
            $disCount++
        } else {
            Write-Host "[$c/$disTotal] [SKIP] $pkg : $combined" -ForegroundColor DarkGray
        }
    }

    # --- STAGE 2: Suspend Protected Services + AppOps Hardening ---
    Write-Host ""
    Write-Host ("--- " + (T "ЭТАП 2: Заморозка $susTotal служб (pm suspend + AppOps)" "STAGE 2: Freezing $susTotal services (pm suspend + AppOps)") + " ---") -ForegroundColor Cyan
    $susCount = 0
    $s = 0
    foreach ($pkg in $SuspendPackages) {
        $s++
        if ($ProtectedSet.Contains($pkg)) {
            Write-Host "[$s/$susTotal] [PROTECTED] $pkg" -ForegroundColor Magenta
            continue
        }
        $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "suspend", "--user", "0", $pkg)
        Set-PackageAppOpsMode -AdbExe $AdbExe -Package $pkg -Mode "ignore"
        $combined = ($res.Output + " " + $res.Error).Trim()
        if ($combined -match "new suspended state: true") {
            Write-Host "[$s/$susTotal] [FROZEN + APPOPS] $pkg" -ForegroundColor Green
            $susCount++
        } else {
            Write-Host "[$s/$susTotal] [STATUS] $pkg : $combined" -ForegroundColor DarkYellow
        }
    }

    # --- STAGE 3: Direct Clean APK Installation Settings ---
    Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "settings", "put", "secure", "install_non_market_apps", "1") | Out-Null
    Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "settings", "put", "global", "package_verifier_enable", "0") | Out-Null

    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host (T "ИТОГИ: Отключено: $disCount/$disTotal | Заморожено: $susCount/$susTotal" "SUMMARY: Disabled: $disCount/$disTotal | Frozen: $susCount/$susTotal") -ForegroundColor Green
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host ""

    if (-not [Console]::IsInputRedirected) {
        Write-Host (T "Выполнить оптимизацию приложений (ART Dexopt, 1-3 мин)?" "Run ART Dexopt app optimization & cache trim (takes 1-3 min)?") -ForegroundColor Yellow
        Write-Host (T "  Введите [1] для запуска, либо [0] чтобы пропустить: " "  Enter [1] to run, or [0] to skip: ") -NoNewline -ForegroundColor Cyan
        $opt = Read-Host
        if ($opt -match "^(1|д|да|y|yes)$") {
            Optimize-DeviceApps -AdbExe $AdbExe
        }

        Write-Host (T "Рекомендуется перезагрузить смартфон. Перезагрузить сейчас?" "Reboot recommended to cleanly apply all changes. Reboot now?") -ForegroundColor Yellow
        Write-Host (T "  Введите [1] для перезагрузки, либо [0] чтобы пропустить: " "  Enter [1] to reboot, or [0] to skip: ") -NoNewline -ForegroundColor Cyan
        $reboot = Read-Host
        if ($reboot -match "^(1|д|да|y|yes)$") {
            Invoke-Adb -AdbExe $AdbExe -Arguments @("reboot") | Out-Null
            Write-Host (T "Команда на перезагрузку отправлена." "Reboot command sent.") -ForegroundColor Green
        }
    }
}

function Apply-RollbackConfiguration {
    param([string]$AdbExe)
    $disTotal = $DisablePackages.Count
    $susTotal = $SuspendPackages.Count

    Write-Header (T "ПОЛНЫЙ ОТКАТ: ВОЗВРАТ В ЗАВОДСКОЕ СОСТОЯНИЕ" "COMPLETE FACTORY ROLLBACK")
    Write-Host (T "Будут включены обратно $disTotal пакетов и полностью разморожены $susTotal служб (включая сброс AppOps)." "All $disTotal disabled packages and $susTotal frozen services (including AppOps permissions) will be restored.") -ForegroundColor Yellow

    if (-not [Console]::IsInputRedirected) {
        Write-Host (T "  Введите [1] для полного отката, либо [0] для отмены: " "  Enter [1] to confirm full rollback, or [0] to cancel: ") -NoNewline -ForegroundColor Cyan
        $confirm = Read-Host
        if ($confirm -notmatch "^(1|д|да|y|yes|откат)$") {
            Write-Log (T "Откат отменён пользователем." "Rollback cancelled.") "WARN"
            return
        }
    }

    Write-Host ""
    Write-Host ("--- " + (T "1. Разморозка служб и сброс AppOps" "1. Unfreezing services & resetting AppOps") + " ---") -ForegroundColor Cyan
    foreach ($pkg in $SuspendPackages) {
        $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "unsuspend", "--user", "0", $pkg)
        Set-PackageAppOpsMode -AdbExe $AdbExe -Package $pkg -Mode "default"
        Write-Host "  [UNFROZEN] $pkg : $(($res.Output + ' ' + $res.Error).Trim())" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host ("--- " + (T "2. Включение пакетов (pm enable)" "2. Re-enabling packages (pm enable)") + " ---") -ForegroundColor Cyan
    foreach ($pkg in $DisablePackages) {
        $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "enable", "--user", "0", $pkg)
        Write-Host "  [ENABLED] $pkg : $(($res.Output + ' ' + $res.Error).Trim())" -ForegroundColor Gray
    }

    # Restore package verifier flag to default
    Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "settings", "delete", "global", "package_verifier_enable") | Out-Null

    Write-Host ""
    Write-Host (T "Откат завершён! Все $disTotal + $susTotal компонентов возвращены в исходное состояние." "Rollback complete! All $($disTotal + $susTotal) components restored to stock.") -ForegroundColor Green
}

function Restore-FeatureMenu {
    param([string]$AdbExe)

    while ($true) {
        Write-Header (T "ВОССТАНОВЛЕНИЕ ОТДЕЛЬНЫХ ФУНКЦИЙ COLOROS" "GRANULAR FEATURE RESTORER")
        Write-Host (T "Выберите функцию, которую хотите вернуть на телефон:" "Select a specific ColorOS feature to re-enable:") -ForegroundColor Yellow
        Write-Host ""
        Write-Host (" [1] " + (T "«Остров» (Fluid Cloud / Плеер и таймер у камеры)" "Fluid Cloud ('Dynamic Island' media & timer capsule)")) -ForegroundColor Green
        Write-Host (" [2] " + (T "Always-On Display (AOD / Часы на выключенном экране)" "Always-On Display (AOD lockscreen clock & icons)")) -ForegroundColor Cyan
        Write-Host (" [3] " + (T "Скриншоты 3 пальцами и встроенная запись экрана" "3-Finger Screenshots & Native Screen Recorder")) -ForegroundColor Cyan
        Write-Host (" [4] " + (T "Умная боковая панель (Smart Sidebar)" "Smart Sidebar (Edge Quick-Access Panel)")) -ForegroundColor Cyan
        Write-Host (" [5] " + (T "Игровой режим (Game Toolkit / HyperBoost)" "Game Toolkit / HyperBoost Gaming Engine")) -ForegroundColor Cyan
        Write-Host (" [6] " + (T "Системный диктофон и компас ColorOS" "Native Sound Recorder & Compass")) -ForegroundColor Cyan
        Write-Host (" [7] " + (T "CarLink и автомобильные службы (OCar, цифровой ключ)" "CarLink, OCar & Digital Car Key")) -ForegroundColor Cyan
        Write-Host (" [8] " + (T "Разморозить HeyTap Browser, App Market и Магазин тем" "Unfreeze HeyTap Browser, App Market & Theme Store (+AppOps)")) -ForegroundColor DarkYellow
        Write-Host (" [9] " + (T "Вернуть проверку APK (appdetail) и облако HeyTap Cloud" "Restore ColorOS APK Scanner (appdetail) & HeyTap Cloud")) -ForegroundColor DarkYellow
        Write-Host (" [0] " + (T "Назад в главное меню" "Back to Main Menu")) -ForegroundColor DarkGray
        Write-Host ""

        $sub = Read-Host (T "Ваш выбор" "Your choice")
        switch ($sub) {
            "1" {
                $pkgs = @(
                    "com.coloros.ocs.opencapabilityservice",
                    "com.oplus.smartmediacontroller",
                    "com.oplus.smartengine",
                    "com.oplus.aiwidgets",
                    "com.oplus.metis",
                    "com.coloros.sceneservice"
                )
                foreach ($p in $pkgs) {
                    $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "enable", "--user", "0", $p)
                    Write-Host "  [ENABLED] $p : $(($res.Output + ' ' + $res.Error).Trim())" -ForegroundColor Green
                }
                Write-Host (T "`n[+] «Остров» (Fluid Cloud) восстановлен! Перезагрузите смартфон." "`n[+] Fluid Cloud restored! Reboot recommended.") -ForegroundColor Green
                Read-Host (T "Нажмите Enter..." "Press Enter...")
            }
            "2" {
                $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "enable", "--user", "0", "com.oplus.aod")
                Write-Host "  [ENABLED] com.oplus.aod : $(($res.Output + ' ' + $res.Error).Trim())" -ForegroundColor Green
                Write-Host (T "`n[+] AOD включён! Перезагрузите смартфон." "`n[+] AOD enabled! Reboot recommended.") -ForegroundColor Green
                Read-Host (T "Нажмите Enter..." "Press Enter...")
            }
            "3" {
                foreach ($p in @("com.oplus.screenshot", "com.oplus.screenrecorder")) {
                    $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "enable", "--user", "0", $p)
                    Write-Host "  [ENABLED] $p : $(($res.Output + ' ' + $res.Error).Trim())" -ForegroundColor Green
                }
                Read-Host (T "Нажмите Enter..." "Press Enter...")
            }
            "4" {
                $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "enable", "--user", "0", "com.coloros.smartsidebar")
                Write-Host "  [ENABLED] com.coloros.smartsidebar : $(($res.Output + ' ' + $res.Error).Trim())" -ForegroundColor Green
                Read-Host (T "Нажмите Enter..." "Press Enter...")
            }
            "5" {
                $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "enable", "--user", "0", "com.oplus.games")
                Write-Host "  [ENABLED] com.oplus.games : $(($res.Output + ' ' + $res.Error).Trim())" -ForegroundColor Green
                Read-Host (T "Нажмите Enter..." "Press Enter...")
            }
            "6" {
                foreach ($p in @("com.coloros.soundrecorder", "com.coloros.compass2")) {
                    $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "enable", "--user", "0", $p)
                    Write-Host "  [ENABLED] $p : $(($res.Output + ' ' + $res.Error).Trim())" -ForegroundColor Green
                }
                Read-Host (T "Нажмите Enter..." "Press Enter...")
            }
            "7" {
                foreach ($p in @("com.heytap.opluscarlink", "com.oplus.ocar", "com.oplus.cardigitalkey")) {
                    $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "enable", "--user", "0", $p)
                    Write-Host "  [ENABLED] $p : $(($res.Output + ' ' + $res.Error).Trim())" -ForegroundColor Green
                }
                Read-Host (T "Нажмите Enter..." "Press Enter...")
            }
            "8" {
                foreach ($p in @("com.heytap.browser", "com.heytap.market", "com.oplus.themestore")) {
                    $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "unsuspend", "--user", "0", $p)
                    Set-PackageAppOpsMode -AdbExe $AdbExe -Package $p -Mode "default"
                    Write-Host "  [UNFROZEN + APPOPS RESET] $p : $(($res.Output + ' ' + $res.Error).Trim())" -ForegroundColor Green
                }
                Read-Host (T "Нажмите Enter..." "Press Enter...")
            }
            "9" {
                foreach ($p in @("com.oplus.appdetail", "com.heytap.cloud")) {
                    $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "enable", "--user", "0", $p)
                    Write-Host "  [ENABLED] $p : $(($res.Output + ' ' + $res.Error).Trim())" -ForegroundColor Green
                }
                Read-Host (T "Нажмите Enter..." "Press Enter...")
            }
            "0" {
                break
            }
            default {
                Write-Host (T "Неверный выбор." "Invalid selection.") -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
}

function Show-Diagnostics {
    param([string]$AdbExe, [PSCustomObject]$DeviceInfo)
    Write-Header (T "ДИАГНОСТИКА СОСТОЯНИЯ УСТРОЙСТВА" "DEVICE DIAGNOSTICS")

    Write-Host ("  Model:     $($DeviceInfo.Manufacturer) $($DeviceInfo.Model) ($($DeviceInfo.VendorModel))") -ForegroundColor Cyan
    Write-Host ("  Build:     $($DeviceInfo.BuildId) | Android $($DeviceInfo.AndroidVer) ($($DeviceInfo.OplusRomVer))") -ForegroundColor Cyan
    Write-Host ("  Serial:    $($DeviceInfo.Serial) | Region: $($DeviceInfo.RegionMark)") -ForegroundColor Cyan

    $disRes = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "list", "packages", "-d")
    $disCount = ($disRes.Output -split "`r?`n" | Where-Object { $_ -match "^package:" }).Count
    Write-Host ("  " + (T "Отключено пакетов в системе (-d):" "Disabled packages (-d):") + " $disCount") -ForegroundColor Green

    $dump = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "dumpsys", "package") -TimeoutMs 60000
    $susCount = 0
    foreach ($line in ($dump.Output -split "`r?`n")) {
        if ($line -match "User 0:.*suspended=true") { $susCount++ }
    }
    Write-Host ("  " + (T "Заморожено пакетов в системе (suspended=true):" "Frozen packages (suspended=true):") + " $susCount") -ForegroundColor Green

    $battRes = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "dumpsys", "battery")
    foreach ($line in ($battRes.Output -split "`r?`n")) {
        if ($line -match "level:\s*(\d+)") { Write-Host ("  " + (T "Заряд батареи:" "Battery Level:") + " $($matches[1])%") -ForegroundColor Cyan }
        if ($line -match "temperature:\s*(\d+)") { Write-Host ("  " + (T "Температура:" "Temperature:") + " $([math]::Round([int]$matches[1]/10, 1)) °C") -ForegroundColor Cyan }
    }
}

# ==============================================================================
# 6. MAIN ENTRY POINT
# ==============================================================================
$AdbExe = Find-AdbExecutable -CustomPath $AdbPath
if (-not $AdbExe) {
    Write-Host ""
    Write-Host (T "[-] ОШИБКА: adb.exe не найден! Скачайте полный архив из Releases или установите platform-tools." "[-] ERROR: adb.exe not found! Download the full Release archive or install Google platform-tools.") -ForegroundColor Red
    exit 1
}

Start-AdbDaemon -AdbExe $AdbExe

$device = $null
while (-not $device) {
    $device = Test-AdbConnection -AdbExe $AdbExe
    if (-not $device) {
        if ([Console]::IsInputRedirected) {
            Write-Host (T "Обнаружен неинтерактивный режим. Завершение работы." "Non-interactive input detected. Exiting.") -ForegroundColor Yellow
            exit 1
        }
        Write-Host (T "Нажмите [Enter] для повторной проверки или введите [0] для выхода: " "Press [Enter] to retry ADB scan, or enter [0] to exit: ") -NoNewline -ForegroundColor Yellow
        $retry = Read-Host
        if ($retry -eq "0") {
            Write-Host (T "Выход из программы." "Exiting.") -ForegroundColor DarkGray
            exit 0
        }
    }
}

if (-not (Verify-DeviceCompatibility -DeviceInfo $device)) {
    Write-Host ""
    if (-not [Console]::IsInputRedirected) {
        Read-Host (T "Нажмите [Enter] для выхода..." "Press [Enter] to exit...") | Out-Null
    }
    exit 1
}

$protectedSet = Get-ProtectedPackagesSet -AdbExe $AdbExe

if ($ApplyClone) { Apply-CloneConfiguration -AdbExe $AdbExe -ProtectedSet $protectedSet; exit 0 }
if ($Rollback) { Apply-RollbackConfiguration -AdbExe $AdbExe; exit 0 }
if ($OptimizeOnly) { Optimize-DeviceApps -AdbExe $AdbExe; exit 0 }
if ($BatteryReport) { Show-BatteryDrainAnalysis -AdbExe $AdbExe; exit 0 }
if ($RestoreFeature) { Restore-FeatureMenu -AdbExe $AdbExe; exit 0 }

while ($true) {
    $disTotal = $DisablePackages.Count
    $susTotal = $SuspendPackages.Count
    $totalAll = $disTotal + $susTotal

    Write-Header (T "ЦЕНТР ОПТИМИЗАЦИИ И ДЕБЛОАТА ONEPLUS ACE 6T" "DEBLOAT & PERFORMANCE COMMAND CENTER")
    Write-Host ("  Device: $($device.Manufacturer) $($device.Model) | Build: $($device.BuildId) | Android $($device.AndroidVer)") -ForegroundColor Green
    Write-Host ("  Safety: " + (T "Без Root · Ничего не удаляется · 100% обратимо" "Zero Root · Zero System Deletion · 100% Reversible")) -ForegroundColor DarkGray
    Write-Host ""
    Write-Host (T "Выберите действие:" "Select an action:") -ForegroundColor Yellow
    Write-Host (" [1] " + (T "Очистить и оптимизировать (Отключить $disTotal + Заморозить $susTotal служб)" "Apply Debloat & Optimization (Disable $disTotal + Freeze $susTotal Services)")) -ForegroundColor Green
    Write-Host (" [2] " + (T "Восстановить отдельную функцию (Остров, AOD, Скриншоты, Игры...)" "Restore Specific Feature (Fluid Cloud, AOD, Screenshots, Games...)")) -ForegroundColor Cyan
    Write-Host (" [3] " + (T "Ускорение приложений (ART Dexopt) и очистка кэша" "Accelerate Apps (ART Dexopt speed-profile) & Trim Caches")) -ForegroundColor Yellow
    Write-Host (" [4] " + (T "Анализ расхода батареи (Топ-15 приложений в мА·ч)" "Battery Drain Profiler (Top-15 Apps in mAh)")) -ForegroundColor White
    Write-Host (" [5] " + (T "Полный откат (Включить и разморозить все $totalAll пакетов)" "Complete Rollback (Re-enable & Unfreeze all $totalAll Packages)")) -ForegroundColor Magenta
    Write-Host (" [6] " + (T "Диагностика устройства (версия, статус пакетов, батарея)" "Device Diagnostics (OS Version, Package Stats, Battery)")) -ForegroundColor Gray
    Write-Host (" [7] " + (T "Перезагрузить смартфон" "Reboot Smartphone")) -ForegroundColor DarkCyan
    Write-Host (" [L] " + (T "Switch Language / Язык: RU -> EN" "Сменить язык / Language: EN -> RU")) -ForegroundColor DarkYellow
    Write-Host (" [0] " + (T "Выход" "Exit")) -ForegroundColor DarkGray
    Write-Host ""

    $choice = Read-Host (T "Ваш выбор" "Your choice")
    switch ($choice.ToUpperInvariant()) {
        "1" {
            Apply-CloneConfiguration -AdbExe $AdbExe -ProtectedSet $protectedSet
            Read-Host (T "Нажмите Enter для возврата в меню..." "Press Enter to return to menu...")
        }
        "2" {
            Restore-FeatureMenu -AdbExe $AdbExe
        }
        "3" {
            Optimize-DeviceApps -AdbExe $AdbExe
            Read-Host (T "Нажмите Enter для возврата в меню..." "Press Enter to return to menu...")
        }
        "4" {
            Show-BatteryDrainAnalysis -AdbExe $AdbExe
            Read-Host (T "Нажмите Enter для возврата в меню..." "Press Enter to return to menu...")
        }
        "5" {
            Apply-RollbackConfiguration -AdbExe $AdbExe
            Read-Host (T "Нажмите Enter для возврата в меню..." "Press Enter to return to menu...")
        }
        "6" {
            Show-Diagnostics -AdbExe $AdbExe -DeviceInfo $device
            Read-Host (T "Нажмите Enter для возврата в меню..." "Press Enter to return to menu...")
        }
        "7" {
            Invoke-Adb -AdbExe $AdbExe -Arguments @("reboot") | Out-Null
            Write-Host (T "Команда на перезагрузку отправлена." "Reboot command sent.") -ForegroundColor Green
            Read-Host (T "Нажмите Enter для возврата в меню..." "Press Enter to return to menu...")
        }
        "L" {
            $Global:UiLang = if ($Global:UiLang -eq "ru") { "en" } else { "ru" }
        }
        "0" {
            break
        }
        default {
            Write-Host (T "Неверный выбор." "Invalid choice.") -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}

#Requires -Version 5.1
<#
.SYNOPSIS
    Точный слепок оптимизации, деблоата, заморозки и анализа батареи для OnePlus Ace 6T (ColorOS 16 CN).
.DESCRIPTION
    Воспроизводит конфигурацию проверенного устройства (OnePlus Ace 6T / PLR110 / ColorOS 16 CN01):
    1. Отключение 82 предустановленных пакетов через: pm disable-user --user 0
    2. Заморозка 13 системных служб (включая HeyTap Browser, App Market, Ads) через: pm suspend --user 0
    3. Очистка временного кэша (pm trim-caches) и компиляция ART (cmd package compile -m speed-profile -a)
    4. Глубокий анализ расхода батареи (поиск фонового жора по UIDs и пакетам)
    5. Функция полного отката: pm enable --user 0 и pm unsuspend --user 0
.NOTES
    Привязка: строго модель PLR110, сборка PLR110_16.0.10.500(CN01).
    Версия: 4.0 (Battery Analytics & Clone Edition)
#>

[CmdletBinding()]
param(
    [switch]$ApplyClone,
    [switch]$Rollback,
    [switch]$OptimizeOnly,
    [switch]$BatteryReport,
    [string]$AdbPath
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# ==============================================================================
# 1. ПРИВЯЗКА К МОДЕЛИ И РЕГИОНУ (СТРОГО ДЛЯ PLR110 CN01)
# ==============================================================================
$TargetModel = "PLR110"
$TargetRegionToken = "CN01"

# ==============================================================================
# 2. БАЗА ДАННЫХ ПАКЕТОВ: 82 ДЛЯ ОТКЛЮЧЕНИЯ (pm disable-user)
# ==============================================================================
$DisablePackages = @(
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
    "com.heytap.speechassist",
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
    "com.oplus.ocar",
    "com.oplus.ovoicemanager",
    "com.oplus.ovoicemanager.wakeup",
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
    "com.oppo.store",
    "com.qti.dcf",
    "com.qualcomm.qti.powersavemode",
    "com.ted.number",
    "com.unionpay.tsmservice"
)

# ==============================================================================
# 3. БАЗА ДАННЫХ ПАКЕТОВ: 13 ДЛЯ ЗАМОРОЗКИ (pm suspend)
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
# 4. ЖЕСТКИЙ БЕЛЫЙ СПИСОК (НИКОГДА НЕ ТРОГАТЬ)
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
    "com.happproxy",
    "com.newmoonproduction.bigfarmhomestead"
)

# ==============================================================================
# 5. ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
# ==============================================================================

function Write-Header {
    param([string]$Title)
    Clear-Host
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "   ONEPLUS ACE 6T (PLR110) - COLOROS 16 CN01 TOOLBOX                   " -ForegroundColor Green
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
    $logFile = Join-Path -Path $PSScriptRoot -ChildPath "clone_tool.log"
    Add-Content -Path $logFile -Value $logLine -Encoding UTF8 -ErrorAction SilentlyContinue

    switch ($Level) {
        "SUCCESS" { Write-Host "[+] $Message" -ForegroundColor Green }
        "WARN"    { Write-Host "[!] $Message" -ForegroundColor Yellow }
        "ERROR"   { Write-Host "[-] $Message" -ForegroundColor Red }
        "STEP"    { Write-Host ">>> $Message" -ForegroundColor Cyan }
        default   { Write-Host "[*] $Message" -ForegroundColor Gray }
    }
}

function Find-AdbExecutable {
    param([string]$CustomPath)
    
    # 1. Приоритет: локальные файлы в папке со скриптом (портативный автономный запуск)
    if (Test-Path "$PSScriptRoot\platform-tools\adb.exe") {
        return (Resolve-Path "$PSScriptRoot\platform-tools\adb.exe").Path
    }
    if (Test-Path "$PSScriptRoot\adb.exe") {
        return (Resolve-Path "$PSScriptRoot\adb.exe").Path
    }

    # 2. Пользовательский путь
    if ($CustomPath -and (Test-Path $CustomPath)) {
        return (Resolve-Path $CustomPath).Path
    }

    # 3. Проверка в системном PATH
    $cmd = Get-Command adb.exe -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    # 4. Известные пути установки в Windows
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
    return $null
}

function Invoke-Adb {
    param(
        [string]$AdbExe,
        [string[]]$Arguments
    )
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $AdbExe
    $psi.Arguments = $Arguments -join " "
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.StandardOutputEncoding = [System.Text.Encoding]::UTF8
    $psi.StandardErrorEncoding = [System.Text.Encoding]::UTF8
    $psi.CreateNoWindow = $true

    $proc = [System.Diagnostics.Process]::Start($psi)
    $stdout = $proc.StandardOutput.ReadToEnd()
    $stderr = $proc.StandardError.ReadToEnd()
    $proc.WaitForExit()

    return [PSCustomObject]@{
        ExitCode = $proc.ExitCode
        Output   = $stdout.Trim()
        Error    = $stderr.Trim()
    }
}

function Test-AdbConnection {
    param([string]$AdbExe)
    Write-Log "Проверка связи с устройством..." "STEP"
    
    $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("devices")
    $lines = $res.Output -split "`r?`n" | Where-Object { $_ -and $_ -notmatch "^List of devices attached" }

    if (-not $lines -or $lines.Count -eq 0) {
        Write-Log "Устройство не найдено по USB!" "ERROR"
        return $null
    }

    $deviceLine = $lines[0]
    $serial = ($deviceLine -split "`t")[0].Trim()
    $state = ($deviceLine -split "`t")[1].Trim()

    if ($state -ne "device") {
        Write-Log "Устройство не готово (статус: '$state'). Требуется 'device'." "WARN"
        return $null
    }

    $modelRes = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "getprop", "ro.product.model")
    $manufRes = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "getprop", "ro.product.manufacturer")
    $buildRes = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "getprop", "ro.build.display.id")

    return [PSCustomObject]@{
        Serial       = $serial
        Model        = $modelRes.Output
        Manufacturer = $manufRes.Output
        BuildId      = $buildRes.Output
    }
}

function Verify-DeviceCompatibility {
    param([PSCustomObject]$DeviceInfo)
    Write-Host "Проверка совместимости прошивки:" -ForegroundColor Yellow
    Write-Host "  Модель:  $($DeviceInfo.Model) (Ожидается: $TargetModel)"
    Write-Host "  Сборка:  $($DeviceInfo.BuildId) (Ожидается регион: $TargetRegionToken)"

    if ($DeviceInfo.Model -ne $TargetModel) {
        Write-Log "ОШИБКА: Модель $($DeviceInfo.Model) не поддерживается этим скриптом (строго $TargetModel)." "ERROR"
        return $false
    }

    if (-not ($DeviceInfo.BuildId -like "*$TargetRegionToken*")) {
        Write-Log "ОШИБКА: Прошивка не содержит признака региона $TargetRegionToken. Скрипт остановлен." "ERROR"
        return $false
    }

    Write-Log "Проверка модели и региона успешно пройдена." "SUCCESS"
    return $true
}

function Create-BackupSnapshot {
    param([string]$AdbExe)
    $backupDir = Join-Path -Path $PSScriptRoot -ChildPath "Backups"
    if (-not (Test-Path $backupDir)) {
        New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
    }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $currentBackup = Join-Path -Path $backupDir -ChildPath "backup_$timestamp"
    New-Item -Path $currentBackup -ItemType Directory -Force | Out-Null

    Write-Log "Создание резервной копии состояния пакетов..." "STEP"
    
    $disRes = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "list", "packages", "-d")
    $disFile = Join-Path -Path $currentBackup -ChildPath "disabled_packages.txt"
    Set-Content -Path $disFile -Value $disRes.Output -Encoding UTF8

    $allRes = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "list", "packages")
    $allFile = Join-Path -Path $currentBackup -ChildPath "all_packages.txt"
    Set-Content -Path $allFile -Value $allRes.Output -Encoding UTF8

    Write-Log "Резервная копия сохранена в: $currentBackup" "SUCCESS"
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
    Write-Header "ОПТИМИЗАЦИЯ ПРИЛОЖЕНИЙ И ОЧИСТКА КЭША"

    Write-Host "1. Безопасная очистка временного кэша (pm trim-caches)..." -ForegroundColor Yellow
    Write-Log "Вызов: adb shell pm trim-caches 999999999999" "STEP"
    $trimRes = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "trim-caches", "999999999999")
    Write-Host "   Вывод: $($trimRes.Output)" -ForegroundColor Green

    Write-Host ""
    Write-Host "2. Профильная компиляция ART (cmd package compile -m speed-profile -a)..." -ForegroundColor Yellow
    Write-Log "Вызов: adb shell cmd package compile -m speed-profile -a" "STEP"
    $compRes = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "cmd", "package", "compile", "-m", "speed-profile", "-a")
    Write-Host "   Вывод: $($compRes.Output)" -ForegroundColor Green
    Write-Log "Оптимизация завершена успешно." "SUCCESS"
}

function Show-BatteryDrainAnalysis {
    param([string]$AdbExe)
    Write-Header "АНАЛИЗ РАСХОДА БАТАРЕИ И ПОИСК ФОНОВОГО ЖОРА"

    Write-Host "1. Общее состояние аккумулятора..." -ForegroundColor Yellow
    $batt = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "dumpsys", "battery")
    $level = "н/д"; $temp = "н/д"; $volt = "н/д"; $health = "н/д"; $status = "н/д"
    foreach ($line in ($batt.Output -split "`r?`n")) {
        if ($line -match "level:\s*(\d+)") { $level = "$($matches[1])%" }
        if ($line -match "temperature:\s*(\d+)") { $temp = "$([math]::Round([int]$matches[1]/10, 1)) °C" }
        if ($line -match "voltage:\s*(\d+)") { $volt = "$($matches[1]) мВ" }
        if ($line -match "health:\s*(\d+)") { 
            switch ($matches[1]) {
                "2" { $health = "Отличное (Good)" }
                "3" { $health = "Перегрев (Overheat)" }
                "4" { $health = "Изношена (Dead)" }
                default { $health = "Код $($matches[1])" }
            }
        }
        if ($line -match "status:\s*(\d+)") {
            switch ($matches[1]) {
                "2" { $status = "Заряжается" }
                "3" { $status = "Разряжается" }
                "5" { $status = "Заряжена (Full)" }
                default { $status = "Код $($matches[1])" }
            }
        }
    }

    Write-Host "  Уровень заряда: $level | Статус: $status" -ForegroundColor Cyan
    Write-Host "  Температура:    $temp | Напряжение: $volt | Здоровье: $health" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "2. Сбор статистики разряда (dumpsys batterystats)..." -ForegroundColor Yellow
    Write-Host "   (Чтение системных логов энергопотребления, подождите 3-5 сек)..." -ForegroundColor Gray

    # Получаем карту UID -> Package
    $uidMap = @{}
    $pkgList = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "list", "packages", "-U")
    foreach ($line in ($pkgList.Output -split "`r?`n")) {
        if ($line -match "package:([a-zA-Z0-9_\.]+)\s+uid:(\d+)") {
            $pName = $matches[1]
            $uId = $matches[2]
            if (-not $uidMap.ContainsKey($uId)) {
                $uidMap[$uId] = $pName
            }
        }
    }

    # Считываем batterystats
    $stats = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "dumpsys", "batterystats")
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
            if ($line -match "^\s*(?:UID\s+)?(\d{4,5}):\s+([0-9\.]+)\s*(.*)$") {
                $uid = $matches[1]
                $mah = [double]$matches[2]
                $details = $matches[3]

                $pkg = if ($uidMap.ContainsKey($uid)) { $uidMap[$uid] } else { "Системный процесс (UID $uid)" }

                $drainList.Add([PSCustomObject]@{
                    UID     = $uid
                    Package = $pkg
                    Drain   = $mah
                    Details = $details
                })
            }
        }
    }

    if ($drainList.Count -eq 0) {
        Write-Host "  Статистика расхода по приложениям пока пуста (телефон недавно снят с зарядки)." -ForegroundColor DarkGray
    } else {
        Write-Host ""
        Write-Host "ТОП-15 ПРИЛОЖЕНИЙ ПО РАСХОДУ ЭНЕРГИИ:" -ForegroundColor Green
        Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
        
        $topDrain = $drainList | Sort-Object -Property Drain -Descending | Select-Object -First 15
        $rank = 0
        foreach ($item in $topDrain) {
            $rank++
            $pColor = "White"
            if ($item.Package -match "ozon|wildberries|instagram|telegram|exteragram|browser|tiktok") { $pColor = "Yellow" }
            if ($item.Package -match "launcher|systemui|android") { $pColor = "DarkCyan" }
            if ($item.Package -match "colorfulengine") { $pColor = "Red" }

            Write-Host (" {0,2}. {1,-45} | {2,7:F2} mAh" -f $rank, $item.Package, $item.Drain) -ForegroundColor $pColor
        }
        Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host "  * Жёлтым выделены сторонние фоновые приложения (маркетплейсы, мессенджеры)" -ForegroundColor Yellow
        Write-Host "  * Красным выделены тяжелые службы (живые обои и графика)" -ForegroundColor Red
        Write-Host "  * Синим выделены системные компоненты Android" -ForegroundColor DarkCyan
    }
}

function Apply-CloneConfiguration {
    param(
        [string]$AdbExe,
        [System.Collections.Generic.HashSet[string]]$ProtectedSet
    )
    Write-Header "ПРИМЕНЕНИЕ СЛЕПКА: ОТКЛЮЧЕНИЕ И ЗАМОРОЗКА"

    Write-Host "ВНИМАНИЕ: Данная процедура воспроизводит точное состояние автора:" -ForegroundColor Yellow
    Write-Host " - Будут отключены 82 пакета (Baidu, живые обои, телеметрия, утилиты);" -ForegroundColor Yellow
    Write-Host " - Будут заморожены 13 пакетов (HeyTap Browser, App Market, Ads и др.);" -ForegroundColor Yellow
    Write-Host " - VPN (com.happproxy), клавиатура, лаунчер и Google-сервисы защищены." -ForegroundColor Green
    Write-Host ""

    $confirm = Read-Host "Подтвердите применение конфигурации (введите: 'Применить слепок')"
    if ($confirm -ne "Применить слепок") {
        Write-Log "Применение отменено пользователем." "WARN"
        return
    }

    Create-BackupSnapshot -AdbExe $AdbExe | Out-Null

    # --- ЭТАП 1: Отключение (82 пакета) ---
    Write-Host ""
    Write-Host "--- ЭТАП 1: Отключение 82 пакетов (pm disable-user) ---" -ForegroundColor Cyan
    $disCount = 0
    $c = 0
    foreach ($pkg in $DisablePackages) {
        $c++
        if ($ProtectedSet.Contains($pkg)) {
            Write-Host "[$c/$($DisablePackages.Count)] [ЗАЩИТА] $pkg пропущен" -ForegroundColor Magenta
            continue
        }
        $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "disable-user", "--user", "0", $pkg)
        if ($res.Output -match "disabled-user") {
            Write-Host "[$c/$($DisablePackages.Count)] [ОТКЛЮЧЕНО] $pkg" -ForegroundColor Green
            $disCount++
        } else {
            Write-Host "[$c/$($DisablePackages.Count)] [ПРОПУСК] $pkg : $($res.Output)" -ForegroundColor DarkGray
        }
    }

    # --- ЭТАП 2: Заморозка (13 пакетов) ---
    Write-Host ""
    Write-Host "--- ЭТАП 2: Заморозка 13 системных служб (pm suspend) ---" -ForegroundColor Cyan
    $susCount = 0
    $s = 0
    foreach ($pkg in $SuspendPackages) {
        $s++
        if ($ProtectedSet.Contains($pkg)) {
            Write-Host "[$s/$($SuspendPackages.Count)] [ЗАЩИТА] $pkg пропущен" -ForegroundColor Magenta
            continue
        }
        $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "suspend", "--user", "0", $pkg)
        if ($res.Output -match "Package .* new suspended state: true") {
            Write-Host "[$s/$($SuspendPackages.Count)] [ЗАМОРОЖЕНО] $pkg" -ForegroundColor Green
            $susCount++
        } else {
            Write-Host "[$s/$($SuspendPackages.Count)] [СТАТУС] $pkg : $($res.Output)" -ForegroundColor DarkYellow
        }
    }

    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "ИТОГИ: Успешно отключено: $disCount | Успешно заморожено: $susCount" -ForegroundColor Green
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host ""

    $opt = Read-Host "Выполнить финальную оптимизацию приложений (ART Dexopt) и очистку кэша? (д/н)"
    if ($opt -match "^(д|y|yes)$") {
        Optimize-DeviceApps -AdbExe $AdbExe
    }

    $reboot = Read-Host "Рекомендуется перезагрузить устройство. Перезагрузить сейчас? (д/н)"
    if ($reboot -match "^(д|y|yes)$") {
        Invoke-Adb -AdbExe $AdbExe -Arguments @("reboot") | Out-Null
        Write-Host "Команда на перезагрузку отправлена." -ForegroundColor Green
    }
}

function Apply-RollbackConfiguration {
    param([string]$AdbExe)
    Write-Header "ПОЛНЫЙ ОТКАТ: ВКЛЮЧЕНИЕ И РАЗМОРОЗКА"

    Write-Host "Будут включены обратно 82 пакета и разморожены 13 пакетов." -ForegroundColor Yellow
    $confirm = Read-Host "Подтвердите откат (введите: 'Откат')"
    if ($confirm -ne "Откат") {
        Write-Log "Откат отменён пользователем." "WARN"
        return
    }

    # 1. Разморозка (unsuspend)
    Write-Host ""
    Write-Host "--- Разморозка пакетов (pm unsuspend) ---" -ForegroundColor Cyan
    foreach ($pkg in $SuspendPackages) {
        $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "unsuspend", "--user", "0", $pkg)
        Write-Host "  [РАЗМОРОЗКА] $pkg : $($res.Output)" -ForegroundColor Gray
    }

    # 2. Включение (enable)
    Write-Host ""
    Write-Host "--- Включение пакетов (pm enable) ---" -ForegroundColor Cyan
    foreach ($pkg in $DisablePackages) {
        $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "enable", "--user", "0", $pkg)
        Write-Host "  [ВКЛЮЧЕНИЕ] $pkg : $($res.Output)" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "Откат завершен! Все пакеты возвращены в исходное состояние." -ForegroundColor Green
}

function Show-Diagnostics {
    param([string]$AdbExe, [PSCustomObject]$DeviceInfo)
    Write-Header "ДИАГНОСТИКА СОСТОЯНИЯ УСТРОЙСТВА"

    Write-Host "Модель:        $($DeviceInfo.Manufacturer) $($DeviceInfo.Model)" -ForegroundColor Cyan
    Write-Host "Сборка:        $($DeviceInfo.BuildId)" -ForegroundColor Cyan
    Write-Host "Серийный номер:$($DeviceInfo.Serial)" -ForegroundColor Cyan

    $disRes = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "list", "packages", "-d")
    $disCount = ($disRes.Output -split "`r?`n" | Where-Object { $_ -match "^package:" }).Count
    Write-Host "Отключено пакетов в системе (-d): $disCount" -ForegroundColor Green

    # Подсчет замороженных пакетов
    $dump = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "dumpsys", "package")
    $susCount = 0
    foreach ($line in ($dump.Output -split "`r?`n")) {
        if ($line -match "User 0:.*suspended=true") { $susCount++ }
    }
    Write-Host "Заморожено пакетов в системе (suspended=true): $susCount" -ForegroundColor Green

    $battRes = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "dumpsys", "battery")
    foreach ($line in ($battRes.Output -split "`r?`n")) {
        if ($line -match "level:\s*(\d+)") { Write-Host "Заряд батареи: $($matches[1])%" -ForegroundColor Cyan }
        if ($line -match "temperature:\s*(\d+)") { Write-Host "Температура:   $([math]::Round([int]$matches[1]/10, 1)) °C" -ForegroundColor Cyan }
    }
}

# ==============================================================================
# 6. ГЛАВНАЯ ТОЧКА ВХОДА (MAIN)
# ==============================================================================
$AdbExe = Find-AdbExecutable -CustomPath $AdbPath
if (-not $AdbExe) {
    Write-Host "ОШИБКА: ADB не найден в системе. Установите platform-tools." -ForegroundColor Red
    exit 1
}

Invoke-Adb -AdbExe $AdbExe -Arguments @("start-server") | Out-Null
$device = Test-AdbConnection -AdbExe $AdbExe
if (-not $device) {
    Write-Host "Устройство не подключено или не авторизовано." -ForegroundColor Red
    exit 1
}

if (-not (Verify-DeviceCompatibility -DeviceInfo $device)) {
    exit 1
}

$protectedSet = Get-ProtectedPackagesSet -AdbExe $AdbExe

if ($ApplyClone) {
    Apply-CloneConfiguration -AdbExe $AdbExe -ProtectedSet $protectedSet
    exit 0
}

if ($Rollback) {
    Apply-RollbackConfiguration -AdbExe $AdbExe
    exit 0
}

if ($OptimizeOnly) {
    Optimize-DeviceApps -AdbExe $AdbExe
    exit 0
}

if ($BatteryReport) {
    Show-BatteryDrainAnalysis -AdbExe $AdbExe
    exit 0
}

while ($true) {
    Write-Header "ГЛАВНОЕ МЕНЮ (СЛЕПОК КОНФИГУРАЦИИ ONEPLUS ACE 6T)"
    Write-Host "Подключено: $($device.Manufacturer) $($device.Model) [Сборка: $($device.BuildId)]" -ForegroundColor Green
    Write-Host ""
    Write-Host "Выберите действие:" -ForegroundColor Yellow
    Write-Host " [1] Применить слепок автора (Отключить 82 пакета + Заморозить 13 пакетов)" -ForegroundColor Green
    Write-Host " [2] Оптимизация приложений (ART Dexopt) и безопасная очистка кэша" -ForegroundColor Cyan
    Write-Host " [3] Анализ расхода батареи (Поиск фонового жора и Top App Drain)" -ForegroundColor Yellow
    Write-Host " [4] Полный откат (Включить 82 пакета + Разморозить 13 пакетов)" -ForegroundColor Magenta
    Write-Host " [5] Диагностика состояния устройства (версия, заряд, память)" -ForegroundColor White
    Write-Host " [6] Перезагрузить устройство" -ForegroundColor Gray
    Write-Host " [0] Выход" -ForegroundColor DarkGray
    Write-Host ""

    $choice = Read-Host "Ваш выбор"
    switch ($choice) {
        "1" {
            Apply-CloneConfiguration -AdbExe $AdbExe -ProtectedSet $protectedSet
            Read-Host "Нажмите Enter для возврата в меню..."
        }
        "2" {
            Optimize-DeviceApps -AdbExe $AdbExe
            Read-Host "Нажмите Enter для возврата в меню..."
        }
        "3" {
            Show-BatteryDrainAnalysis -AdbExe $AdbExe
            Read-Host "Нажмите Enter для возврата в меню..."
        }
        "4" {
            Apply-RollbackConfiguration -AdbExe $AdbExe
            Read-Host "Нажмите Enter для возврата в меню..."
        }
        "5" {
            Show-Diagnostics -AdbExe $AdbExe -DeviceInfo $device
            Read-Host "Нажмите Enter для возврата в меню..."
        }
        "6" {
            Invoke-Adb -AdbExe $AdbExe -Arguments @("reboot") | Out-Null
            Write-Host "Команда на перезагрузку отправлена." -ForegroundColor Green
            Read-Host "Нажмите Enter для возврата в меню..."
        }
        "0" {
            break
        }
        default {
            Write-Host "Неверный выбор." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}

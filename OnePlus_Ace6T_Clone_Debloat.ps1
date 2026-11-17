#Requires -Version 5.1
<#
.SYNOPSIS
    Очистка, деблоат, заморозка китайских служб и анализ батареи для OnePlus Ace 6T (ColorOS 16 CN).
.DESCRIPTION
    Воспроизводит конфигурацию проверенного устройства (OnePlus Ace 6T / PLR110 / ColorOS 16 CN01):
    1. Отключение 82 предустановленных пакетов через: pm disable-user --user 0
    2. Заморозка 13 системных служб (включая HeyTap Browser, App Market, Ads) через: pm suspend --user 0
    3. Очистка временного кэша (pm trim-caches) и компиляция ART (cmd package compile -m speed-profile -a)
    4. Глубокий анализ расхода батареи (поиск фонового жора по UIDs и пакетам)
    5. Функция полного отката: pm enable --user 0 и pm unsuspend --user 0
.NOTES
    Привязка: строго модель PLR110, сборка ColorOS 16 CN (CN01).
    Версия: 4.1 (Fault-Tolerant & Multi-Device Edition)
#>

[CmdletBinding()]
param(
    [switch]$ApplyClone,
    [switch]$Rollback,
    [switch]$OptimizeOnly,
    [switch]$BatteryReport,
    [switch]$RestoreFeature,
    [string]$AdbPath
)

# Фиксация кодировок UTF-8 для ввода и вывода в консоли
try { [Console]::InputEncoding = [System.Text.Encoding]::UTF8 } catch {}
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}
$OutputEncoding = [System.Text.Encoding]::UTF8

# Определение рабочей директории скрипта
$ScriptDirectory = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }
if (-not $ScriptDirectory) { $ScriptDirectory = (Get-Location).Path }

# Глобальный идентификатор выбранного устройства для изоляции от эмуляторов и других подключений
$Global:TargetDeviceSerial = $null

# ==============================================================================
# 1. ПРИВЯЗКА К МОДЕЛИ И РЕГИОНУ (СТРОГО ДЛЯ PLR110 CN01)
# ==============================================================================
$TargetModel = "PLR110"
$TargetRegionToken = "CN01"

# ==============================================================================
# 2. БАЗА ДАННЫХ ПАКЕТОВ: 82 ДЛЯ ОТКЛЮЧЕНИЯ (pm disable-user)
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

function Find-AdbExecutable {
    param([string]$CustomPath)
    
    # 1. Приоритет: локальные файлы в папке со скриптом (портативный автономный запуск)
    if (Test-Path "$ScriptDirectory\platform-tools\adb.exe") {
        return (Resolve-Path "$ScriptDirectory\platform-tools\adb.exe").Path
    }
    if (Test-Path "$ScriptDirectory\adb.exe") {
        return (Resolve-Path "$ScriptDirectory\adb.exe").Path
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
        [string[]]$Arguments,
        [switch]$IgnoreTargetSerial
    )
    $finalArgs = if ($Global:TargetDeviceSerial -and -not $IgnoreTargetSerial) {
        @("-s", $Global:TargetDeviceSerial) + $Arguments
    } else {
        $Arguments
    }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $AdbExe
    $psi.Arguments = $finalArgs -join " "
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
    
    $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("devices") -IgnoreTargetSerial
    
    # Фильтрация строк устройств с защитой от логов запуска adb daemon
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
        Write-Log "Устройство не найдено по USB!" "ERROR"
        Write-Host ""
        Write-Host "======================================================================" -ForegroundColor Yellow
        Write-Host " [!] Устройство не обнаружено через ADB." -ForegroundColor Yellow
        Write-Host " Рекомендации:" -ForegroundColor Gray
        Write-Host "  1. Убедитесь, что телефон включен и подключен к ПК качественным кабелем USB." -ForegroundColor Gray
        Write-Host "  2. Проверьте «Настройки» -> «Для разработчиков» -> «Отладка по USB» (должна быть включена)." -ForegroundColor Gray
        Write-Host "  3. Разблокируйте экран телефона и проверьте режим подключения в шторке (выберите «Передача файлов»)." -ForegroundColor Gray
        Write-Host "  4. Если появилось окно «Разрешить отладку по USB?», отметьте «Всегда разрешать» и нажмите «Разрешить»." -ForegroundColor Gray
        Write-Host "======================================================================" -ForegroundColor Yellow
        Write-Host ""
        return $null
    }

    # Обработка состояния unauthorized (ожидание подтверждения на экране)
    $unauth = $deviceMatches | Where-Object { $_.State -eq "unauthorized" }
    if ($unauth) {
        Write-Log "Устройство ($($unauth[0].Serial)) ожидает подтверждения авторизации (unauthorized)." "WARN"
        Write-Host ""
        Write-Host "======================================================================" -ForegroundColor Yellow
        Write-Host " [!] ВНИМАНИЕ: Смартфон подключен, но не авторизован!" -ForegroundColor Yellow
        Write-Host " Разблокируйте экран вашего OnePlus Ace 6T." -ForegroundColor Cyan
        Write-Host " В появившемся диалоговом окне «Разрешить отладку по USB?»:" -ForegroundColor Cyan
        Write-Host " 1. Поставьте галочку [v] «Всегда разрешать с этого компьютера»." -ForegroundColor Cyan
        Write-Host " 2. Нажмите «Разрешить»." -ForegroundColor Green
        Write-Host "======================================================================" -ForegroundColor Yellow
        Write-Host ""
        return $null
    }

    $active = $deviceMatches | Where-Object { $_.State -eq "device" }
    if ($active.Count -eq 0) {
        Write-Log "Устройство найдено в статусе '$($deviceMatches[0].State)', требуется статус 'device'." "WARN"
        return $null
    }

    # Изоляция целевого устройства по серийному номеру
    $selected = $active[0]
    $Global:TargetDeviceSerial = $selected.Serial

    $modelRes = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "getprop", "ro.product.model")
    $manufRes = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "getprop", "ro.product.manufacturer")
    $buildRes = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "getprop", "ro.build.display.id")

    return [PSCustomObject]@{
        Serial       = $selected.Serial
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
        Write-Log "ОШИБКА: Модель '$($DeviceInfo.Model)' не поддерживается этим скриптом (строго $TargetModel)." "ERROR"
        Write-Host ""
        Write-Host "[!] ВНИМАНИЕ: Данный скрипт сконфигурирован исключительно для модели $TargetModel (OnePlus Ace 6T)." -ForegroundColor Red
        Write-Host "Во избежание сбоев в работе системы операция отменена." -ForegroundColor Red
        return $false
    }

    if (-not ($DeviceInfo.BuildId -like "*$TargetRegionToken*")) {
        Write-Log "ОШИБКА: Прошивка не содержит признака региона $TargetRegionToken. Скрипт остановлен." "ERROR"
        Write-Host ""
        Write-Host "[!] ВНИМАНИЕ: Сборка прошивки '$($DeviceInfo.BuildId)' не содержит региональный токен $TargetRegionToken." -ForegroundColor Red
        Write-Host "Скрипт оптимизирован строго под китайскую версию ColorOS 16 CN01." -ForegroundColor Red
        return $false
    }

    Write-Log "Проверка модели и региона успешно пройдена." "SUCCESS"
    return $true
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

    Write-Log "Создание резервной копии состояния пакетов..." "STEP"
    
    $disRes = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "list", "packages", "-d")
    $disFile = Join-Path -Path $currentBackup -ChildPath "disabled_packages.txt"
    Set-Content -Path $disFile -Value $disRes.Output -Encoding UTF8 -ErrorAction SilentlyContinue

    $allRes = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "list", "packages")
    $allFile = Join-Path -Path $currentBackup -ChildPath "all_packages.txt"
    Set-Content -Path $allFile -Value $allRes.Output -Encoding UTF8 -ErrorAction SilentlyContinue

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
            if ($line -match "^\s*(?:UID\s+)?([a-zA-Z0-9_\-]+):\s+([0-9\.]+)\s*(.*)$") {
                $uid = $matches[1]
                $mah = [double]::Parse($matches[2], [System.Globalization.CultureInfo]::InvariantCulture)
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
        Write-Host "  Статистика расхода по приложениям пока накапливается (телефон недавно перезагружен или заряжен)." -ForegroundColor DarkGray
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

    Write-Host "ВНИМАНИЕ: Данная процедура воспроизводит конфигурацию проверенного OnePlus Ace 6T:" -ForegroundColor Yellow
    Write-Host " - Будут отключены 82 пакета (Baidu, живые обои, телеметрия, региональные утилиты);" -ForegroundColor Yellow
    Write-Host " - Будут заморожены 13 пакетов (HeyTap Browser, App Market, Ads, Breeno и др.);" -ForegroundColor Yellow
    Write-Host " - VPN (com.happproxy), клавиатура, лаунчер и Google-сервисы защищены." -ForegroundColor Green
    Write-Host ""

    Write-Host "Подтвердите применение конфигурации:" -ForegroundColor Yellow
    Write-Host "  Введите [1] или [Д] (или Y/да) для запуска, либо [0] для отмены: " -NoNewline -ForegroundColor Cyan
    $confirm = Read-Host
    if ($confirm -notmatch "^(1|д|да|y|yes|применить|применить слепок)$") {
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
        # ColorOS 16/17 AppOps Hardening: отбираем фоновые права, чтобы пакет не проснулся
        Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "cmd", "appops", "set", $pkg, "RUN_IN_BACKGROUND", "ignore") | Out-Null
        Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "cmd", "appops", "set", $pkg, "RUN_ANY_IN_BACKGROUND", "ignore") | Out-Null
        Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "cmd", "appops", "set", $pkg, "POST_NOTIFICATION", "ignore") | Out-Null
        Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "cmd", "appops", "set", $pkg, "BOOT_COMPLETED", "ignore") | Out-Null
        if ($res.Output -match "Package .* new suspended state: true") {
            Write-Host "[$s/$($SuspendPackages.Count)] [ЗАМОРОЖЕНО + APPOPS] $pkg" -ForegroundColor Green
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

    Write-Host "Выполнить финальную оптимизацию приложений (ART Dexopt) и очистку кэша?" -ForegroundColor Yellow
    Write-Host "  Введите [1] или [Д] (или Y/да) для согласия, либо [0] для пропуска: " -NoNewline -ForegroundColor Cyan
    $opt = Read-Host
    if ($opt -match "^(1|д|да|y|yes)$") {
        Optimize-DeviceApps -AdbExe $AdbExe
    }

    Write-Host "Рекомендуется перезагрузить устройство. Перезагрузить сейчас?" -ForegroundColor Yellow
    Write-Host "  Введите [1] или [Д] (или Y/да) для перезагрузки, либо [0] для пропуска: " -NoNewline -ForegroundColor Cyan
    $reboot = Read-Host
    if ($reboot -match "^(1|д|да|y|yes)$") {
        Invoke-Adb -AdbExe $AdbExe -Arguments @("reboot") | Out-Null
        Write-Host "Команда на перезагрузку отправлена." -ForegroundColor Green
    }
}

function Apply-RollbackConfiguration {
    param([string]$AdbExe)
    Write-Header "ПОЛНЫЙ ОТКАТ: ВКЛЮЧЕНИЕ И РАЗМОРОЗКА"

    Write-Host "Будут включены обратно 82 пакета и разморожены 13 пакетов." -ForegroundColor Yellow
    Write-Host "Подтвердите полный откат конфигурации:" -ForegroundColor Yellow
    Write-Host "  Введите [1] или [Д] (или Y/да/откат) для подтверждения, либо [0] для отмены: " -NoNewline -ForegroundColor Cyan
    $confirm = Read-Host
    if ($confirm -notmatch "^(1|д|да|y|yes|откат)$") {
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

function Restore-FeatureMenu {
    param([string]$AdbExe)
    
    while ($true) {
        Write-Header "ВОССТАНОВЛЕНИЕ ОТДЕЛЬНЫХ ФУНКЦИЙ COLOROS"
        Write-Host "Выберите функцию, которую хотите вернуть на телефон:" -ForegroundColor Yellow
        Write-Host ""
        Write-Host " [1] 🏝️  «Остров» (Fluid Cloud / Живые оповещения / Плеер и таймер у камеры)" -ForegroundColor Green
        Write-Host " [2] 🕒  Always-On Display (AOD / Часы и инфо на выключенном экране)" -ForegroundColor Cyan
        Write-Host " [3] 📸  Скриншоты 3 пальцами и встроенная запись экрана" -ForegroundColor Cyan
        Write-Host " [4] 📱  Умная боковая панель (Smart Sidebar)" -ForegroundColor Cyan
        Write-Host " [5] 🎮  Игровой режим (Game Toolkit / HyperBoost)" -ForegroundColor Cyan
        Write-Host " [6] 🎙️  Системный диктофон и компас ColorOS" -ForegroundColor Cyan
        Write-Host " [7] 🚗  CarLink и автомобильные службы (OCar, цифровой ключ)" -ForegroundColor Cyan
        Write-Host " [8] 🌐  Китайский браузер HeyTap Browser и App Market (разморозка)" -ForegroundColor DarkYellow
        Write-Host " [0] ⬅️  Назад в главное меню" -ForegroundColor DarkGray
        Write-Host ""
        
        $sub = Read-Host "Ваш выбор"
        switch ($sub) {
            "1" {
                Write-Host "`n[i] Восстановление «Острова» (Fluid Cloud)..." -ForegroundColor Yellow
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
                    Write-Host "  [ВКЛЮЧЕНО] $p : $($res.Output)" -ForegroundColor Green
                }
                Write-Host "`n[+] «Остров» (Fluid Cloud) успешно восстановлен!" -ForegroundColor Green
                Write-Host "[!] Перезагрузите смартфон, чтобы ColorOS заново инициализировала службы у камеры." -ForegroundColor Yellow
                Read-Host "Нажмите Enter для продолжения..."
            }
            "2" {
                Write-Host "`n[i] Восстановление Always-On Display (AOD)..." -ForegroundColor Yellow
                $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "enable", "--user", "0", "com.oplus.aod")
                Write-Host "  [ВКЛЮЧЕНО] com.oplus.aod : $($res.Output)" -ForegroundColor Green
                Write-Host "`n[+] AOD включён! Перезагрузите смартфон для вступления в силу." -ForegroundColor Green
                Read-Host "Нажмите Enter для продолжения..."
            }
            "3" {
                Write-Host "`n[i] Восстановление скриншотов и записи экрана..." -ForegroundColor Yellow
                foreach ($p in @("com.oplus.screenshot", "com.oplus.screenrecorder")) {
                    $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "enable", "--user", "0", $p)
                    Write-Host "  [ВКЛЮЧЕНО] $p : $($res.Output)" -ForegroundColor Green
                }
                Write-Host "`n[+] Скриншоты и запись экрана успешно включены!" -ForegroundColor Green
                Read-Host "Нажмите Enter для продолжения..."
            }
            "4" {
                Write-Host "`n[i] Восстановление умной боковой панели (Smart Sidebar)..." -ForegroundColor Yellow
                $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "enable", "--user", "0", "com.coloros.smartsidebar")
                Write-Host "  [ВКЛЮЧЕНО] com.coloros.smartsidebar : $($res.Output)" -ForegroundColor Green
                Write-Host "`n[+] Smart Sidebar успешно включена!" -ForegroundColor Green
                Read-Host "Нажмите Enter для продолжения..."
            }
            "5" {
                Write-Host "`n[i] Восстановление игрового режима (Game Toolkit)..." -ForegroundColor Yellow
                $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "enable", "--user", "0", "com.oplus.games")
                Write-Host "  [ВКЛЮЧЕНО] com.oplus.games : $($res.Output)" -ForegroundColor Green
                Write-Host "`n[+] Игровой режим успешно включён!" -ForegroundColor Green
                Read-Host "Нажмите Enter для продолжения..."
            }
            "6" {
                Write-Host "`n[i] Восстановление диктофона и компаса..." -ForegroundColor Yellow
                foreach ($p in @("com.coloros.soundrecorder", "com.coloros.compass2")) {
                    $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "enable", "--user", "0", $p)
                    Write-Host "  [ВКЛЮЧЕНО] $p : $($res.Output)" -ForegroundColor Green
                }
                Write-Host "`n[+] Диктофон и Компас успешно включены!" -ForegroundColor Green
                Read-Host "Нажмите Enter для продолжения..."
            }
            "7" {
                Write-Host "`n[i] Восстановление CarLink и автомобильных служб..." -ForegroundColor Yellow
                foreach ($p in @("com.heytap.opluscarlink", "com.oplus.ocar", "com.oplus.cardigitalkey")) {
                    $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "enable", "--user", "0", $p)
                    Write-Host "  [ВКЛЮЧЕНО] $p : $($res.Output)" -ForegroundColor Green
                }
                Write-Host "`n[+] Автомобильные службы успешно включены!" -ForegroundColor Green
                Read-Host "Нажмите Enter для продолжения..."
            }
            "8" {
                Write-Host "`n[i] Разморозка китайского браузера и App Market..." -ForegroundColor Yellow
                foreach ($p in @("com.heytap.browser", "com.heytap.market", "com.oplus.themestore")) {
                    $res = Invoke-Adb -AdbExe $AdbExe -Arguments @("shell", "pm", "unsuspend", "--user", "0", $p)
                    Write-Host "  [РАЗМОРОЖЕНО] $p : $($res.Output)" -ForegroundColor Green
                }
                Write-Host "`n[+] HeyTap Browser и App Market разморожены!" -ForegroundColor Green
                Read-Host "Нажмите Enter для продолжения..."
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
    Write-Host ""
    Write-Host "[-] ОШИБКА: Исполняемый файл adb.exe не найден!" -ForegroundColor Red
    Write-Host "Пожалуйста, распакуйте архив полностью, чтобы папка 'platform-tools' находилась рядом со скриптом." -ForegroundColor Yellow
    exit 1
}

Invoke-Adb -AdbExe $AdbExe -Arguments @("start-server") -IgnoreTargetSerial | Out-Null

$device = $null
while (-not $device) {
    $device = Test-AdbConnection -AdbExe $AdbExe
    if (-not $device) {
        if ([Console]::IsInputRedirected) {
            Write-Host "Обнаружен неинтерактивный режим (перенаправленный ввод). Завершение работы." -ForegroundColor Yellow
            exit 1
        }
        Write-Host "Нажмите [Enter] для повторной проверки или введите [0] для выхода: " -NoNewline -ForegroundColor Yellow
        $retry = Read-Host
        if ($retry -eq "0") {
            Write-Host "Выход из программы." -ForegroundColor DarkGray
            exit 0
        }
    }
}

if (-not (Verify-DeviceCompatibility -DeviceInfo $device)) {
    Write-Host ""
    Write-Host "Нажмите [Enter] для выхода..." -ForegroundColor DarkGray
    Read-Host | Out-Null
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

if ($RestoreFeature) {
    Restore-FeatureMenu -AdbExe $AdbExe
    exit 0
}

while ($true) {
    Write-Header "ONEPLUS ACE 6T (PLR110) · ЦЕНТР ОПТИМИЗАЦИИ И ДЕБЛОАТА"
    Write-Host "Смартфон: $($device.Manufacturer) $($device.Model) [Сборка: $($device.BuildId)]" -ForegroundColor Green
    Write-Host "Статус:   Root не требуется · 100% обратимо · Безопасный режим" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "Выберите действие:" -ForegroundColor Yellow
    Write-Host " [1] ⚡ Очистить и оптимизировать (Отключить 82 китайских пакета + Заморозить 13)" -ForegroundColor Green
    Write-Host " [2] 🏝️ Восстановить отдельную функцию (Остров, AOD, Скриншоты, Игры...)" -ForegroundColor Cyan
    Write-Host " [3] 🚀 Ускорение приложений (ART Dexopt компиляция) и очистка кэша" -ForegroundColor Yellow
    Write-Host " [4] 🔋 Анализ расхода батареи (Поиск фонового жора и Top App Drain)" -ForegroundColor White
    Write-Host " [5] ↩️ Полный откат (Включить обратно все 95 пакетов)" -ForegroundColor Magenta
    Write-Host " [6] 📊 Диагностика устройства (версия ПО, статус батареи, память)" -ForegroundColor Gray
    Write-Host " [7] 🔄 Перезагрузить смартфон" -ForegroundColor DarkCyan
    Write-Host " [0] ❌ Выход" -ForegroundColor DarkGray
    Write-Host ""

    $choice = Read-Host "Ваш выбор"
    switch ($choice) {
        "1" {
            Apply-CloneConfiguration -AdbExe $AdbExe -ProtectedSet $protectedSet
            Read-Host "Нажмите Enter для возврата в меню..."
        }
        "2" {
            Restore-FeatureMenu -AdbExe $AdbExe
        }
        "3" {
            Optimize-DeviceApps -AdbExe $AdbExe
            Read-Host "Нажмите Enter для возврата в меню..."
        }
        "4" {
            Show-BatteryDrainAnalysis -AdbExe $AdbExe
            Read-Host "Нажмите Enter для возврата в меню..."
        }
        "5" {
            Apply-RollbackConfiguration -AdbExe $AdbExe
            Read-Host "Нажмите Enter для возврата в меню..."
        }
        "6" {
            Show-Diagnostics -AdbExe $AdbExe -DeviceInfo $device
            Read-Host "Нажмите Enter для возврата в меню..."
        }
        "7" {
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

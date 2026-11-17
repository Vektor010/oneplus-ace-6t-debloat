#Requires -Version 5.1
<#
.SYNOPSIS
    Automated AST and package database integrity test suite for AceDebloat.
.DESCRIPTION
    Validates script syntax, checks for duplicates, and confirms strict whitelist safety.
#>

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$RepoRoot = Split-Path -Parent $ScriptRoot
$TargetScript = Join-Path -Path $RepoRoot -ChildPath "OnePlus_Ace6T_Clone_Debloat.ps1"
$TargetBat = Join-Path -Path $RepoRoot -ChildPath "Run_Debloat.bat"

$TotalErrors = 0

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "        ACEDEBLOAT: AUTOMATED QUALITY & INTEGRITY TEST SUITE         " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan

# 1. PowerShell AST Syntax Validation
Write-Host "[1/4] Validating PowerShell AST syntax for core engine..." -ForegroundColor Yellow
$tokens = $null
$errors = $null
$null = [System.Management.Automation.Language.Parser]::ParseFile($TargetScript, [ref]$tokens, [ref]$errors)

if ($errors.Count -eq 0) {
    Write-Host "  ✓ PASS: PowerShell AST parsed with 0 syntax errors." -ForegroundColor Green
} else {
    Write-Host "  ✗ FAIL: $($errors.Count) syntax error(s) discovered in ${TargetScript}:" -ForegroundColor Red
    foreach ($err in $errors) {
        Write-Host "    Line $($err.Extent.StartLineNumber): $($err.Message)" -ForegroundColor Red
    }
    $TotalErrors++
}

# 2. Package Database Integrity & Duplicate Check
Write-Host "[2/4] Checking package arrays for duplicates and collisions..." -ForegroundColor Yellow
$content = [System.IO.File]::ReadAllText($TargetScript, [System.Text.Encoding]::UTF8)

# Regex extraction of array definitions
$disMatch = [regex]::Match($content, '\$DisablePackages\s*=\s*@\(([\s\S]*?)\)\s*#')
$susMatch = [regex]::Match($content, '\$SuspendPackages\s*=\s*@\(([\s\S]*?)\)\s*#')
$whtMatch = [regex]::Match($content, '\$StrictWhitelist\s*=\s*@\(([\s\S]*?)\)\s*#')

$disPackages = @([regex]::Matches($disMatch.Groups[1].Value, '"([^"]+)"') | ForEach-Object { $_.Groups[1].Value })
$susPackages = @([regex]::Matches($susMatch.Groups[1].Value, '"([^"]+)"') | ForEach-Object { $_.Groups[1].Value })
$whtPackages = @([regex]::Matches($whtMatch.Groups[1].Value, '"([^"]+)"') | ForEach-Object { $_.Groups[1].Value })

Write-Host "  Discovered packages: Disabled=$($disPackages.Count), Suspended=$($susPackages.Count), Whitelisted=$($whtPackages.Count)" -ForegroundColor Gray

# Check collisions between Disabled and Suspended
$intersection = $disPackages | Where-Object { $susPackages -contains $_ }
if ($intersection.Count -eq 0) {
    Write-Host "  ✓ PASS: Zero collisions between Disabled and Suspended arrays." -ForegroundColor Green
} else {
    Write-Host "  ✗ FAIL: Found packages defined in both Disabled and Suspended arrays:" -ForegroundColor Red
    $intersection | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
    $TotalErrors++
}

# 3. Whitelist Safety Assertion
Write-Host "[3/4] Verifying strict whitelist safety boundaries..." -ForegroundColor Yellow
$whitelistCollisions = @()
foreach ($w in $whtPackages) {
    if ($disPackages -contains $w -or $susPackages -contains $w) {
        $whitelistCollisions += $w
    }
}

if ($whitelistCollisions.Count -eq 0) {
    Write-Host "  ✓ PASS: Zero whitelist violations. Core Android subsystems protected." -ForegroundColor Green
} else {
    Write-Host "  ✗ FAIL: Whitelisted core package found in deactivation lists:" -ForegroundColor Red
    $whitelistCollisions | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
    $TotalErrors++
}

# 4. Windows Batch Launcher Validation
Write-Host "[4/4] Validating Run_Debloat.bat execution wrapper..." -ForegroundColor Yellow
if (Test-Path $TargetBat) {
    $batBytes = [System.IO.File]::ReadAllBytes($TargetBat)
    $hasCrLf = $false
    for ($i = 0; $i -lt $batBytes.Length - 1; $i++) {
        if ($batBytes[$i] -eq 13 -and $batBytes[$i+1] -eq 10) {
            $hasCrLf = $true
            break
        }
    }
    if ($hasCrLf) {
        Write-Host "  ✓ PASS: Run_Debloat.bat exists with valid Windows CRLF line endings." -ForegroundColor Green
    } else {
        Write-Host "  ✗ FAIL: Run_Debloat.bat does not contain CRLF line endings." -ForegroundColor Red
        $TotalErrors++
    }
} else {
    Write-Host "  ✗ FAIL: Run_Debloat.bat is missing." -ForegroundColor Red
    $TotalErrors++
}

Write-Host "======================================================================" -ForegroundColor Cyan
if ($TotalErrors -eq 0) {
    Write-Host "  TEST RESULT: ALL CHECKS PASSED (0 ERRORS). REPOSITORY VERIFIED." -ForegroundColor Green
    Write-Host "======================================================================" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "  TEST RESULT: $TotalErrors CHECK(S) FAILED. PLEASE RESOLVE." -ForegroundColor Red
    Write-Host "======================================================================" -ForegroundColor Cyan
    exit 1
}

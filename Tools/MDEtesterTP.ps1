# MDE Tester banner  
Write-Host "+=====================================================================================================+`n"
Write-Host ""
Write-Host "███╗░░░███╗██████╗░███████╗  ████████╗███████╗░██████╗████████╗███████╗██████╗░"
Write-Host "████╗░████║██╔══██╗██╔════╝  ╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝██╔════╝██╔══██╗"
Write-Host "██╔████╔██║██║░░██║█████╗░░  ░░░██║░░░█████╗░░╚█████╗░░░░██║░░░█████╗░░██████╔╝"
Write-Host "██║╚██╔╝██║██║░░██║██╔══╝░░  ░░░██║░░░██╔══╝░░░╚═══██╗░░░██║░░░██╔══╝░░██╔══██╗"
Write-Host "██║░╚═╝░██║██████╔╝███████╗  ░░░██║░░░███████╗██████╔╝░░░██║░░░███████╗██║░░██║"
Write-Host "╚═╝░░░░░╚═╝╚═════╝░╚══════╝  ░░░╚═╝░░░╚══════╝╚═════╝░░░░╚═╝░░░╚══════╝╚═╝░░╚═╝"
Write-Host ""
Write-Host "                         By Kijo Ninja (@kj_ninja25)"
Write-Host "                              Version : 1.0.0"
# MDE Tester introduction 
$intro = @"
MDE Tester is designed to help testing various features in Microsoft Defender for Endpoint.
'MDEtesterTP.ps1' is intended to assist in testing the following features: 
  - Tamper Protection
  - Tamper Protection, Antivirus Exclusions
"@

Write-Host "`n"
Write-Host $intro
Write-Host ""
Write-Host "+=====================================================================================================+"
Write-Host "Confirm Tamper Protection status"
# Confirm Microsoft Defender Antivirus Tamper Protection status
$avStatus = Get-MpComputerStatus
$tpStatus = $avStatus.IsTamperProtected
$tpManage = $avStatus.TamperProtectionSource

# Confirm if Tamper Protection is enabled or disabled
if ($tpStatus -eq $true) {
    Write-Host "[1] Tamper Protection Status         : [OK] Enabled" -ForegroundColor Green
} elseif ($tpStatus -eq $false) {
    Write-Host "[1] Tamper Protection Status         : [NO] Disabled" -ForegroundColor Yellow
} else {
    Write-Host "[1] Tamper Protection Status         : [E] Unknown - $tpStatus"  -ForegroundColor Red
}

# Confirm if Tamper Protection is managed by Microsoft or other
if ($tpManage -eq "Intune") {
    Write-Host "[2] Tamper Protection Source         : [OK] Intune" -ForegroundColor Green
} elseif ($tpManage -eq "ATP") {
    Write-Host "[2] Tamper Protection Source         : [OK] MDE Tenant" -ForegroundColor Green
} else {
    Write-Host "[2] Tamper Protection Source         : [E] Unknown - $tpManage"  -ForegroundColor Red
}


# Confirm Microsoft Defender Antivirus version 4.18.2211.5 or later. 
function Get-DefenderAntivirusVersion {
    $avVersion = $avStatus.AMProductVersion
    if ($avVersion -ge "4.18.2211.5") {
        Write-Host "   [+] Microsoft Defender Antivirus     : [OK] $avVersion" -ForegroundColor Green
    } else {
        Write-Host "   [-] Microsoft Defender Antivirus     : [NO] $avVersion" -ForegroundColor Yellow
    }
}

# Confirm if the device of av policies managed by Intune or MECM  
function Get-DeviceManagement {
    $deviceManagePath = "HKLM:\SOFTWARE\Microsoft\Windows Defender"
    $deviceManagePathExists = Test-Path $deviceManagePath

    if ($deviceManagePathExists) {
        $deviceManageValue = Get-ItemPropertyValue -Path $deviceManagePath -Name "ManagedDefenderProductType"

        if ($deviceManageValue -eq 6) { 
            Write-Host "   [+] Device Management/ Defender AV   : [OK] Intune`n" -ForegroundColor Green
        } elseif ($deviceManageValue -eq 7) {
            Write-Host "   [+] Device Management/ Defender AV   : [OK] MECM`n" -ForegroundColor Green
        } else {
            Write-Host "   [-] Device Management/ Defender AV   : [E] Unknown - $deviceManageValue`n"  -ForegroundColor Yellow
        }
    } else {
            Write-Host "   [-] Device Management/ Defender AV   : [E] Unknown - $deviceManageValue`n"  -ForegroundColor Red
    }
}

# Confirm Tamper Protection for antivirus exclusions
$tpExclusionsPath = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features"
$tpExclusionsPathExists = Test-Path $tpExclusionsPath

if ($tpExclusionsPathExists) {
    $tpExclusionsValue = Get-ItemPropertyValue -Path $tpExclusionsPath -Name "TPExclusions"

    if ($tpExclusionsValue -eq 1) { 
        Write-Host "[3] Tamper Protection, AV exclusions : [OK] Enabled" -ForegroundColor Green
    } elseif ($TPExclusionsValue -eq 0) {
        Write-Host "[3] Tamper Protection, AV exclusions : [NO] Disabled" -ForegroundColor Yellow
        Get-DefenderAntivirusVersion
        Get-DeviceManagement
        Write-Host "   [Please verify the configuration as below since this script does not confirm it]"
        Write-Host "   [-] DisableLocalAdminMerge" -ForegroundColor Yellow
        Write-Host "   [-] Microsoft Defender Antivirus exclusions are managed in Microsoft Intune`n" -ForegroundColor Yellow
    } else {
        Write-Host "[3] Tamper Protection, AV exclusions : [E] Unknown - $TPExclusionsValue`n"  -ForegroundColor Red 
    }
} else {
    Write-Host "[3] Tamper Protection, AV exclusions  : [E] Unknown - $tpExclusionsPath"  -ForegroundColor Red
    Write-Host "[3] Path - 'HKLM:\SOFTWARE\Microsoft\Windows Defender\Features' : $tpExclusionsPathExists`n" -ForegroundColor Red
}

Write-Host "+=====================================================================================================+"

# Reference : https://cloudbrothers.info/current-limits-defender-av-tamper-protection/Script-Method1.ps1.txt
function Get-AllAVValues {
    try {
        $avValues = Get-MpPreference
        Write-Host "  [-] DisableIOAVProtection          : $($avValues.DisableIOAVProtection)"
        Write-Host "  [-] DisableEmailScanning           : $($avValues.DisableEmailScanning)"
        Write-Host "  [-] DisableBlockAtFirstSeen        : $($avValues.DisableBlockAtFirstSeen)"
        Write-Host "  [-] DisableRealtimeMonitoring      : $($avValues.DisableRealtimeMonitoring)"
        Write-Host "  [-] DisableBehaviorMonitoring      : $($avValues.DisableBehaviorMonitoring)"
        Write-Host "  [-] MAPSReporting                  : $($avValues.MAPSReporting)"
        Write-Host "  [-] SharedSignaturesPath           : $($avValues.SharedSignaturesPath)"
        Write-Host "  [-] UnknownThreatDefaultAction     : $($avValues.UnknownThreatDefaultAction)"
        Write-Host "  [-] LowThreatDefaultAction         : $($avValues.LowThreatDefaultAction)"
        Write-Host "  [-] HighThreatDefaultAction        : $($avValues.HighThreatDefaultAction)"
        Write-Host "  [-] ModerateThreatDefaultAction    : $($avValues.ModerateThreatDefaultAction)"
        Write-Host "  [-] SevereThreatDefaultAction      : $($avValues.SevereThreatDefaultAction)"
        Write-Host "  [-] DisableArchiveScanning         : $($avValues.DisableArchiveScanning)"
        Write-Host "  [-] ExclusionExtension             : $($avValues.ExclusionExtension)"
        Write-Host "  [-] ExclusionPath                  : $($avValues.ExclusionPath)`n"
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }  
}

# Disable virus and threat protection
function Set-VirusThreatProtection {
    try {
        Set-MpPreference -DisableIOAVProtection $true -DisableEmailScanning $true -DisableBlockAtFirstSeen $true
        Write-Host "  [1] Disabling Virus and Threat Protection : [OK] Disabled" -ForegroundColor Green
        Write-Host '     [-] Set-MpPreference -DisableIOAVProtection $true'
        Write-Host '     [-] Set-MpPreference -DisableEmailScanning $true'
        Write-Host '     [-] Set-MpPreference -DisableBlockAtFirstSeen $true'
    } catch {
        Write-Host "  [1] Disabling Virus and Threat Protection : [NO] Disabled" -ForegroundColor Red
        Write-Host "  Error: $_" -ForegroundColor Red
    }
}

# Disable real-time protection
function Set-RealTimeProtection {
    try {
        Set-MpPreference -DisableRealtimeMonitoring $true
        Write-Host "  [2] Disable real-time protection          : [OK] Disabled" -ForegroundColor Green
        Write-Host '     [-] Set-MpPreference -DisableRealtimeMonitoring $true' 
    } catch {
        Write-Host "  [2] Disable real-time protection          : [NO] Disabled" -ForegroundColor Red
        Write-Host "  Error: $_" -ForegroundColor Red
    }
}

# Disable behavior monitoring
function Set-BehaviorMonitoring {
    try {
        Set-MpPreference -DisableBehaviorMonitoring $true
        Write-Host "  [3] Turning off behavior monitoring       : [OK] Disabled" -ForegroundColor Green
        Write-Host '     [-] Set-MpPreference -DisableBehaviorMonitoring $true'
    } catch {
        Write-Host "  [3] Turning off behavior monitoring       : [NO] Disabled" -ForegroundColor Red
        Write-Host "  Error: $_" -ForegroundColor Red
    }
}

# Disable cloud-delivered protection
function Set-CloudDeliveredProtection {
    try {
        Set-MpPreference -MAPSReporting 0 
        Write-Host "  [4] Disable cloud-delivered protection    : [OK] Disabled" -ForegroundColor Green
        Write-Host '     [-] Set-MpPreference -MAPSReporting 0 '
    } catch {
        Write-Host "  [4] Disable cloud-delivered protection    : [NO] Disabled" -ForegroundColor Red
        Write-Host "  Error: $_" -ForegroundColor Red
    }
}

# Disable signature updates
function Set-SignatureUpdates {
    try {
        Set-MpPreference -SharedSignaturesPath "-"
        Write-Host "  [5] Disable signature updates             : [OK] Disabled" -ForegroundColor Green
        Write-Host '     [-] Set-MpPreference -SharedSignaturesPath "-"'
    } catch {
        Write-Host "  [5] Disable signature updates             : [NO] Disabled" -ForegroundColor Red
        Write-Host "  Error: $_" -ForegroundColor Red
    }
}

# Automatic actions are taken on detected threats
function Set-AutomaticActions {
    try {
        Set-MpPreference -UnknownThreatDefaultAction Allow -LowThreatDefaultAction Allow  -HighThreatDefaultAction Allow  -ModerateThreatDefaultAction Allow  -SevereThreatDefaultAction Allow
        Write-Host "  [6] Automatic actions on detected threats : [OK] Disabled" -ForegroundColor Green
        Write-Host '     [-] Set-MpPreference -UnknownThreatDefaultAction Allow'
        Write-Host '     [-] Set-MpPreference -LowThreatDefaultAction Allow'
        Write-Host '     [-] Set-MpPreference -HighThreatDefaultAction Allow'
        Write-Host '     [-] Set-MpPreference -ModerateThreatDefaultAction Allow'
        Write-Host '     [-] Set-MpPreference -SevereThreatDefaultAction Allow'
    } catch {
        Write-Host "  [6] Automatic actions on detected threats : [NO] Disabled" -ForegroundColor Red
        Write-Host "  Error: $_" -ForegroundColor Red
    }
}

# Archived files are scanned.
function Set-ArchivedFilesScanning {
    try {
        Set-MpPreference -DisableArchiveScanning $true
        Write-Host "  [7] Archived files are scanned            : [OK] Disabled" -ForegroundColor Green
        Write-Host '     [-] Set-MpPreference -DisableArchiveScanning $true'
    } catch {
        Write-Host "  [7] Archived files are scanned            : [NO] Disabled" -ForegroundColor Red
        Write-Host "  Error: $_`n" -ForegroundColor Red
    }
}

# Exclusions cannot be modified or added
function Set-ExclusionExtension {
    try {
        Set-MpPreference -ExclusionExtension "ps1" -ExclusionPath "C:\"
        Write-Host "  [8] Exclusions cannot be modified or added: [OK] Disabled" -ForegroundColor Green
        Write-Host '     [-] Set-MpPreference -ExclusionExtension "ps1"'
        Write-Host '     [-] Set-MpPreference -ExclusionPath "C:\"'
        Write-Host ""
    } catch {
        Write-Host "  [8] Exclusions cannot be modified or added: [NO] Disabled" -ForegroundColor Red
        Write-Host "  Error: $_`n" -ForegroundColor Red
    }
}

# ask if you want to test or not
$tpResponse = Read-Host "Do you want to test Tamper Protection? (Yes/No)"

# Check the user's response
# If the user chooses "Yes" and "Y, execute Code A
# testing is available only if Tamper Protection is enabled
if ($tpStatus -eq $true) {
    if ($tpResponse -eq "Yes" -or $tpResponse -eq "Y") {
        Write-Host "<BEFORE : Current Values>" -ForegroundColor Yellow
        Get-AllAVValues

        # Code to execute if the user chooses "Yes"
        # Add your Code A here
        Write-Host "<TP : PowerShell Cmdlet testings>" -ForegroundColor Yellow
        Set-VirusThreatProtection
        Set-RealTimeProtection
        Set-BehaviorMonitoring
        Set-CloudDeliveredProtection
        Set-SignatureUpdates 
        Set-AutomaticActions
        Set-ArchivedFilesScanning
	Set-ExclusionExtension

        Write-Host "<AFTER : Values after the testings>" -ForegroundColor Yellow
        Get-AllAVValues
    } else {
        # Finish the script if the user chooses "No"
        exit
    }
} else {
    Write-Host "Tamper Protection is not enabled. Please enable it to test the settings."
    exit
}

# Parameter
param (
    [Parameter(Mandatory=$false)]
    [string]$Path,
    [Parameter(Mandatory=$false)]
    [string]$Category
) 

# Create MDE-tester directory if it doesn't exist
$testerDirectory = "C:\MDE-tester"
if (-not (Test-Path $testerDirectory -PathType Container)) {
    New-Item -Path $testerDirectory -ItemType Directory
}

# Get the current date and time in the specified format
$dateSuffix = Get-Date -Format "yyyyMMddHHmm"

# Construct the file name with the date suffix
$outputFileName = "{0}-LOG.txt" -f $dateSuffix
$outputFilePath = Join-Path $testerDirectory $outputFileName

# Save the original output stream (e.g., Console)
$originalOutput = $Host.UI.RawUI.ForegroundColor

# Redirect output to the text file
Start-Transcript -Path $outputFilePath -Append

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
Write-Host "                         By Kijo Ninja (@kj_ninja25)" -ForegroundColor Cyan
Write-Host "                              Version : 4.0.0"

# : MDE Tester introduction 
$intro = @"
MDE Tester is designed to help testing following features in Microsoft Defender for Endpoint.
'MDEtester.ps1' is intended to assist in testing the following features: 
  - Microsoft Defender SmartScreen
  - Microsoft Defender Exploit Guard, Network Protection
  - Microsoft Defender for Endpoint, URL Indicators
  - Microsoft Defender for Endpoint, Web Content Filtering

# Usage : Test full features
PS C:\> .\MDEtester.ps1 -Path <CSV File path> -Category <Category>
-Category : HighBandwidth, LegalLiability, Leisure
"@

Write-Host "`n"
Write-Host $intro

# Check each status(prerequisite) for testing
Write-Host ""
Write-Host "+=====================================================================================================+"
Write-Host "Checking device configuration..."
Write-Host ""

# MDE Sensor status
try {
    $MDEservice = Get-Service -Name "Sense" -ErrorAction Stop
    $MDEstatus = $MDEservice.Status

    if ($MDEstatus -eq "Running") {
        Write-Host "[1] Microsoft Defender for Endpoint : [OK] Onboard" -ForegroundColor Green
    } elseif ($MDEstatus -eq "Stopped") {
        Write-Host "[1] Microsoft Defender for Endpoint : [NO] Not Onboard" -ForegroundColor Red
        $MDENotRunning = $true
    }
} catch {
    Write-Host "[E] Microsoft Defender for Endpoint : [NO] No Sense found" -ForegroundColor Red
    $MDENotRunning = $true
}

# MDE Network Protection status
try {
    $NPvalue = (Get-MpPreference).EnableNetworkProtection

    if ($NPvalue -eq 1) {
        Write-Host "[2] MDE Network Protection          : [OK] Enabled" -ForegroundColor Green
    } elseif ($NPvalue -eq 0) {
        Write-Host "[2] MDE Network Protection          : [NO] Disabled" -ForegroundColor Red
        $NPDisabled = $true
    } elseif ($NPvalue -eq 2) {
        Write-Host "[2] MDE Network Protection          : [OK] Audit" -ForegroundColor Green
    }
} catch [System.Exception] {
    Write-Host "[E] MDE Network Protection          : [NO] The status is unknown." -ForegroundColor Red
    $NPDisabled = $true
}

# Defender SmartScreen status
$SSValuePath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
$SmartScreenEnabledPathExists = Test-Path $SSValuePath

# If Edge SmartScreenEnabled path exists
if ($SmartScreenEnabledPathExists) {
    $SSvalue = Get-ItemPropertyValue -Path $SSValuePath -Name "SmartScreenEnabled"

    # Display messages based on the Edge SmartScreenEnabled status
    if ($SSvalue -eq 1) {
        Write-Host "[3] Microsoft Defender SmartScreen  : [OK] Enabled`n" -ForegroundColor Green
    } else {
        Write-Host "[3] Microsoft Defender SmartScreen  : [NO] Disabled`n" -ForegroundColor Red
        $SmartScreenDisabled = $true
    }
} else {
    # Display messages when Edge registry key was found due to non GPO/Intune policy management 
    Write-Host "[W] Microsoft Defender SmartScreen  : [NO] Path not found or inaccessible." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "If the device was not managed by GPO or Intune, the registry key path won't be found by this script." -ForegroundColor Yellow
    Write-Host "In order to make sure Edge Defender SmartScreen is enabled, please check Edge browser settings.`n" -ForegroundColor Yellow
}

# Microsoft Defender Antivirus - Version
# Get Microsoft Defender Real-Time Protection status
$defenderStatus = Get-MpComputerStatus

# Display the Real-Time Protection status
Write-Host "--- Microsoft Defender Antivirus ---"
Write-Host "[4] Antivirus Engine Version        : $($defenderStatus.AMEngineVersion )" -ForegroundColor Green
Write-Host "[5] Antivirus Product Version       : $($defenderStatus.AMProductVersion)" -ForegroundColor Green
try {
    if ($defenderStatus.RealTimeProtectionEnabled -eq $true) {
        Write-Host "[6] Real-Time Protection Enabled    : [OK] $($defenderStatus.RealTimeProtectionEnabled)" -ForegroundColor Green
    } else {
        Write-Host "[6] Real-Time Protection Enabled    : [NO] $($defenderStatus.RealTimeProtectionEnabled)" -ForegroundColor Red
        $RealTimeProtectionDisabled = $true
    }
} catch [System.Exception] {
    Write-Host "[E] Real-Time Protection Enabled    : [NO] The status is unknown." -ForegroundColor Red
    $RealTimeProtectionDisabled = $true
}

Write-Host "" 

# Check if any of the conditions are met to stop the script
if ($MDENotRunning) {
    Write-Host "[Action] Onboarding Microsoft Defender for Endpoint on the device is a prerequisite to run this script."
    Write-Host "--- END ---"
    Stop-Transcript
    $Host.UI.RawUI.ForegroundColor = $originalOutput
    Exit
} elseif ($NPDisabled -and $SmartScreenDisabled) {
    Write-Host "[Action] Enabling Network Protection or SmartScreen is a prerequisite to run this script."
    Write-Host "--- END ---"
    Stop-Transcript
    $Host.UI.RawUI.ForegroundColor = $originalOutput
    Exit
} elseif ($RealTimeProtectionDisabled) {
    Write-Host "[Action] Enabling Defender Antivirus - Real-Time Protection is a prerequisite to run this script."
    Write-Host "--- END ---"
    Stop-Transcript
    $Host.UI.RawUI.ForegroundColor = $originalOutput
    Exit
}

Write-Host "+=====================================================================================================+`n"

# Helper functions
function Invoke-BrowserUrl {
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Edge','Chrome')]
        [string]$Browser,

        [Parameter(Mandatory)]
        [string]$Url,

        [Parameter(Mandatory)]
        [string]$Message
    )

    $exe = if ($Browser -eq 'Edge') { 'msedge.exe' } else { 'chrome.exe' }

    Write-Host "$Message  ...Processing in $Browser"

    try {
        Start-Process $exe -ArgumentList $Url -ErrorAction Stop
        Write-Host "[Success] $Url" -ForegroundColor Green
    } catch {
        Write-Host "[Error] occurred while processing $Url in $Browser" -ForegroundColor Red
        if ($_.Exception.Message) {
            Write-Host "Error Details: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    Write-Host "-------------------------------------------------------------------------------------------------------"
}

function Ensure-BrowserStarted {
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Edge','Chrome')]
        [string]$Browser
    )

    $procName = if ($Browser -eq 'Edge') { 'msedge' } else { 'chrome' }

    if (-not (Get-Process -Name $procName -ErrorAction SilentlyContinue)) {
        try {
            Start-Process $procName
            Start-Sleep -Seconds 2
        } catch {
            Write-Host "[Warning] Failed to start ${Browser}: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}

function Invoke-WcfUrl {
    param (
        [Parameter(Mandatory)]
        [string]$Url,

        [Parameter(Mandatory)]
        [string]$Message
    )

    Invoke-BrowserUrl -Browser 'Edge' -Url $Url -Message $Message
    Invoke-BrowserUrl -Browser 'Chrome' -Url $Url -Message $Message
}

# Network Protection
Write-Host "=> MDE, Network Protection : Test in Chrome "

# Network Protection URL
Invoke-BrowserUrl -Browser 'Chrome' -Url 'https://smartscreentestratings2.net/' -Message "[1] Network Protection URL"

# Network Protection C2C URL
Invoke-BrowserUrl -Browser 'Chrome' -Url 'https://commandcontrol.smartscreentestratings.com' -Message "[2] Network Protection C2C URL"
# wait 10seconds
Start-Sleep -Seconds 10

Write-Host ""

# Microsoft Defender SmartScreen : Test
Write-Host "=> Microsoft Defender SmartScreen : Test in Edge"

Invoke-BrowserUrl -Browser 'Edge' -Url 'https://demo.smartscreen.msft.net/phishingdemo.html' -Message "[3] Phishing URL"
Invoke-BrowserUrl -Browser 'Edge' -Url 'https://demo.smartscreen.msft.net/other/malware.html' -Message "[4] Malware URL"
Invoke-BrowserUrl -Browser 'Edge' -Url 'https://demo.smartscreen.msft.net/download/malwaredemo/freevideo.exe' -Message "[5] Untrusted URL"
Invoke-BrowserUrl -Browser 'Edge' -Url 'https://demo.smartscreen.msft.net/other/exploit.html' -Message "[6] Exploit URL"
# wait 10seconds
Start-Sleep -Seconds 10

Write-Host ""

# MDE IoC URL : Test
Write-Host "=> MDE URL Indicators : Test in Edge & Chrome"

# Initialize the counter
$counter = 7

# Check if $Path is null or empty
if (-not $Path) {
    Write-Host "[No Test] : Path parameter is null or empty. Please specify a category using -Path parameter." -ForegroundColor Yellow
} else {
    if (Test-Path $Path) {
        # Read URLs from the CSV file
        $urlList = Import-Csv $Path | Select-Object -ExpandProperty IndicatorValue

        Ensure-BrowserStarted -Browser 'Edge'
        Ensure-BrowserStarted -Browser 'Chrome'

        foreach ($url in $urlList) {
            $message = "[$counter] URL Indicators"
            Invoke-BrowserUrl -Browser 'Edge' -Url $url -Message $message
            Invoke-BrowserUrl -Browser 'Chrome' -Url $url -Message $message
            $counter++
        }
    } else {
        Write-Host "[Error] CSV File not found: $Path" -ForegroundColor Red
    }
}

# wait 10seconds
Start-Sleep -Seconds 10

Write-Host ""

# MDE WCF : Test
Write-Host "=> MDE Web Content Filtering : Test in Edge & Chrome"

# Streaming Media & Downloads - https://www.netflix.com/
# Streaming Media & Downloads - https://www.hulu.com/welcome
# Image Sharing - https://www.pinterest.com/
# Download Sites - https://www.jamendo.com/
$HighBandwidth = @(
    "https://www.netflix.com/",
    "https://www.hulu.com/welcome",
    "https://www.pinterest.com/",
    "https://www.jamendo.com/"
)

# Hacking - https://github.com/adrecon/ADRecon
# Illegal Drug - https://www.greenrush.com/shop
# Illegal Software - https://tacking-uspsot-ks.com/
# Weapons - https://www.budsgunshop.com/
$LegalLiability = @(
     "https://github.com/adrecon/ADRecon",
     "https://www.greenrush.com/shop",
     "https://tacking-uspsot-ks.com/",
     "https://www.budsgunshop.com/"
)

# Games - https://poki.com/
# Professional Networking - https://www.linkedin.com/
# Web-based Email - https://mail.aol.com/
# Social Networking - https://web.whatsapp.com/
$Leisure = @(
     "https://poki.com/",
     "https://www.linkedin.com/",
     "https://mail.aol.com/",
     "https://web.whatsapp.com/"
)

# Check if the specified category exists in the script
if ($MyInvocation.BoundParameters['Category']) {
    $Category = $MyInvocation.BoundParameters['Category']

    # Check if the category is valid
    switch ($Category) {
        "HighBandwidth" {
            foreach ($url in $HighBandwidth) {
                Invoke-WcfUrl -Url $url -Message "High Bandwidth URL"
            }
        }
        "LegalLiability" {
            foreach ($url in $LegalLiability) {
                Invoke-WcfUrl -Url $url -Message "Legal Liability URL"
            }
        }
        "Leisure" {
            foreach ($url in $Leisure) {
                Invoke-WcfUrl -Url $url -Message "Leisure URL"
            }
        }
        default {
            Write-Host "Invalid category. Please specify a valid category."
        }
    }
} else {
    Write-Host "[No Test] : Category parameter is null or empty. Please specify a category using -Category parameter." -ForegroundColor Yellow
    Write-Host "[No Test] : 'HighBandwidth', 'LegalLiability', 'Leisure'" -ForegroundColor Yellow
}

Write-Host ""

# Close transcript and restore the original output stream
Stop-Transcript
$Host.UI.RawUI.ForegroundColor = $originalOutput

#END 

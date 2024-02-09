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
Write-Host "                         By Kijo Ninja (@kj_ninja25)"
Write-Host "                              Version : 2.0.1"

# : MDE Tester introduction 
$intro = @"
MDE Tester is designed to help testing various features in Microsoft Defender for Endpoint.
'MDEtester.ps1' is intended to assist in testing the following features: 
  - Microsoft Defender SmartScreen
  - Microsoft Defender Exploit Guard, Network Protection
  - Microsoft Defender for Endpoint, URL Indicators
  - Microsoft Defender for Endpoint, Web Content Filtering

# Usage : Test full features
PS C:\> .\MDEtester.ps1 -Path <CSV File path> -Category <Category>
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

# AV version
# Get Windows Defender Real-Time Protection status
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
    Exit
} elseif ($NPDisabled -and $SmartScreenDisabled) {
    Write-Host "[Action] Enabling Network Protection or SmartScreen is a prerequisite to run this script."
    Write-Host "--- END ---"
    Exit
} elseif ($RealTimeProtectionDisabled) {
    Write-Host "[Action] Enabling Defender Antivirus - Real-Time Protection is a prerequisite to run this script."
    Write-Host "--- END ---"
    Exit
}

Write-Host "+=====================================================================================================+`n"

#ASR Network Protection : Test
Write-Host "=> MDE, Network Protection : Test in Chrome "

function Process-Url {
    param (
        [string]$url,
        [string]$message
    )

    Write-Host "$message  ...Processing in Chrome"

    try {
        # Open Chrome process for the current URL and wait for it to exit
        Start-Process chrome.exe -ArgumentList $url 

        Write-Host "[Success] $url" -ForegroundColor Green
    } catch {
        # Handle exceptions (display error message) - Mostly Chrome was not installed 
        Write-Host "[Error] occurred while processing $url in Chrome" -ForegroundColor Red
    }
    Write-Host "-------------------------------------------------------------------------------------------------------"
}

# Network Protection URL
$url = "https://smartscreentestratings2.net/"
Process-Url -url $url -message "[1] Network Protection URL"

# Network Protection C2C URL
$url = "https://commandcontrol.smartscreentestratings.com"
Process-Url -url $url -message "[2] Network Protection C2C URL"

Write-Host ""

# Microsoft Defender SmartScreen : Test
Write-Host "=> Microsoft Defender SmartScreen : Test in Edge"

# Function to process Microsoft Defender SmartScreen URLs and display the result
function Process-Url {
    param (
        [string]$url,
        [string]$message
    )

    Write-Host "$message  ...Processing in Edge"

    try {
        # Open Edge process for the current URL
        $edgeProcess = Start-Process msedge.exe -ArgumentList $url -PassThru
       
        # Display the specific message based on the keyword
        Write-Host "[Success] $url" -ForegroundColor Green
    } catch {
        # Handle exceptions (display error message)
        Write-Host "[Error] occurred while processing $url in Edge" -ForegroundColor Red
    }
    Write-Host "-------------------------------------------------------------------------------------------------------"
}

# Phishing URL
$url = "https://demo.smartscreen.msft.net/phishingdemo.html"
Process-Url -url $url -message "[3] Phishing URL"

# Malware URL
$url = "https://demo.smartscreen.msft.net/other/malware.html"
Process-Url -url $url -message "[4] Malware URL"

# Untrusted URL
$url = "https://demo.smartscreen.msft.net/download/malwaredemo/freevideo.exe"
Process-Url -url $url -message "[5] Untrusted URL"

# Exploit URL
$url = "https://demo.smartscreen.msft.net/other/exploit.html"
Process-Url -url $url -message "[6] Exploit URL"

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

        # Check if the Edge browser process is already running
        $edgeProcess = Get-Process -Name msedge -ErrorAction SilentlyContinue

        # Check if the Chrome browser process is already running
        $chromeProcess = Get-Process -Name chrome -ErrorAction SilentlyContinue

        # Start Edge browser if not running
        if ($null -eq $edgeProcess) {
            Start-Process msedge
            Start-Sleep -Seconds 2  # Wait for the browser to start
        }

        # Start Chrome browser if not running
        if ($null -eq $chromeProcess) {
            try {
                Start-Process chrome  
                Start-Sleep -Seconds 3  # Wait for the browser to start
            } catch {
                # Handle exceptions (display error message)
                # Write-Host "[Error] No chrome process found to start" -ForegroundColor Red
            }   
        }

        # Open the Edge browser for each URL
        foreach ($url in $urlList) {
            Write-Host "[$counter] URL Indicators ...Processing in Edge"

            # Access the URL in Edge
            Start-Process msedge $url
            Start-Sleep -Seconds 2  # Wait a bit between accessing each URL

            # Display a success message with the counter incremented
            Write-Host "[Success] $url" -ForegroundColor Green
            Write-Host "-------------------------------------------------------------------------------------------------------"
            try {
                Write-Host "[$counter] URL Indicators ...Processing in Chrome"

                # Access the URL in Chrome
                Start-Process chrome $url
                Start-Sleep -Seconds 3  # Wait a bit between accessing each URL

                # Display a success message with the counter incremented
                Write-Host "[Success] $url" -ForegroundColor Green
                Write-Host "-------------------------------------------------------------------------------------------------------"
            } catch {
                # Handle exceptions (display error message)
                Write-Host "[Error] occurred while processing $url in Chrome" -ForegroundColor Red
                Write-Host "-------------------------------------------------------------------------------------------------------"
            }
            $counter++
        }
    } else {
        Write-Host "[Error] CSV File not found: $Path" -ForegroundColor Red
    }
}

Write-Host ""

# MDE WCF : Test
Write-Host "=> MDE Web Content Filtering : Test in Edge & Chrome"

function Invoke-UrlProcessing {
    param (
        [string]$url,
        [string]$message
    )

    Write-Host "$message  ...Processing in Edge"

    try {
        # Open Edge process for the current URL and wait for it to exit
        Start-Process "msedge.exe" -ArgumentList $url -Wait -ErrorAction Stop

        Write-Host "[Success] $url" -ForegroundColor Green
    } catch {
        Write-Host "[Error] occurred while processing $url in Edge" -ForegroundColor Red
        Write-Host "Error Details: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host "-------------------------------------------------------------------------------------------------------"

    Write-Host "$message  ...Processing in Chrome"

    try {
        # Open Chrome process for the current URL and wait for it to exit
        Start-Process "chrome.exe" -ArgumentList $url -Wait -ErrorAction Stop

        Write-Host "[Success] $url" -ForegroundColor Green
    } catch {
        Write-Host "[Error] occurred while processing $url in Chrome" -ForegroundColor Red
    }
    Write-Host "-------------------------------------------------------------------------------------------------------"
}

# Gambling - https://onlinesportsbetting.pro/
# Violence - https://www.americanviolence.org/
# Pornography - https://www.qorno.com/
# Nudity - https://www.aznude.com/browse/tags/imgs/fullfrontal/1.html
$AdultContent = @(
    "https://onlinesportsbetting.pro/",
    "https://www.americanviolence.org/",
    "https://www.qorno.com/",
    "https://www.aznude.com/browse/tags/imgs/fullfrontal/1.html"
)

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
        "AdultContent" {
            foreach ($url in $AdultContent) {
                Invoke-UrlProcessing -url $url -message "Adult Content URL"
            }
        }
        "HighBandwidth" {
            foreach ($url in $HighBandwidth) {
                Invoke-UrlProcessing -url $url -message "High Bandwidth URL"
            }
        }
        "LegalLiability" {
            foreach ($url in $LegalLiability) {
                Invoke-UrlProcessing -url $url -message "Legal Liability URL"
            }
        }
        "Leisure" {
            foreach ($url in $Leisure) {
                Invoke-UrlProcessing -url $url -message "Legal Liability URL"
            }
        }
        default {
            Write-Host "Invalid category. Please specify a valid category."
        }
    }
} else {
    Write-Host "[No Test] : Category parameter is null or empty. Please specify a category using -Category parameter." -ForegroundColor Yellow
    Write-Host "[No Test] : 'AdultContent', 'HighBandwidth', 'LegalLiability', 'Leisure'" -ForegroundColor Yellow
}

Write-Host ""

$LearningKijo = @"
+====================================================================================================================================================================+
| In order to check the detailed logs, you can track all activities in Advanced Hunting, Microsoft Defender XDR.                                                     |
| Here are the out-of-the-box KQL queries for threat hunting.                                                                                                        |
|                                                                                                                                                                    |
| [1] MDE URL Indicators "Block"                                                                                                                                     |
| https://github.com/LearningKijo/KQL/blob/main/KQL-XDR-Hunting/Endpoint-Microsoft-Defender-for-Endpoint/MDE-Query-Repository/01-MDE-URL-Indicators-Block.md         |
|                                                                                                                                                                    |
| [2] MDE URL Indicators "Warn"                                                                                                                                      |
| https://github.com/LearningKijo/KQL/blob/main/KQL-XDR-Hunting/Endpoint-Microsoft-Defender-for-Endpoint/MDE-Query-Repository/02-MDE-URL-Indicators-Bypass.md        |
|                                                                                                                                                                    |
| [3] MDE Network Protection                                                                                                                                         |
| https://github.com/LearningKijo/KQL/blob/main/KQL-XDR-Hunting/Endpoint-Microsoft-Defender-for-Endpoint/MDE-Query-Repository/03-MDE-NetworkProtection-Detection.md  |
|                                                                                                                                                                    |
| [4] Microsoft Defender SmartScreen                                                                                                                                 |
| https://github.com/LearningKijo/KQL/blob/main/KQL-XDR-Hunting/Endpoint-Microsoft-Defender-for-Endpoint/MDE-Query-Repository/04-SS-DefenderSmartScreen-Detection.md |
|                                                                                                                                                                    |
|                                                                          ---- END ----                                                                             |
| Thank you, Kijo Ninja                                                                                                                                              |
+====================================================================================================================================================================+
"@

Write-Host $LearningKijo

Write-Host ""

# Close transcript and restore the original output stream
Stop-Transcript
$Host.UI.RawUI.ForegroundColor = $originalOutput

#END 

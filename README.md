# MDE Tester

MDE Tester is designed to help testing various features in Microsoft Defender for Endpoint. 

`MDEtesterWP.ps1` is intended to assist in testing the following features: 
- [x] Microsoft Defender SmartScreen
- [x] Microsoft Defender Exploit Guard, Network Protection
- [x] Microsoft Defender for Endpoint, URL Indicators
- [x] Microsoft Defender for Endpoint, Web Content Filtering

## Prerequisites

`MDEtesterWP.ps1` assumes that the following items are installed, enabled and onboared.
- Install Google Chrome & Microsoft Edge
- Enable [Real-Time protection](https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/configure-microsoft-defender-antivirus-features?view=o365-worldwide), Microsoft Defender Antivirus
- Enable [Microsoft Defender SmartScreen](https://learn.microsoft.com/en-us/windows/security/operating-system-security/virus-and-threat-protection/microsoft-defender-smartscreen/)
- Enable [Microsoft Defender Exploit Guard, Network Protection](https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/network-protection?view=o365-worldwide)
- Onboard [Microsoft Defender for Endpoint](https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/microsoft-defender-endpoint?view=o365-worldwide) 

## Usage

***Test 1***
```
PS C:\> .\MDEtesterWP.ps1 
```
***Test 2***
```
PS C:\> .\MDEtesterWP.ps1 -Path <CSV File path>
```
***Test 3***
```
PS C:\> .\MDEtesterWP.ps1 -Category <category>
```
***Test 4***
```
PS C:\> .\MDEtesterWP.ps1 -Path <CSV File path> -Category <category>
```

|    Features  | Test 1 | Test 2 | Test 3 | Test 4 |
|:-----|--------|--------|-------|--------|
|  Microsoft Defender SmartScreen  | 〇 | 〇 | 〇 | 〇 |
|  Network Protection                       | 〇 | 〇 | 〇 | 〇 |
|  MDE URL Indicators                       | × | 〇 | × | 〇 |
|  MDE Web Content Filtering           | × | × | 〇 | 〇 |

> [!Important]
> **Signing**
> 
> If your PowerShell execution policy is set to RemoteSigned, PowerShell will not run unsigned scripts downloaded from the internet. Therefore, please unblock the script using the cmdlet or through Properties. <br>
> - [Running unsigned scripts using the RemoteSigned execution policy](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_signing?view=powershell-7.4#running-unsigned-scripts-using-the-remotesigned-execution-policy)
#### Parameter
```
-Path <String> : This is an optional parameter. Please specify a CSV file path and it is used for testing MDE URL indicators.
```
```
-Category <String> :  This is an optional parameter. Please select a category you want to test and it is used for testing MDE WCF.
```

## LOG
After you run `MDEtesterIoC.ps1`, all logs will be created by the script and available following the path - `C:\MDE-tester`.

## How it looks like
![image](https://github.com/LearningKijo/MDEtester/assets/120234772/34deb2dd-8a9a-48e4-a2eb-dd52cf8ee57c)

#### Disclaimer
The views and opinions expressed herein are those of the author and do not necessarily reflect the views of company.

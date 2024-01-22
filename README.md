# MDE Tester
MDE Tester is designed to help testing various features in Microsoft Defender for Endpoint. 

`MDEtesterIoC.ps1` is intended to assist in testing the following features: 
- [x] Microsoft Defender SmartScreen
- [x] Microsoft Defender Exploit Guard, Network Protection
- [x] Microsoft Defender for Endpoint, URL Indicators

## Prerequisites
- You need ***"a CSV file"*** that lists URLs to test URL Indicators in Microsoft Defender for Endpoint.
> [!Important]
> The CSV file column header must be ***'IndicatorValue'***. Here is [an example](https://github.com/LearningKijo/MDEtester/blob/main/Tools/Sample.csv).

`MDEtesterIoC.ps1` assumes that the following items are installed, enabled and onboared.
- Install Google Chrome & Microsoft Edge
- Enable [Real-Time protection](https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/configure-microsoft-defender-antivirus-features?view=o365-worldwide), Microsoft Defender Antivirus
- Enable [Microsoft Defender SmartScreen](https://learn.microsoft.com/en-us/windows/security/operating-system-security/virus-and-threat-protection/microsoft-defender-smartscreen/)
- Enable [Microsoft Defender Exploit Guard, Network Protection](https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/network-protection?view=o365-worldwide)
- Onboard [Microsoft Defender for Endpoint](https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/microsoft-defender-endpoint?view=o365-worldwide) 


## Usage

```powershell
PS C:\> .\MDEtesterIoC.ps1 -Path <CSV File path>
```
```powershell
PS C:\> .\MDEtesterIoC.ps1 -Path "C:\temp\Sample.csv"
```

> [!Important]
> **Signing**
> 
> If your PowerShell execution policy is set to RemoteSigned, PowerShell will not run unsigned scripts downloaded from the internet. Therefore, please unblock the script using the cmdlet or through Properties. <br>
> - [Running unsigned scripts using the RemoteSigned execution policy](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_signing?view=powershell-7.4#running-unsigned-scripts-using-the-remotesigned-execution-policy)
#### Parameter
```
-Path <String> : This is a mandatory parameter to specify a CSV file and is used for testing MDE URL indicators.
```

## LOG
After you run `MDEtesterIoC.ps1`, all logs will be created by the script and available following the path - `C:\MDE-tester`.

#### Disclaimer
The views and opinions expressed herein are those of the author and do not necessarily reflect the views of company.

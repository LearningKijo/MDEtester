# MDE Tester
MDE Tester is designed to help testing Web Protection-related components in Microsoft Defender for Endpoint. 
- [x] Microsoft Defender SmartScreen
- [x] Microsoft Defender Exploit Guard, Network Protection
- [x] Microsoft Defender for Endpoint, URL Indicators

### Prerequisites
- CSV file (to test [URL Indicators](https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/indicator-ip-domain?view=o365-worldwide), Microsoft Defender for Endpoint)
> [!Important]
> The CSV file column header must be ***'IndicatorValue'***. Here is [an example](https://github.com/LearningKijo/MDEtester/blob/main/Tools/Sample.csv).

`MDE-Tester.ps1` assumes that the following items are installed, enabled and onboared.
- Install Google Chrome & Microsoft Edge
- Enable [Microsoft Defender SmartScreen](https://learn.microsoft.com/en-us/windows/security/operating-system-security/virus-and-threat-protection/microsoft-defender-smartscreen/)
- Enable [Microsoft Defender Exploit Guard, Network Protection](https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/network-protection?view=o365-worldwide)
- Onboard [Microsoft Defender for Endpoint](https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/microsoft-defender-endpoint?view=o365-worldwide) 


## Usage


```powershell
PS C:\> .\MDE-Tester.ps1 -Path <CSV File path>
```
```powershell
PS C:\> .\MDE-Tester.ps1 -Path "C:\temp\Sample.csv"
```

> [!Important]
> #### Parameter
>```
>-Path <String> : This is a mandatory parameter to specify a CSV file and is used for testing MDE URL indicators.
>```

#### Disclaimer
The views and opinions expressed herein are those of the author and do not necessarily reflect the views of company.

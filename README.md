# **nvAppTimestamp Parser**
Parses Nvidia's Saved Executable Paths

## **Features**
• Signature Checks  
• File Instance Checks  
• Dumps Extracted Paths (C:\)  
• Detects Executables With Renamed Extensions or Unicode

## **How to Use**
**1.** Open Powershell as Administrator.  
**2.** Paste Script using Invoke or ps1.  
**3.** Wait for it to filter and scan paths using the data in assistance of a check.

## **Invoke**
```powershell
$url = 'https://github.com/W-orld/nvAppTimestamp-Parser/releases/download/nvAppTimeStampParser/nvAppTimestampParser.ps1'
$bytes = (Invoke-WebRequest -Uri $url).Content
$script = [System.Text.Encoding]::UTF8.GetString($bytes).TrimStart([char]0xFEFF)
Invoke-Expression $script

function Write-ToLog
{param(
    [Parameter(Mandatory = $true,Position=0)][String]$logMessage,
    [Parameter(Mandatory = $true)][String]$logPath,
    [Parameter(Mandatory = $false)][ValidateSet("Error","Warning","Information")][String]$entryType = "Information")
    
    $timeStamp = Get-Date -Format s
    $testFile = Test-Path $logPath
    If ($testFile -eq $false){"$timeStamp Created log file" | Out-File $logPath }
    Switch ($entryType)
    {
        "Error" {$entryTypeText = "Error:";$typeColor = "Yellow";$typeBackColor = "Red"}
        "Warning" {$entryTypeText = "Warning:";$typeColor = "Blue";$typeBackColor = "Yellow"}
        "Information" {$entryTypeText =  "";$typeColor = "Green";$typeBackColor = "Black"}
    }
    $logText = "$timeStamp - " + $entryTypeText + $logMessage
    $logText | out-file $logPath -Append
    Write-Host "$(Get-Date -Format T) $logMessage" -ForegroundColor $typeColor -BackgroundColor $typeBackColor 
}
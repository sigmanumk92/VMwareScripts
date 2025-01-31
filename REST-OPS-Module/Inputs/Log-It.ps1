######################################>
#Logging Function
function Log-it ([string] $txt){
    Write-Host $txt
    $LogTimeStamp = (Get-Date -Format G)
    Add-Content -Path $LogFile -Value "$($LogTimeStamp):  $txt"
    $txt = $null
}
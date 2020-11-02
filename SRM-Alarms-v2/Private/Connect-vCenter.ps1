<#
.SYNOPSIS
Connect to a target vCenter,
.DESCRIPTION
This script is an internal function to connect to a vCenter.
.NOTES
Author: Anthony Schulte
.PARAMETER Credential
Credential to use for connection.
.PARAMETER vCenter
vCenter Address to connect to.
.EXAMPLE
Connect-vCenter -Credential $VMcred -vCenter vcenter.contoso.com
#>

Function Connect-vCenter {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [string]$vCenter,
        [Parameter(Mandatory = $True)]
        $usernames,
        [Parameter(Mandatory = $True)]
        $passwords,
		[Parameter(Mandatory = $False)]
        $logs
		)

    #Import Modules necessary for VMware and set single server mode#
    Import-Module VMware.VimAutomation.Core -Verbose:$false
    Import-Module VMware.VUMAutomation -Verbose:$false
	Set-PowerCLIConfiguration -DefaultVIServerMode Single -InvalidCertificateAction Ignore -Scope Session -Confirm:$False -Verbose:$false | Out-Null

    #Connect to vCenter Server specified
    Connect-VIServer -Server $vCenter -user $usernames -password $passwords
	Write-ToLogFile -logPath $logs "Connecting to vCenter"
}
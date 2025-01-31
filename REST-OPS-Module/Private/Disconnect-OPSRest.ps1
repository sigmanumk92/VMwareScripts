<###########################################
.SYNOPSIS
This script will allow the user to disconnect from the ops REST API
.DESCRIPTION
This script will allow the user to disconnect from the ops REST API
.NOTES
Author: Anthony Schulte
Created: 04/25/2023
.PARAMETER opsname
Pass the name of the ops Appliance
.EXAMPLE
Disconnect-opsREST -opsname 'servername.domain'
#############################################>

Function Disconnect-opsREST {
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory = $True)]
		[String]$opsname
	)
	Begin {
		#Define Base URL 
		#--------------------------------------------
		$BASE_URL = 'https://' + $opsname + '/suite-api/api'
		$EndUri	= $BASE_URL + '/auth/token/release'
		$methodp = 'POST'	
			
		try {
			Log-It "Release a token"
			$invoke_Delete_Session = Invoke-RestMethod -URI $EndUri -Method $methodp
			Log-It $invoke_Delete_Session
		}

        catch {
            Log-It "There was an error getting the token in the disconnect-opsrest script"
            Log-It  $_.Exception.Message
		    }
				
	} #EndBegin
} #EndFunction
<###########################################
.SYNOPSIS
This script will allow the user to connect to the Aria Operations REST API
.DESCRIPTION
This script will allow the user to connect to the Aria Operations REST API and returns the token for use in the other scripts
.NOTES
Author: Anthony Schulte
Created: 01/25/2025
.PARAMETER opsname
Pass the name of the Aria Operations
.EXAMPLE
Connect-OPSREST -opsname 'servername.domain'
#############################################>
Function Connect-OPSREST {
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory = $True)]
		[String]$opsname,
		[System.Management.Automation.Credential()]
		$MyCredential = [System.Management.Automation.PSCredential]::Empty
	)
	Begin {
		#Instantiate Variables
		#--------------------------------------------
		[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
		
		#Declare Credentials
		#--------------------------------------------
		$params_Auth = @{}
		
		Log-It "The user is $($MyCredential.Username)"
		#$mycred = New-Object -typename System.Management.Automation.PSCredential -ArgumentList $user,$pwd1
		
		$RESTAPIUser = $MyCredential.UserName
		$RESTAPIPassword = $MyCredential.GetNetworkCredential().Password
		
		#Define Base URL and Authentication Token
		#--------------------------------------------
		$BASE_URL = 'https://' + $opsname + '/suite-api/api'
		Log-It "Here is the Base_URL $BASE_URL"
		#Put the header together
		$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
		$headers.Add('Content-Type', 'application/json')
		$headers.Add('Accept', 'application/json')
		$headersstr = $headers | Out-String
		Log-It $headersstr
		#Putting the Body in a header
		#
		$body = @{
			username = "$RestApiUser"
			authSource = "Active Directory"
			password = "$RESTAPIPassword"
		} | ConvertTo-Json
		#Create Token and return value
		$params_Auth = @{
				Uri			= $BASE_URL + '/auth/token/acquire'
				Headers		= $headers
				Method		= 'POST'
				body		= $body
		}
		Log-It "Here is the entire REST Call"
		$paramstring = $params_Auth | ConvertTO-Json
		Log-It $paramstring
		try {
            
			$token = Invoke-RestMethod @params_Auth | Select-Object -expandproperty token
			Log-It $token
			
		}

        catch {
            Log-It "There was an error getting the token in the connect-opsrest script"
            Log-It  $_.Exception.Message
		}
		return $token
	} #EndBegin
} #EndFunction

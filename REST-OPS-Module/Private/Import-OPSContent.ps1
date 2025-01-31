<###########################################
.SYNOPSIS
This script will allow the user to Import content from the Operations REST API
.DESCRIPTION
This script will allow the user to Import content from the Operations REST API
.NOTES
Author: Anthony Schulte
Created: 01/25/2025
.PARAMETER opsname
Pass the name of the Operations server
.PARAMETER token
Pass the token generated from previous script
.EXAMPLE
Import-OPSContent -opsname 'servername.domain' -token 'asdfagreert39024592jgfasdg'
#############################################>

Function Import-OPSContent {
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory = $True)]
		[String]$opsname,
		[Parameter(Mandatory = $True)]
		[String]$token
	)
	Begin {
		
		#--------------------------------------------
		#Get the file name
        $File = @{
            contentFile = Get-Item -Path "C:\Users\Administrator\content.zip"
        }
        
        #Set up the Json for connection to import content
        $ImpFile = @{
            "URI"         = "https://" + $opsname + "/suite-api/api/content/operations/import"
            "Headers"     = @{
                                        'Content-Type'  = "multipart/form-data"
                                        'Accept'  = "*/*"
                                        Authorization = "OpsToken $($token)"
                                        }
            "Method"      = "POST"
        }
        Invoke-RestMethod @ImpFile -Form $File

	} #EndBegin
} #EndFunction
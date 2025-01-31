<###########################################
.SYNOPSIS
This script will allow the user to get the alerts from the Operations REST API
.DESCRIPTION
This script will allow the user to get the alerts from the Operations REST API
.NOTES
Author: Anthony Schulte
Created: 01/25/2025
.PARAMETER opsname
Pass the name of the Operations server
.PARAMETER token
Pass the token generated from previous script
.EXAMPLE
Get-OPSVersion -opsname 'servername.domain' -token 'asdfagreert39024592jgfasdg'
#############################################>

Function Get-OPSVersion {
    [CmdletBinding()]
    Param(
            [Parameter(Mandatory = $True)]
            [String] $opsname,
            [Parameter(Mandatory = $True)]
            [String] $Token
    )
    Begin {
        Log-It "The Token id in the Get-OPSVersion Script is - $Token"
        $BASE_URL = 'https://' + $opsname + '/suite-api/api'
        Log-It "Creating the the Authorization header for the api calls"
        
        #Define Base URL and Authentication Token
        #--------------------------------------------
        #Putting the Body in a header
        $getverjson = $null
        $getverjson = @{}      
        $getverjson = @{
                        "URI"     = $BASE_URL + '/versions/current'
                        "Headers" = @{
                            'Content-Type' = "application/json"
                            'Accept' = "application/json"
                            Authorization = "OpsToken $($Token)"
                        }
                        "Method"  = 'GET'
                    }
        $getverjsonstr = $getverjson | ConvertTo-Json
        Log-it $getverjsonstr
       
        try {
            
            $verdata = Invoke-RestMethod @getverjson
            $verdata
            Log-It "$verdata"
            }

        catch {
            Log-It "There was an error in the Get-OPSVersion script"
            Log-It  $_.Exception.Message
            }
    } #EndBegin
} #EndFunction
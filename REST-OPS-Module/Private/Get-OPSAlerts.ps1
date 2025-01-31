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
Get-OPSAlerts -opsname 'servername.domain' -token 'asdfagreert39024592jgfasdg'
#############################################>

Function Get-OPSAlerts {
    [CmdletBinding()]
    Param(
            [Parameter(Mandatory = $True)]
            [String] $opsname,
            [Parameter(Mandatory = $True)]
            [String] $Token
    )
    Begin {
            
        $outpath = Get-OutputfldPath
        $outfilep = "$outpath" + "\CSV-Files\"
        Log-It $outfilep
        Log-It "The Token id in the Get-OPSAlerts Script is - $Token"
        $BASE_URL = 'https://' + $opsname + '/suite-api/api'
        Log-It "Creating the the Authorization header for the api calls"
        
        #Define Base URL and Authentication Token
        #--------------------------------------------
        #Putting the Body in a header
        $getaljson = $null
        $getaljson = @{}      
        $getaljson = @{
                        "URI"     = $BASE_URL + '/alerts'
                        "Headers" = @{
                            'Content-Type' = "application/json"
                            'Accept' = "application/json"
                            Authorization = "OpsToken $($Token)"
                        }
                        "Method"  = 'GET'
                    }
        $getaljsonstr = $getaljson | ConvertTo-Json
        Log-it $getaljsonstr
       
        try {
            
                Invoke-RestMethod @getaljson 
            }

        catch {
            Log-It "There was an error in the Get-OPSAlerts script"
            Log-It  $_.Exception.Message
            }
    } #EndBegin
} #EndFunction
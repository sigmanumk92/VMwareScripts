<###########################################
.SYNOPSIS
This script will allow the user to get the content from the Operations REST API
.DESCRIPTION
This script will allow the user to get the content from the Operations REST API
.NOTES
Author: Anthony Schulte
Created: 01/25/2025
.PARAMETER opsname
Pass the name of the Operations server
.PARAMETER token
Pass the token generated from previous script
.EXAMPLE
Get-OPSContentEXP -opsname 'servername.domain' -token 'asdfagreert39024592jgfasdg' -outpath "c:\scripts"
#############################################>

Function Get-OPSContentEXP {
    [CmdletBinding()]
    Param(
            [Parameter(Mandatory = $True)]
            [String] $opsname,
            [Parameter(Mandatory = $True)]
            [String] $Token,
            [Parameter(Mandatory = $True)]
            [String] $outpath
    )
    Begin {
        Log-It "The Token id in the Get-OPSContentEXP Script is - $Token"
        $BASE_URL = 'https://' + $opsname + '/suite-api/api'
        Log-It "Creating the the Authorization header for the api calls"
        $outfn = "$($outpath)\$($opsname)-content.zip"
        Log-it $outfn
        #Putting the Info in a Hashtable
        $getcontexpjson = $null
        $getcontexpjson = @{}      
        $getcontexpjson = @{
                        "URI"     = $BASE_URL + '/content/operations/export/zip'
                        "Headers" = @{
                        'Content-Type' = "application/json"
                        'Accept' = "application/json"
                        Authorization = "OpsToken $($Token)"
                        }
                        "Method"  = "GET"
                }
        $getcontexpjsonstr = $getcontexpjson | ConvertTo-Json -Depth 6
        Log-it $getcontexpjsonstr
        try {
        
                Invoke-RestMethod @getcontexpjson -outfile $outfn
        
        }
        catch {
                Log-It "There was an error in the Get-OPSContentEXP script"
                Log-It  $_.Exception.Message
                Break
        }
        return $outfn
        
        } #EndBegin
} #EndFunction
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
Get-OPSContent -opsname 'servername.domain' -token 'asdfagreert39024592jgfasdg'
#############################################>

Function Get-OPSContent {
        [CmdletBinding()]
        Param(
                [Parameter(Mandatory = $True)]
                [String] $opsname,
                [Parameter(Mandatory = $True)]
                [String] $Token
        )
        Begin {
                Log-It "The Token id in the Get-OPSContent Script is - $Token"
                $BASE_URL = 'https://' + $opsname + '/suite-api/api'
                Log-It "Creating the the Authorization header for the api calls"
                
                #Putting the Info in a Hashtable
                $getcontjson = @{
                                "URI"     = $BASE_URL + '/content/operations/export'
                                "Headers" = @{
                                'Content-Type' = "application/json"
                                'Accept' = "application/json"
                                Authorization = "OpsToken $($Token)"
                                }
                                "Method"  = "POST"
                                body = @{
                                        scope = "ALL"
                                        contentTypes = "VIEW_DEFINITIONS","DASHBOARDS","CUSTOM_GROUPS","SUPER_METRICS"
                                        } | ConvertTo-Json
                        }
                $getcontjsonstr = $getcontjson | ConvertTo-Json -Depth 6
                Log-it $getcontjsonstr
                try {
                
                #Get the Content
                Log-It "Starting the export of the content types of data"
                Invoke-RestMethod @getcontjson | Select-Object -ExpandProperty contentTypes
                
                }
                catch {
                Log-It "There was an error getting the content in the Get-OPSContent script"
                Log-It  $_.Exception.Message
                }
                
                #Check the Process of Creation of Content
                #Putting the Info in a Hashtable
                $getstatusjson = @{
                        "URI"     = $BASE_URL + '/content/operations/export'
                        "Headers" = @{
                        'Content-Type' = "application/json"
                        'Accept' = "application/json"
                        Authorization = "OpsToken $($Token)"
                        }
                        "Method"  = "GET"
                }
                $getstatusjsonstr = $getstatusjson | ConvertTo-Json -Depth 6
                Log-it $getstatusjsonstr
                try {
                
                #Get the Content Status
                Log-It "Get the Status of the export of the content types of data"
                $status = Invoke-RestMethod @getstatusjson
                $statusinfo = $status | ConvertTo-Json -Depth 6
                Log-it "$statusinfo"
                
                }
                catch {
                Log-It "There was an error getting the status of the content in the Get-OPSContent script"
                Log-It  $_.Exception.Message
                }

                
    } #EndBegin
} #EndFunction
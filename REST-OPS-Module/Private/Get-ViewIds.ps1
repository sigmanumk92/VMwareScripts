<###########################################
.SYNOPSIS
This script will get the view Definition id to know which views need to be zipped
.DESCRIPTION
This script will get the view Definition id to know which views need to be zipped
.NOTES
Author: Anthony Schulte
Created: 01/25/2025
.PARAMETER outputpath
Location of the Dashboard file
.PARAMETER dashname
The name of the dashboard
.EXAMPLE
Get-ViewIds -outputpath <path to dashboardjsons> -dashname "Dashboard name"
#############################################>
Function Get-ViewIds {
    [CmdletBinding()]
    Param(
            [Parameter(Mandatory = $True)]
            [String] $outputpath,
            [Parameter(Mandatory = $True)]
            [String] $dashname
    )
    Begin {
        #$dashname = Get-ChildItem -Path "C:\Users\ASchulte\Documents\Scripts\REST-OPS-Module\Outputs\Final-exportFiles\Dashboards" -File | Select-Object -ExpandProperty Name
        #$outputpath = "C:\Users\ASchulte\Documents\Scripts\REST-OPS-Module\Outputs\Final-exportFiles"
        
        $userdashfile = "$($outputpath)\$($dashname)"
        Write-host $userdashfile
        
        If(Test-Path -Path $userdashfile){
            #Get the View Definition IDfor each dashboard
            Log-It "Found the dashboard in the get-viewid script"
            try{
                $dashjson = Get-Content $userdashfile
                $dashjsoninfo = $dashjson | Convertfrom-Json
                $idlist = ($dashjsoninfo.dashboards.widgets.config | Where-Object {[string]::IsNullOrEmpty($_.viewDefinitionId) -eq $false} | Select-Object -ExpandProperty viewDefinitionId ) -join ','
            }Catch{
                Log-It "There was an error getting the viewID from the $($userdashfile)"
                Log-It  $_.Exception.Message
            }
            #Return the Array of view IDS
            $idsout = $idlist.Split(",")
            log-it "Here is the ids from the get-viewids list - $($idsout)"
            
            Return $idsout
        }Else{
            Log-It "Could not find the dashboard file"
        }
    }
}
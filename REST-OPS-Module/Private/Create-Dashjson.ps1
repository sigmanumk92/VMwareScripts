<###########################################
.SYNOPSIS
This script will parse the original Dashboard Json and grab each individual one
.DESCRIPTION
This script will parse the original Dashboard Json and grab each individual one
.NOTES
Author: Anthony Schulte
Created: 01/25/2025
.PARAMETER userid
Pass the token generated from previous script
.EXAMPLE
Create-Dashjson -userid 'asdfagreert39024592jgfasdg' -outputpath 'c:\scripts'
#############################################>

Function Create-Dashjson {
    [CmdletBinding()]
    Param(
            [Parameter(Mandatory = $True)]
            [String] $userid,
            [Parameter(Mandatory = $True)]
            [String] $outputpath                    
    )
    Begin {

        $userdashfile = "$($outputpath)\$($userid)\dashboard\dashboard.json"
        Log-it "The userdashboard file is here $($userdashfile)"
        Try{
            IF(Test-Path -path $userdashfile){
                $jsondash = Get-Content -raw $userdashfile -ErrorAction Stop -ErrorVariable errors
                $jsondatainfo = $jsondash | ConvertFrom-Json
                $data = $jsondatainfo.dashboards

                foreach ($item in $data) {
                    $itemname = $item.id
                    $itemname = $item.name -replace '[^a-zA-Z0-9]', ''
                    $itemJson = $item | ConvertTo-Json -Depth 10
                    $filePath = "$($outputpath)\Dashboard-$itemname.json"
                    Set-Content -Path $filePath -Value $itemJson -ErrorAction Stop -ErrorVariable errors
                }

                # Get all JSON files in the current folder
                $jsonFiles = Get-ChildItem -Path "$($outputpath)\" -Filter *.json -ErrorAction Stop -ErrorVariable errors
				
                # Loop through each file
                foreach ($file in $jsonFiles) {
                    # Read the JSON file and convert it to a PowerShell object
                    $jsonData = Get-Content -Path $file.FullName -Raw | ConvertFrom-Json -ErrorAction Stop -ErrorVariable errors

                    # Add a new line to the JSON object
                    $header = @{"dashboards" = $jsondata}
                    # Convert the PowerShell object back to JSON and save it
                    $header | ConvertTo-Json -Depth 10 | Set-Content -Path $file.FullName -ErrorAction Stop -ErrorVariable errors
                }
            }
        }
        Catch{
            Log-It "There was an error creating the dashboard files"
            Log-It  $_.Exception.Message
            Break
        }
    }
}

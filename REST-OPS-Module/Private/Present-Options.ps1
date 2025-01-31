<###########################################
.SYNOPSIS
This script will Allow the user to choose one of their Dashboards or all of them to export
.DESCRIPTION
This script will Allow the user to choose one of their Dashboards or all of them to export
.NOTES
Author: Anthony Schulte
Created: 01/25/2025
.PARAMETER userid
Pass the token generated from previous script
.EXAMPLE
Present-Options -outputpath <path to dashboardjsons>
#############################################>
Function Present-Options {
    [CmdletBinding()]
    Param(
            [Parameter(Mandatory = $True)]
            [String] $outputpath                    
    )
    Begin {
        # Get all JSON files in the folder
        $jsonFiles = Get-ChildItem -Path $outputpath -Filter "*.json" 
        Log-it "jsonFiles"
        $selectedFiles = @()
        # Check if any JSON files exist
        if ($jsonFiles.Count -eq 0) {
            Log-it "No JSON files found. Stopping script"
            Break
        } else {
            # Display options to the user
            Log-It "JSON files found:"
            for ($i = 0; $i -lt $jsonFiles.Count; $i++) {
                Log-It "$($i + 1). $($jsonFiles[$i].Name)"
            }
            Log-It "$($jsonFiles.Count + 1). All files"

            # Prompt user for selection
            do {
                $choice = Read-Host "Enter your choice (1-$($jsonFiles.Count + 1))"
                if ($choice -eq ($jsonFiles.Count + 1)) {
                    $selectedFiles = $jsonFiles
                    break
                } elseif ($choice -ge 1 -and $choice -le $jsonFiles.Count) {
                    $selectedFiles = $jsonFiles[$choice - 1]
                    break
                } else {
                    Log-It "Invalid choice. Please try again."
                }
            } while ($true)
            
            # Use the selected files
            Log-It "You selected:"
            $selectedFiles | ForEach-Object { Log-It $_.FullName }
            $filenm = @()
            $filenm = $selectedFiles.Name
            Log-it "Here are the file names being passed $($filenm)"
            Return $filenm
        }
    }
}
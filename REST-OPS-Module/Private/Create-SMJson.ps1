<###########################################
.SYNOPSIS
This script will parse the Super Metric and create new file with just the super metrics needed
.DESCRIPTION
This script will parse the Super Metric and create new file with just the super metrics needed
.NOTES
Author: Anthony Schulte
Created: 01/25/2025
.PARAMETER outputpath
Pass the token generated from previous script
.PARAMETER ViewFiles
Pass the token generated from previous script
.EXAMPLE
Create-SMJson -outputpath 'c:\scripts' -ViewFiles 'test.xml'
#############################################>
Function Create-SMjson {
    [CmdletBinding()]
    Param(
            [Parameter(Mandatory = $True)]
            [String] $outputpath,
            [Parameter(Mandatory = $True)]
            [String] $ViewFIles                    
    )
    Begin {

        
		################# Super Metric Section ##############################################
		Log-it "The Script is now extracting the super metrics from the views"
		$superfile = "$($outputpath)\Super-Metrics\supermetrics.json"
		$xmlfileslist = $ViewFIles.Name
		$supmetlist = @()
		$unarr = @()
		#Get the SM metrics from each view
		Foreach($xmlitem in $xmlfileslist){
			#Importing XML File
			Log-It "Importing XML File - $($xmlitem)"
			$sup = @()
			$xml = [xml](Get-Content -Path "$($outputpath)\Views\$($xmlitem)")
			$pattern = "Super Metric|sm_"
			$nodes = $xml.Selectnodes("//*[@id]")
			Log-It $nodes
			#Get the super Metric IDs
			$sup = $nodes.Controls.Control.InnerXML | select-string -pattern $pattern -AllMatches | ForEach-Object {
				$_.Matches[0].Value + $_.Line.Substring($_.Matches[0].Index + $_.Matches[0].Length, 36)
			}
			#Log-it 
			Log-It "The output of the ID is $($sup)"
			#Create a list 
			$unarr = $sup | Get-Unique
			ForEach($uitem in $unarr){
				$pos = $uitem.Indexof("_")
				$rightvalue = $uitem.Substring($pos+1)
				$supmetlist += $rightvalue
			}
			Log-It "So far the super metrics captured are - $($supmetlist)"
		}
		Log-It $supmetlist
		Log-it "Creating a json just with the super metrics identified above"
		
        ####### Create the Super metric File for each metric found ################
		$jsonsup = Get-Content -Raw $superfile | ConvertFrom-Json
		
        # Iterate through properties and values
		foreach ($property in $jsonsup.PSObject.Properties) {
			foreach($supid in $supmetlist){
				If($property.Name -match $supid){
                    $newjson = @{}
                    
                    # Add new data to the new JSON object
                    $newJson.Add($property.Name, $property.value)
                    $jsonsupname = $property.value.name.ToString()
                    $cleanString = $jsonsupname -replace '[^a-zA-Z0-9]', ''
                    # Convert the new JSON object to a string
                    $newJson | ConvertTo-Json -depth 6 | Set-Content -Path "$($outputpath)\Super-Metrics\$($cleanString).json"
                }Else{
                    Log-It "Skipping this id"
                }
			}
		}
    }
}
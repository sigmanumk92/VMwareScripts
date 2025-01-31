<##########################################
.SYNOPSIS
This script will allow the user to choose Their dashboards (1 or all) from the exported content
.DESCRIPTION
This script will allow the user to choose Their dashboards (1 or all) from the exported content
.NOTES
Author: Anthony Schulte
.PARAMETER opsname
Operations Manager Name
.EXAMPLE
Get-OPSDash -opsname vrops.contoso.com
############################################>
function Get-OPSDash {
    [CmdletBinding()]  
    Param(   
        [Parameter(Mandatory = $True)]
        [string]$opsname,
		[Parameter(Mandatory = $False)]
		[System.Management.Automation.Credential()]
		$MyCred = [System.Management.Automation.PSCredential]::Empty
    )  
    Begin {
		#------- Script Setup Variables -------#
		$CurrentScriptFilePath = $script:MyInvocation.MyCommand.Path
		$ScriptCSVFilePath = $CurrentScriptFilePath.Substring(0, $CurrentScriptFilePath.LastIndexOf('.'))
		$CurrentScriptFileName = $script:MyInvocation.MyCommand.Name
		$CurrentScriptFilePathDir = Split-Path $script:MyInvocation.MyCommand.Path
		$CurrentScriptFileName = $CurrentScriptFileName.Substring(0, $CurrentScriptFileName.LastIndexOf('.'))
		$CurrentScriptLastModifiedDateTime = (Get-Item $script:MyInvocation.MyCommand.Path).LastWriteTime
		$mainScriptDir = "$((Get-Item $CurrentScriptFilePathDir).parent.fullname)"
		$mainInputDir = Join-Path -path $CurrentScriptFilePathDir -childpath 'inputs'
		$StartTimer = (Get-Date)
		$user = $env:Username
		#------- Dot Sources -------#
		#. $("$mainInputDir\Write-ToLogFile.ps1") #logs to file
		. $("$mainInputDir\Log-It.ps1") #logs to file

		#Log File
		$outputDir = Join-Path -path $CurrentScriptFilePathDir -childpath 'outputs'
		$outputcsvdir = Join-Path -path $CurrentScriptFilePathDir -childpath 'outputs\CSV-Files'
		$outputexpdir = Join-Path -path $CurrentScriptFilePathDir -childpath 'outputs\Exported-Files'
		$outputfinalexpdir = Join-Path -path $CurrentScriptFilePathDir -childpath 'outputs\Final-exportFiles'
				
		#Create LogFile
		$LogFileNameTimeStamp = (Get-Date).ToString('MMddyyyy_hhmmss')
		$TimeStamp = (Get-Date -Format G)
		$LogFile = "$outputDir\Get-OPSDash-" + $LogFileNameTimeStamp + ".log"
		
		Add-Content -Path $LogFile -Value "********************* Beginning Script @ $($TimeStamp)  **********************"
		#------- Log Header -------#
		Log-It " Path: $CurrentScriptFilePath"
		Log-It " Modified: $CurrentScriptLastModifiedDateTime"
		Log-It  " User: $user" 
		Log-It  " Start: $startTimer"
		Log-It  "#------------------------------------#"
		
		#------- Sets Script Run Location -------#
		Set-Location -Path $CurrentScriptFilePathDir
		Log-It  "Directory set to: $CurrentScriptFilePathDir"

		#------- ConSole Output Header -------#
		Log-It  "Script Path: $CurrentScriptFilePath"
		Log-It  "Last Modified: $CurrentScriptLastModifiedDateTime"
			
		#Begin Main Script
		# Get today's date
        $CurrentDate = Get-Date
        $CurrentDate = $CurrentDate.ToString('MM-dd-yyyy_hhmmss')
        Write-Host "Note: This Script will only allow you to choose from the dashboards that you own.  You may choose one or all of your Dashboards.  It will separate these and their views and metrics and associate them together in a zip file. "	-ForegroundColor Green
		Log-It "Trying to connect to the Operations Server."

        try {
            If($mycred){
				Log-it "Credential was found from previous script, using that credential"
				$token = Connect-OPSREST -opsname $opsname -MyCredential $mycred
			}Else{
				$mycred = Get-Credential
            	$token = Connect-OPSREST -opsname $opsname -MyCredential $mycred
			}
            Log-it "The Token that was passed - $token"
            if($token){
                Log-it "The connect Script passed the token properly $token"
            }Else{
                Log-it "The token didnt pass properly and is null.  Exiting the Script"
                Break
            }
		}

        catch {
            Log-It "There was an error getting the token"
            Log-It  $_.Exception.Message
		    Log-It  "Script has failed."
           }
        
        
    }#Begin phase ends
    Process {
        ############### Testing the Token can connect to Operations Section ###################################
		#Checking if the Connection is working properly
		Log-It "Checking if the token is working properly.  Getting the Version of OPS"
		$verJson = Get-OPSVersion -opsname $opsname -Token $token
		$verdata = $verJson | ConvertTo-Json -depth 6
		$versd = $verdata | convertfrom-json
		$versinfo = @()
		ForEach($veritem in $versd){
			$objverinfo = New-Object psobject -Property @{
				'Release Name' = $veritem.releaseName
				'Build Number' = $veritem.buildNumber
				'Release Date' = $veritem.humanlyReadableReleaseDate
			}
			$versinfo += $objverinfo
		}
		$versinfo | format-table -AutoSize | Out-string -Stream | Foreach-object{Log-it $_}
		
		Log-it "Looking for the Zip File in the outputs"
		$zipname = Get-ChildItem -Path "$($outputcsvdir)\$($opsname)-content.zip"
		If (Test-Path -path $zipname){
			Log-It "The Zip file was found - review the details and ensure that is the correct date"
			Log-it $zipname
			Pause
		}Else{
			Log-it "Could not find the zip file in output folder"
		}
		
		###################### File Moving Section ###########################################
		#expand the archive
		Try{
			Log-it "The Script is now expanding archives and moving files around"
			If(Test-path -path $zipname){
				Expand-Archive -Path $zipname -DestinationPath "$($outputcsvdir)\$($opsname)-content" -force -ErrorAction Stop -ErrorVariable errors
				
			}
		}
		Catch{
			Log-It "There was an error unzipping the file"
            Log-It  $_.Exception.Message
		}
		Log-It "Starting Sleep for 30 while expanding"
		Start-Sleep 30
		#expand the views
		Log-It "The views are being expanded"
		$viewzip = "$($outputcsvdir)\$($opsname)-content\views.zip"
		Try{
			If(Test-path -path $viewzip){
				Log-it "Starting the expand of the views file"
				Expand-Archive -Path $viewzip -DestinationPath "$($outputcsvdir)\$($opsname)-content\Views" -force -ErrorAction Stop -ErrorVariable errors
				Log-it "Starting sleep for 30 while views zip expands"
			}
		}
		Catch{
			Log-It "There was an error unzipping the file"
            Log-It  $_.Exception.Message
		}
		Start-sleep 30

		#move the super metrics json file to proper folder
		Log-it "Moving the super metrics file"
		$supermetricjson = "$($outputcsvdir)\$($opsname)-content\supermetrics.json"
		If(Test-path -path $supermetricjson){
			Log-it "Super metric file was found and moving to export directory"
			Move-Item -Path $supermetricjson -Destination "$($outputexpdir)\Super-Metrics" -force
		}Else{
			Log-it "There was an issue finding the supermetrics file"
			break
		}
		start-sleep 5
		#move the custom groups json file to proper folder
		Log-it "Moving the custom group file"
		$customgroupjson = "$($outputcsvdir)\$($opsname)-content\customgroups.json"
		If(Test-path -path $customgroupjson){
			Move-Item -Path $customgroupjson -Destination "$($outputexpdir)\Custom-Groups" -force
		}Else{
			Log-it "There was an issue finding the Custom Group file"
			Break
		}
		Start-sleep 5
		#Get the userID from the token
		Log-It "getting the User GUID from the token"
		$userid = ($token -split "::")[0]
		Log-it $userid

		#Change the file name for the user that contains their dashboards - it is a zip
		Log-it "Adding the Zip extension at the end of the file for the user"
		Get-ChildItem -Path "$($outputcsvdir)\$($opsname)-content\dashboards\$userid" -File | Where-object { -not $_.Extension } | Rename-Item -NewName { $_.Name + ".zip" }
		$userzip = 	"$($outputcsvdir)\$($opsname)-content\dashboards\$($userid).zip"
		#Expand the archive to get the Dashboards
		Log-it "Expanding the User dashboards zip"
		If(Test-path -path $userzip){
			Expand-Archive -Path $userzip -DestinationPath "$($outputexpdir)\$userid" -Force
		}Else{
			Log-it "Could not find the user zip file"
			Break
		}
		Start-sleep 10

		######################### Get the Users Dashboards Section ##########################
		#Parse through the json and separate each dashboard into their own Json file
		log-it	"Parsing through the json and separate each dashboard into their own Json file"
		Create-Dashjson -userid $userid -outputpath $outputexpdir

		#Give the user an option to get 1 or all the dashboards
		$optionChoice = Present-Options -outputpath $outputexpdir
		Log-it "$optionChoice"
		Log-it "There are $($optionChoice.count) Dashboards to get the view ids for."
		########################## Get View IDs From Dashboards Section #####################
		Log-it "The Script is now getting the view ids used in the dashboards identified by user"
		If ($optionChoice.count -eq 1){
			#Get Dashboard and get the views from the json
			$viewid = @()
			$viewid = Get-ViewIds -outputpath $outputexpdir -dashname $optionChoice
			Log-It "$($viewid)"
			IF($viewid.count -gt 1){
				ForEach($viewitem in $viewid){
					$objviewinfo = New-Object psobject -Property @{
						"ViewID" = $viewitem
						"Dashboard" = $optionChoice
						}
					$viewinfo = $objviewinfo
				}
			}Else{
				Log-It "Only found 1 view - $viewid"
			}	
		}Else{
			$viewinfo = @()
			Foreach($option in $optionchoice){
				#Get Dashboard and get the views from the json
				$viewid = @()
				$viewid = Get-ViewIds -outputpath $outputexpdir -dashname $option
				Log-It "$($viewid)"
				ForEach($viewitem in $viewid){
					$objviewinfo = New-Object psobject -Property @{
						"ViewID" = $viewitem
						"Dashboard" = $option
						}
					$viewinfo += $objviewinfo
				}
			}
		}
		$viewinfo | format-table -AutoSize | Out-string -Stream | Foreach-object{Log-it $_}
		$viewinfo | export-csv -path "$outputcsvdir\viewinfo.csv" -NoTypeInformation
		
		#Separate the View files into their own XML files
		$viewfile = "$($outputcsvdir)\$($opsname)-content\views\content.xml"
		$viewoutfiles = "$($outputexpdir)\Views"
		#Create the newXML View Files
		Create-NewXML -ViewXMLFile $viewfile -outputpath $viewoutfiles
		#remove the csv now
		Remove-Item -Path "$($outputcsvdir)\viewinfo.csv"
		#Show the list of files
		$xmlfiles = Get-ChildItem -Path $viewoutfiles -Filter "*.xml"
		Log-it $xmlfiles
		
		Log-it "Creating the Json File"
		Create-SMJson -outputpath $outputexpdir -ViewFiles $xmlfiles
		
		################ Moving all of the Items to the Final folder for export ########################
		Pause
		#Get all super metric JSON files in the current folder
		Move-item -path "$($outputexpdir)\Super-Metrics\supermetrics.json" -Destination "$($outputexpdir)\Old"
		$jsonFiles = Get-ChildItem -Path "$($outputexpdir)\Super-Metrics" -Filter *.json 
		Log-it $jsonFiles
		Move-item -path "$($outputexpdir)\Super-Metrics\*.json" -Destination "$($outputfinalexpdir)\" -Force
		#Compress the super metric
		$supexpjson = "$($outputfinalexpdir)\Super-Metrics\*.json"
		If(Test-path -Path $supexpjson){
			Compress-Archive -Path $supexpjson -DestinationPath "$($outputfinalexpdir)\supermetrics-exp-$($CurrentDate).zip"
		}else{
			Log-it "Unable to compress the super metric"
		}
		#move the Dashboards content file to proper folder
		Log-it "Moving the dashboards files to final export folder"
		If(Test-path -path "$($outputexpdir)\*.json"){
			Move-Item -Path "$($outputexpdir)\*.json" -Destination "$($outputfinalexpdir)\" -Force
		}Else{
			Log-it "Unable to move dashboards to final folder"
		}
		Log-it "Zipping the Dashboard folder"
		If(Test-Path -path "$($outputfinalexpdir)\Dashboards\*.json"){
			Compress-Archive -path "$($outputfinalexpdir)\Dashboards\*.json" -DestinationPath "$($outputfinalexpdir)\Dashboards-exp-$($CurrentDate).zip"
		}Else{
			Log-it "Unable to compress dashboards"
		}
		#move the views content file to proper folder
		Log-it "Moving the views file to final export folder"
		$viewexpfile = "$($outputexpdir)\Views\*.xml"
		If(Test-path -Path $viewexpfile){
			Move-Item -Path $viewexpfile -Destination "$($outputfinalexpdir)\" -Force
		}else {
			Log-it "Unable to move views to final folder"
		}
		If(Test-Path -path "$($outputfinalexpdir)\Views\*.xml"){
			Compress-Archive -path "$($outputfinalexpdir)\Views\*.xml" -DestinationPath "$($outputfinalexpdir)\Views-exp-$($CurrentDate).zip"
		}else{
			Log-it "Unable to compress the views"
		}
	
		#Remove the Ops Download Zip
		Log-it "Cleaning up the files for next run"
		Remove-item -Path "$($outputexpdir)\$($userid)"
		Remove-item -Path "$($outputcsvdir)\$($opsname)-content\*.*"
			
    }
    End{
        Log-It "We are finished, ending the session"
      
        Disconnect-OPSREST -opsname $opsname
        Log-It "Successfully Disconnected from Operations"
        #------- Output script time to host -------#
		Log-It  "`nScript Time: $(($EndTimer-$StartTimer).totalseconds) seconds"
		$FinishDate = Get-Date
		$FinishDate = $FinishDate.ToString('MM-dd-yyyy_hhmmss')
		Log-It 'Script Complete'
    }#End phase ends
}
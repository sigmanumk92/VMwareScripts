<##########################################
.SYNOPSIS
This script will allow the user export the content from Aria Operations and allow the user to choose Their dashboards (1 or all)
.DESCRIPTION
This script will allow the user export the content from Aria Operations and allow the user to choose Their dashboards (1 or all)
.NOTES
Author: Anthony Schulte
.PARAMETER opsname
Operations Manager Name
.EXAMPLE
Export-OPSContent -opsname vrops.contoso.com
############################################>
function Export-OPSContent {
    [CmdletBinding()]  
    Param(   
        [Parameter(Mandatory = $True)]
        [string]$opsname
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
		$LogFile = "$outputDir\Export-OPSContent-" + $LogFileNameTimeStamp + ".log"
		
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
        Write-Host "Note: This Script will only allow you export the content from Aria Operations.  This Script downloads all Dashboards, Views, Super Metics, and Custom Groups.  The Zip is then downloaded to the output-CSV-Files folder for use with get-opsdash command."	-ForegroundColor Green		
		Log-It "Trying to connect to the Operations Server."

        try {
            $mycred = Get-Credential
            $token = Connect-OPSREST -opsname $opsname -MyCredential $mycred

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
		
		##################### Getting the Content From Operations Manager Section #################################
		#Check to see if there is a Zip File already downloaded and error out
		Log-it "The Script is now Connecting Operations Manager and Getting the content"
		
		Log-It "Checking to see if there is a content zip for the Operations Manager in the folder"
		$opscontfile = "$($outputcsvdir)\$($opsname)-content.zip"
		
		If (Test-Path -Path $opscontfile){
			Log-it $opscontfile
            Log-it "A content export exists already. Look at the date of the zip file"
            $response = Read-Host "Do you want to use the existing zip file? (y/n)"
                If ($response -eq "y" -or $response -eq "Y"){
                    Log-it "You chose to use the existing zip - use the Get-OPSDash command to get the dashboard files"
                    $response2 = Read-host "Would you like to run the Get-OpsDash command now? (y/n)"
                    If ($response2 -eq "y" -or $response2 -eq "Y"){
                        Log-It "Ok - Lets get your Dashboards now!"
                        Get-OPSDash -opsname $opsname -MyCred $mycred
						Log-it "Export-OPSContent is now complete - Scripting ending now"
						#------- Output script time to host -------#
						Log-It  "`nScript Time: $(($EndTimer-$StartTimer).totalseconds) seconds"
						$FinishDate = Get-Date
						$FinishDate = $FinishDate.ToString('MM-dd-yyyy_hhmmss')
						Log-It 'Script Complete'
                    }
                }Else{
                    Log-it "You chose to not use the existing zip. Moving the existing zip to the Old-Zips folder"
                    Move-Item -Path $opscontfile -Destination "$($outputcsvdir)\Old-Zips" -Force
                }
			
		}Else{
			Log-it "File does not exist proceeding to download the content"
		}
		
		#Get All Content
		Log-It "Getting the content this process takes about 20 min.  The Process is quick the api does not make it available right away."
        Get-OPSContent -opsname $opsname -Token $token
		
		Log-it "Sleeping for 20 minutes while the zip is generated"
		Start-Sleep 1200
		#Reconnect to OPS after 20 min of inactivity
		$token2 = Connect-OPSREST -opsname $opsname -MyCredential $mycred
        
        #Export the Content
		Log-It "Exporting the Content"
		Get-OPSContentEXP -opsname $opsname -token $token2 -outpath $outputcsvdir
		
        Log-it "Let's check if the zip file was generated correctly"
        $getzip = "$($outputcsvdir)\$($opsname)-content.zip"
		
		If (Test-Path -Path $getzip){
			Log-it $getzip
            Log-it "Looks like the zip exported correctly"
            $response = Read-Host "Do you want to run the Get-OPSDash command now? (y/n)"
                If ($response -eq "y" -or $response -eq "Y"){
                    Log-it "OK - Lets get the Dashboards"
                    Get-OPSDash -opsname $opsname -MyCred $mycred
                }
                Else{
                    Log-it "You chose to work on this later - Run The Get-OPSDash command to get the dashboards"
                }
			
		}Else{
			Log-it "Hmmm - Something happened the zip didn't download from Aria Operations.  An investigation is needed."
		}
    }
    End{
        Log-It "We are finished getting the content, ending the session"
      
        Disconnect-OPSREST -opsname $opsname
        Log-It "Successfully Disconnected from Operations"
        #------- Output script time to host -------#
		Log-It  "`nScript Time: $(($EndTimer-$StartTimer).totalseconds) seconds"
		$FinishDate = Get-Date
		$FinishDate = $FinishDate.ToString('MM-dd-yyyy_hhmmss')
		Log-It 'Script Complete'
    }#End phase ends
}
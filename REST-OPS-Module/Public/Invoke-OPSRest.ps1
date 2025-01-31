<##########################################
.SYNOPSIS
This script will allow the user to use the various API to work with aria operations
.DESCRIPTION
This script will allow the user to use the various API to work with aria operations
.NOTES
Author: Anthony Schulte
.PARAMETER opsname
Operations Manager Name
.EXAMPLE
Invoke-OPSRest -opsname vrops.contoso.com
############################################>
function Invoke-OPSRest{
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
				
		#Create LogFile
		$LogFileNameTimeStamp = (Get-Date).ToString('MMddyyyy_hhmmss')
		$TimeStamp = (Get-Date -Format G)
		$LogFile = "$outputDir\Invoke-OPSREST-" + $LogFileNameTimeStamp + ".log"
		$csvalert = "$outputDir\CSV-Files\OpsAlertdata-" + $LogFileNameTimeStamp + ".csv"
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
        Log-It "Trying to connect to the Operations Server."

        try {
            $token = Connect-OPSREST -opsname $opsname

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
        
        #Get the version of Operations
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
		
		#Get all of the alerts and export them to csv
		$alertdata = @()
		$alertdatajson = Get-OPSAlerts -opsname $opsname -Token $token
		$alertdata = $alertdataJson.alerts | ConvertTo-Json -depth 6
		
		#make sure the csv location is good
		Log-It $csvalert
		$alertdata | ForEach-Object{ New-Object PSObject -Property $_ } | export-csv -Path $csvalert
				   
    }
    End{
        Log-It "We are finished, ending the session"
      
        Disconnect-OPSREST -opsname $opsname
        Log-It "Successfully Disconnected from Operations"
        #------- Output script time to host -------#
		Log-It  "`nScript Time: $(($EndTimer-$StartTimer).totalseconds) seconds"
		$FinishDate = Get-Date
		$FinishDate = $FinishDate.ToString('MM-dd-yyyy_hhmmss')
		Write-Output 'Script Complete'
    }#End phase ends
}
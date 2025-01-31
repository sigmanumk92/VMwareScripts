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
Invoke-GetUser -opsname vrops.contoso.com
############################################>
function Invoke-GetUser{
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
		
		#------- Dot Sources -------#
		#. $("$mainInputDir\Write-ToLogFile.ps1") #logs to file
		. $("$mainInputDir\Log-It.ps1") #logs to file
		$user = $env:USERNAME
		#Log File
		$outputDir = Join-Path -path $CurrentScriptFilePathDir -childpath 'outputs'
				
		#Create LogFile
		$LogFileNameTimeStamp = (Get-Date).ToString('MMddyyyy_hhmmss')
		$TimeStamp = (Get-Date -Format G)
		$LogFile = "$outputDir\Invoke-Getuser-" + $LogFileNameTimeStamp + ".log"
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
        $userfromJson = Get-OPSuser -opsname $opsname -token $token
		$data = $userfromJson | ConvertTo-Json -depth 6
		$data | Out-File "C:\Users\ASchulte\Documents\Scripts\REST-OPS-Module\Outputs\CSV-Files\userjson.json"
		$userdata = Get-Content -Raw "C:\Users\ASchulte\Documents\Scripts\REST-OPS-Module\Outputs\CSV-Files\userjson.json" | convertfrom-json
		$userinfo = $userdata.users | where{$_.username -match $user}
		$userinfid = $userinfo.id | Out-string
		Log-it "The userid for $($user) is $($userinfid)"
		Return $userinfid
		
		#get user ID info
		$userfromJson = Get-OPSuserID -opsname $opsname -token $token -userID $userinfid
		$data = $userfromJson | ConvertTo-Json -depth 6
		$data | out-file outjsonid.json
		
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
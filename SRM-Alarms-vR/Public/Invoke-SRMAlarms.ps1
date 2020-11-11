<#
.SYNOPSIS
This script will allow the user to create the SRM Alarms using SNMP
.DESCRIPTION
This script will create the SRM Alarms for each instance of SRM. 
.NOTES
Author: Anthony Schulte
.PARAMETER Credential
Credential to use for connection.
.PARAMETER vCenter
vCenter Address to connect to.
.EXAMPLE
Invoke-SRMAlarms -vCenter vcenter.contoso.com -SRMinst "C:\srminstances.text
#>
function Invoke-SRMAlarms {
    [CmdletBinding()]   
    Param(   
        [Parameter(Mandatory = $True)]
        [string]$vCenter,
		[Parameter(Mandatory = $True)]
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf})]
        [ValidatePattern( '\.txt$' )]
        [string]$SRMInst,
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )  
    Begin {
        Import-Module VMware.VimAutomation.core -Verbose:$false
		Import-Module VMware.VimAutomation.common -Verbose:$false
		$Credential = Get-Credential
        $user = $Credential.GetNetworkCredential().username
        $pass = $Credential.GetNetworkCredential().password
        $domain = $Credential.GetNetworkCredential().domain
      
		
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
		. $("$mainInputDir\ArrayToHTML.ps1") #Converts collection to HTML for purpose of emailing
		. $("$mainInputDir\Write-ToLogFile.ps1") #logs to file
		
		
		#Log File
		$outputDir = Join-Path -path $CurrentScriptFilePathDir -childpath 'outputs'
		$outputDir = Join-Path -path $CurrentScriptFilePathDir -childpath 'outputs'
		$logFile = "$outputDir\$($CurrentScriptFileName) $(Get-Date -format "yyyy-mm-MM-hh-mm-ss").log"
		$hostlog = "$outputDir\HostsList $(Get-Date -format "yyyy-mm-MM-hh-mm-ss").log"
		#------- Log Header -------#
		Write-ToLogFile -logPath $logFile "#----------- Begin Script -----------#"
		Write-ToLogFile -logPath $logFile " Path: $CurrentScriptFilePath"
		Write-ToLogFile -logPath $logFile " Modified: $CurrentScriptLastModifiedDateTime"
		Write-ToLogFile -logPath $logFile " User: $user" 
		Write-ToLogFile -logPath $logFile " Start: $startTimer"
		Write-ToLogFile -logPath $logFile "#------------------------------------#"
		
		#------- Sets Script Run Location -------#
		Set-Location -Path $CurrentScriptFilePathDir
		Write-ToLogFile -logPath $logfile "Directory set to: $CurrentScriptFilePathDir" 

		#------- ConSole Output Header -------#
		Write-ToLogFile -logPath $logfile "Script Path: $CurrentScriptFilePath" 
		Write-ToLogFile -logPath $logfile "Last Modified: $CurrentScriptLastModifiedDateTime" 
		
		 #Import Instances#
        Write-Verbose -Message 'Importing the SRM Instance List'    
        try {
            $SRMNames = Get-Content $SRMInst -ErrorAction Stop
			Write-ToLogFile -logPath $logfile "The Following SRM instances are in the environment: $SRMInst"
            }

        catch {
            Write-Error "Error validating data." 
			Write-ToLogFile -logPath $logfile "Error Validating data"
            }
        
		
		#Begin Main Script
		
		#Connect to vCenter#
        Connect-vCenter -vCenter $vCenter -usernames $user -passwords $pass -logs $logFile
		Write-ToLogFile -logPath $logfile "Connected to vCenter"
			
        # Get today's date
        
        $CurrentDate = Get-Date
        $CurrentDate = $CurrentDate.ToString('MM-dd-yyyy_hhmmss')
        Write-ToLogFile -logPath $logfile "Starting to add Alarms"
		
		
     			$alarmMgr = Get-View AlarmManager
				$alarms = New-Object VMware.Vim.AlarmSpec
				#Add Alarms That use SRM Instances
                Foreach ($SRMlist in $SRMNames) {
				
				SRM-AlarmsCertExpire -alarm $alarms -SRMinstance $SRMlist
				Write-ToLogFile -logPath $logfile "Alarm for Expiring SRM Certs"
				
				SRM-AlarmsDSnotRepl -alarm $alarms -SRMinstance $SRMlist
				Write-ToLogFile -logPath $logfile "Alarm Datastore Not Replicating"
				
				SRM-AlarmsDSProtMissing -alarm $alarms -SRMinstance $SRMlist
				Write-ToLogFile -logPath $logfile "Alarm Datastore Protection missing"
			    
				SRM-AlarmsDSUnprotected -alarm $alarms -SRMinstance $SRMlist
				Write-ToLogFile -logPath $logfile "Alarm Datastore Not Protected"
				
				SRM-AlarmsLicenseExpiring -alarm $alarms -SRMinstance $SRMlist
				Write-ToLogFile -logPath $logfile "Alarm License Expiring"
				
				SRM-AlarmsProtectedVMRemoved -alarm $alarms -SRMinstance $SRMlist
				Write-ToLogFile -logPath $logfile "Alarm Protected VM Removed"
				
				SRM-AlarmsRemoteSiteDown -alarm $alarms -SRMinstance $SRMlist
				Write-ToLogFile -logPath $logfile "Alarm Remote Site Down"
				
				SRM-AlarmsUnknownStatus -alarm $alarms -SRMinstance $SRMlist
				Write-ToLogFile -logPath $logfile "Alarm SRM Unknown status"
				} #End ForEach
				
				SRM-AlarmslocalPingFail -alarm $alarms
				Write-ToLogFile -logPath $logfile "Alarm Local Ping Fail"
				
				SRM-AlarmsPlcHoldDeleted -alarm $alarms
				Write-ToLogFile -logPath $logfile "Alarm PlaceHolder Deleted"
				
				SRM-AlarmsProdVMdel -alarm $alarms
				Write-ToLogFile -logPath $logfile "Alarm Prod VM Deleted"
				
				SRM-AlarmsProdVMInvalid -alarm $alarms
				Write-ToLogFile -logPath $logfile "Alarm Prod VM Invalid"
				
				SRM-AlarmsProtectedVMnotProt -alarm $alarms
				Write-ToLogFile -logPath $logfile "Alarm VM Not Protected"
				
				SRM-AlarmsProtectedVMReconfig -alarm $alarms
				Write-ToLogFile -logPath $logfile "Alarm Protected VM is being Reconfigured"
											
				SRM-AlarmsRemotePingFail -alarm $alarms
				Write-ToLogFile -logPath $logfile "Alarm Remote Ping Fail"
								
				SRM-AlarmsRPBegins -alarm $alarms
				Write-ToLogFile -logPath $logfile "Alarm Recovery Plan Begins"
								
				SRM-AlarmsVMProtRestore -alarm $alarms
				Write-ToLogFile -logPath $logfile "Alarm VM Protection Restored"

				SRM-VRRepunconfig -$alarms
				Write-ToLogFile -logPath $logfile "Alarm VM Replication Unconfigured"

				SRM-VRReplmissing -$alarms
				Write-ToLogFile -logPath $logfile "Alarm VM Replication missing"

				SRM-VRRPOissue -$alarms
				Write-ToLogFile -logPath $logfile "Alarm VM RPO Issue"

				SRM-VRVMDisk -$alarms
				Write-ToLogFile -logPath $logfile "Alarm VM Disk issue"
		   
				SRM-VRSiteIssue -$alarms
				Write-ToLogFile -logPath $logfile "Alarm VR Site issue"


			Write-ToLogFile -logPath $logfile " - script section executed" 
        
    
		
		#Disconnect the vCenter		
		Disconnect-vCenter
    

		#------- Output script time to host -------#
		Write-ToLogFile -logPath $logfile "`nScript Time: $(($EndTimer-$StartTimer).totalseconds) seconds"  
		#$FinishDate = $FinishDate.ToString('MM-dd-yyyy_hhmmss')
		Write-Output 'Script Complete'
    }
	}#End Function#
	



        
           




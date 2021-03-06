<#
.SYNOPSIS
Creates the Alarm For the Placeholder vm Deleted
.DESCRIPTION
This script Creates the Alarm For Placeholder vm Deleted.
.NOTES
Author: Anthony Schulte
#>
Function SRM-AlarmsPlcHoldDeleted {
 [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        $alarm,  
		[Parameter(Mandatory = $False)]
        $logs
		)


$alarm.Name = "Placeholder VM Deleted"

$alarm.Description = "Virtual machine in group is not deleted."

$alarm.Enabled = $TRUE


# Event expression 1 - "Virtual machine in group is no longer configured for protection."

# will change state to "Red"

$expression1 = New-Object VMware.Vim.EventAlarmExpression

$expression1.EventType = $Null

$expression1.eventTypeId = "com.vmware.vcDr.PholderVMUnexpectDeleteEvent"

$expression1.objectType = "VirtualCenter"

$expression1.status = "red"


# Add event expressions to alarm

$alarm.expression = New-Object VMware.Vim.OrAlarmExpression

$alarm.expression.expression += $expression1

 

# Create alarm in vCenter root

$alarmMgr.CreateAlarm("Folder-group-d1",$alarm)

  

# Add action (send mail) to the newly created alarm

Get-AlarmDefinition $alarm.Name | New-AlarmAction -Snmp

# New-AlarmAction will automatically add the trigger Yellow->Red (!)

 

# Add a second trigger for Yellow->Green

Get-AlarmDefinition $alarm.Name | Get-AlarmAction | New-AlarmActionTrigger -StartStatus "Yellow" -EndStatus "Green"

}
<#
.SYNOPSIS
Creates the Alarm For the SRM Remote Ping Fail
.DESCRIPTION
This script Creates the Alarm For SRM Remote Ping Fail.
.NOTES
Author: Anthony Schulte
#>
Function SRM-AlarmsRemotePingFail {
 [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        $alarm,  
		[Parameter(Mandatory = $False)]
        $logs
		)

#$alarmMgr = Get-View AlarmManager

# Create AlarmSpec object

#$alarm = New-Object VMware.Vim.AlarmSpec

$alarm.Name = "SRM Remote Site Ping Fail"

$alarm.Description = "SRM Remote Instance Ping Fail."

$alarm.Enabled = $TRUE


# Event expression 1 - "Virtual machine in group is no longer configured for protection."

# will change state to "Red"

$expression1 = New-Object VMware.Vim.EventAlarmExpression

$expression1.EventType = $Null

$expression1.eventTypeId = "com.vmware.vcDr.RemoteSitePingFailedEvent"

$expression1.objectType = "VirtualCenter"

$expression1.status = "red"


# Attribute comparison for expression 1

#$comparison1 = New-Object VMware.Vim.EventAlarmExpressionComparison

#$comparison1.AttributeName = "Placeholder VM Created (h-srmpmlab-msn-1)"

#$comparison1.Operator = "notEqualTo"

#$comparison1.Value = "1"

#$expression1.Comparisons += $comparison1

# Event expression 2 - Placeholder VM Created (h-srmpmlab-msn-1) restored

# will change state back to "Green"

$expression2 = New-Object VMware.Vim.EventAlarmExpression

$expression2.EventType = $Null

$expression2.eventTypeId = "com.vmware.vcDr.RemoteSiteUpEvent"

$expression2.objectType = "VirtualCenter"

$expression2.status = "Green"

# Add event expressions to alarm

$alarm.expression = New-Object VMware.Vim.OrAlarmExpression

$alarm.expression.expression += $expression1

$alarm.expression.expression += $expression2

 

# Create alarm in vCenter root

$alarmMgr.CreateAlarm("Folder-group-d1",$alarm)

  

# Add action (send mail) to the newly created alarm

Get-AlarmDefinition $alarm.Name | New-AlarmAction -Snmp

# New-AlarmAction will automatically add the trigger Yellow->Red (!)

 

# Add a second trigger for Yellow->Green

Get-AlarmDefinition $alarm.Name | Get-AlarmAction | New-AlarmActionTrigger -StartStatus "Yellow" -EndStatus "Green"

}

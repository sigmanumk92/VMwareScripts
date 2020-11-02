<#
.SYNOPSIS
Creates the Alarm For the Ping Failed for Local SRM 
.DESCRIPTION
This script Creates the Alarm For Ping Failed for Local SRM.
.NOTES
Author: Anthony Schulte
#>
Function SRM-AlarmslocalPingFail {
 [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        $alarm,  
		[Parameter(Mandatory = $False)]
        $logs
		)



$alarm.Name = "SRM Local Site Ping Fail"

$alarm.Description = "SRM Local Instance Ping Fail."

$alarm.Enabled = $TRUE


# Event expression 1 

# will change state to "Red"

$expression1 = New-Object VMware.Vim.EventAlarmExpression

$expression1.EventType = $Null

$expression1.eventTypeId = "com.vmware.vcDr.LocalHmsPingFailedEvent"

$expression1.objectType = "VirtualCenter"

$expression1.status = "Red"

# Event expression 2 - "Virtual machine in group is no longer configured for protection."

# will change state to "Red"

$expression2 = New-Object VMware.Vim.EventAlarmExpression

$expression2.EventType = $Null

$expression2.eventTypeId = "com.vmware.vcDr.LocalHmsConnectionDownEvent"

$expression2.objectType = "VirtualCenter"

$expression2.status = "Red"


# Attribute comparison for expression 1

#$comparison1 = New-Object VMware.Vim.EventAlarmExpressionComparison

#$comparison1.AttributeName = "Placeholder VM Created (h-srmpmlab-msn-1)"

#$comparison1.Operator = "notEqualTo"

#$comparison1.Value = "1"

#$expression1.Comparisons += $comparison1

# Event expression 3 - Placeholder VM Created (h-srmpmlab-msn-1) restored

# will change state back to "Green"

$expression3 = New-Object VMware.Vim.EventAlarmExpression

$expression3.EventType = $Null

$expression3.eventTypeId = "com.vmware.vcDr.LocalHmsConnectionUpEvent"

$expression3.objectType = "VirtualCenter"

$expression3.status = "Green"

# Add event expressions to alarm

$alarm.expression = New-Object VMware.Vim.OrAlarmExpression

$alarm.expression.expression += $expression1

$alarm.expression.expression += $expression2

$alarm.expression.expression += $expression3

# Create alarm in vCenter root

$alarmMgr.CreateAlarm("Folder-group-d1",$alarm)

  

# Add action (send mail) to the newly created alarm

Get-AlarmDefinition $alarm.Name | New-AlarmAction -Snmp

# New-AlarmAction will automatically add the trigger Yellow->Red (!)

 

# Add a second trigger for Yellow->Green

Get-AlarmDefinition $alarm.Name | Get-AlarmAction | New-AlarmActionTrigger -StartStatus "Yellow" -EndStatus "Green"

}

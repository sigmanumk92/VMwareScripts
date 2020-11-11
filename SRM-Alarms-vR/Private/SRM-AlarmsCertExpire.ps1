<#
.SYNOPSIS
Creates the Alarm For the SRM Certificate Expiration
.DESCRIPTION
This script Creates the Alarm For the SRM Certificate Expiration.
.NOTES
Author: Anthony Schulte
#>
Function SRM-AlarmsCertExpire {
 [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        $alarm,
		[Parameter(Mandatory = $True)]
        $SRMinstance,
		[Parameter(Mandatory = $False)]
        $logs
		)

$alarm.Name = "SRM certificate Expiring $SRMinstance"

$alarm.Description = "SRM certificate Expiring."

$alarm.Enabled = $TRUE


# Event expression 1"

# will change state to "Red"

$expression1 = New-Object VMware.Vim.EventAlarmExpression

$expression1.EventType = $Null

$expression1.eventTypeId = "SRM Server certificate expiring ($SRMinstance)"

$expression1.objectType = "VirtualCenter"

$expression1.status = "Red"


# Attribute comparison for expression 1

#$comparison1 = New-Object VMware.Vim.EventAlarmExpressionComparison

#$comparison1.AttributeName = "Placeholder VM Created (h-srmpmlab-msn-1)"

#$comparison1.Operator = "notEqualTo"

#$comparison1.Value = "1"

#$expression1.Comparisons += $comparison1



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

<#
.SYNOPSIS
Creates the Alarm For the RPO Violated
.DESCRIPTION
This script Creates the Alarm For RPO Violated.
.NOTES
Author: Anthony Schulte
#>
Function SRM-VRRPOissue {
 [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        $alarm,
		[Parameter(Mandatory = $False)]
        $logs
		)


$alarm.Name = "VR VM RPO Violated"

$alarm.Description = "VR VM RPO Violated."

$alarm.Enabled = $TRUE


# Event expression 1 - "Virtual machine RPO violated."

# will change state to "Red"

$expression1 = New-Object VMware.Vim.EventAlarmExpression

$expression1.EventType = $Null

$expression1.eventTypeId = "com.vmware.vcHms.rpoViolatedEvent"

$expression1.objectType = "VirtualMachine"

$expression1.status = "Red"

# Event expression 1 - "Virtual machine RPO Restored."

# will change state to "Green"

$expression2 = New-Object VMware.Vim.EventAlarmExpression

$expression2.EventType = $Null

$expression2.eventTypeId = "com.vmware.vcHms.rpoRestoredEvent"

$expression2.objectType = "VirtualMachine"

$expression2.status = "Green"

# Attribute comparison for expression 1

#$comparison1 = New-Object VMware.Vim.EventAlarmExpressionComparison

#$comparison1.AttributeName = "Placeholder VM Created (h-srmpmlab-msn-1)"

#$comparison1.Operator = "notEqualTo"

#$comparison1.Value = "1"

#$expression1.Comparisons += $comparison1



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

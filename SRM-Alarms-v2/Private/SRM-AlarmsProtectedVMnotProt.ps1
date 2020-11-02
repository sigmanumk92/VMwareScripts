<#
.SYNOPSIS
Creates the Alarm For the Protected VMs not protected anymore
.DESCRIPTION
This script Creates the Alarm For Protected VMs not protected anymore.
.NOTES
Author: Anthony Schulte
#>
Function SRM-AlarmsProtectedVMnotProt {
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

$alarm.Name = "SRM VM not Protected"

$alarm.Description = "SRM Protected VM not protected."

$alarm.Enabled = $TRUE


# Event expression 1 - "Virtual machine in group is no longer configured for protection."

# will change state to "Red"

$expression1 = New-Object VMware.Vim.EventAlarmExpression

$expression1.EventType = $Null

$expression1.eventTypeId = "com.vmware.vcDr.VmNotFullyProtectedEvent"

$expression1.objectType = "VirtualMachine"

$expression1.status = "Red"

# Attribute comparison for expression 1

#$comparison1 = New-Object VMware.Vim.EventAlarmExpressionComparison

#$comparison1.AttributeName = "Placeholder VM Created (h-srmpmlab-msn-1)"

#$comparison1.Operator = "notEqualTo"

#$comparison1.Value = "1"

#$expression1.Comparisons += $comparison1
# Event expression 1 - "Virtual machine in group is no longer configured for protection."

# will change state to "Red"

$expression2 = New-Object VMware.Vim.EventAlarmExpression

$expression2.EventType = $Null

$expression2.eventTypeId = "com.vmware.vcDr.VmFullyProtectedEvent"

$expression2.objectType = "VirtualMachine"

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

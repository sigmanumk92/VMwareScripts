<#
.SYNOPSIS
Creates the Alarm For the VR Site Down
.DESCRIPTION
This script Creates the VR Site Down.
.NOTES
Author: Anthony Schulte
#>
Function SRM-VRSiteIssue {
 [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        $alarm,
		[Parameter(Mandatory = $False)]
        $logs
		)


$alarm.Name = "VR Site issue"

$alarm.Description = "VR Site Issue."

$alarm.Enabled = $TRUE


# Event expression 1 - "VR remote Site Down."

# will change state to "Red"

$expression1 = New-Object VMware.Vim.EventAlarmExpression

$expression1.EventType = $Null

$expression1.eventTypeId = "com.vmware.vcHms.remoteSiteDownEvent"

$expression1.objectType = "VirtualCenter"

$expression1.status = "Red"

# Event expression 1 - "VR remote Site Up."

# will change state to "Red"

$expression2 = New-Object VMware.Vim.EventAlarmExpression

$expression2.EventType = $Null

$expression2.eventTypeId = "com.vmware.vcHms.remoteSiteUpEvent"

$expression2.objectType = "VirtualCenter"

$expression2.status = "Green"

# Event expression 1 - "VR local Site Down."

# will change state to "Red"

$expression3 = New-Object VMware.Vim.EventAlarmExpression

$expression3.EventType = $Null

$expression3.eventTypeId = "com.vmware.vcHms.hbrDisconnectedEvent"

$expression3.objectType = "VirtualCenter"

$expression3.status = "Red"

# Event expression 1 - "VR local Site Up."

# will change state to "Red"

$expression4 = New-Object VMware.Vim.EventAlarmExpression

$expression4.EventType = $Null

$expression4.eventTypeId = "com.vmware.vcHms.hbrReconnectedEvent"

$expression4.objectType = "VirtualCenter"

$expression4.status = "Green"

# Add event expressions to alarm

$alarm.expression = New-Object VMware.Vim.OrAlarmExpression

$alarm.expression.expression += $expression1
$alarm.expression.expression += $expression2
$alarm.expression.expression += $expression3
$alarm.expression.expression += $expression4

# Create alarm in vCenter root

$alarmMgr.CreateAlarm("Folder-group-d1",$alarm)

# Add action (send mail) to the newly created alarm

Get-AlarmDefinition $alarm.Name | New-AlarmAction -Snmp

# New-AlarmAction will automatically add the trigger Yellow->Red (!)

 
# Add a second trigger for Yellow->Green

Get-AlarmDefinition $alarm.Name | Get-AlarmAction | New-AlarmActionTrigger -StartStatus "Yellow" -EndStatus "Green"
}

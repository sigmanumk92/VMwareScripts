function Set-AlarmActionState {
<#  
.SYNOPSIS  Enables or disables Alarm actions   
.DESCRIPTION The function will enable or disable
  alarm actions on a vSphere entity itself or recursively
  on the entity and all its children.
.NOTES  Author:  Luc Dekens  
.PARAMETER Entity
  The vSphere entity.
.PARAMETER Enabled
  Switch that indicates if the alarm actions should be
  enabled ($true) or disabled ($false)
.PARAMETER Recurse
  Switch that indicates if the action shall be taken on the
  entity alone or on the entity and all its children.
.EXAMPLE
  PS> Set-AlarmActionState -Entity $cluster -Enabled:$true
#>
 
  param(
    [CmdletBinding()]
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [VMware.VimAutomation.ViCore.Impl.V1.Inventory.InventoryItemImpl]$Entity,
    [switch]$Enabled,
    [switch]$Recurse
  )
 
  begin{
    $alarmMgr = Get-View AlarmManager 
  }
 
  process{
    if($Recurse){
      $objects = @($Entity)
      $objects += Get-Inventory -Location $Entity
    }
    else{
      $objects = $Entity
    }
    $objects | %{
      $alarmMgr.EnableAlarmActions($_.Extensiondata.MoRef,$Enabled)
    }
  }
}
 
function Get-AlarmActionState {
<#  
.SYNOPSIS  Returns the state of Alarm actions.    
.DESCRIPTION The function will return the state of the
  alarm actions on a vSphere entity or on the the entity
  and all its children
.NOTES  Author:  Luc Dekens  
.PARAMETER Entity
  The vSphere entity.
.PARAMETER Recurse
  Switch that indicates if the state shall be reported for
  the entity alone or for the entity and all its children.
.EXAMPLE
  PS> Get-AlarmActionState -Entity $cluster -Recurse:$true
#>
 
  param(
    [CmdletBinding()]
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [VMware.VimAutomation.ViCore.Impl.V1.Inventory.InventoryItemImpl]$Entity,
    [switch]$Recurse = $false
  )
 
  process {
    $Entity = Get-Inventory -Id $Entity.Id
    if($Recurse){
      $objects = @($Entity)
      $objects += Get-Inventory -Location $Entity
    }
    else{
      $objects = $Entity
    }
 
    $objects |
    Select Name,
    @{N="Type";E={$_.GetType().Name.Replace("Impl","").Replace("Wrapper","")}},
    @{N="Alarm actions enabled";E={$_.ExtensionData.alarmActionsEnabled}}
  }
}
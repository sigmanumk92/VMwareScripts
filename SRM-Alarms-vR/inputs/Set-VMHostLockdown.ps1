Function Set-VMHostLockdown 
{
  <#
  .SYNOPSIS
    Enable or Disable VMhost lockdown mode
  .DESCRIPTION
    Enable or Disable VMhost lockdown mode
  .PARAMETER VMHost
    VMHost to modify lockdown mode on.
  .PARAMETER Enable
    Enable VMHost lockdown mode.
  .PARAMETER Disable
    Disable VMHost lockdown mode.
  .EXAMPLE
    Get-VMHost ESX01 | Set-VMHostLockdown -Enable
  .EXAMPLE
    Set-VMHostLockdown -VMHost (Get-VMHost ESX08) -Disable
  #>
  [CmdletBinding(SupportsShouldProcess=$true)]
  param(
    [Parameter(
       Mandatory=$true
    ,  ValueFromPipeline=$true
    ,  HelpMessage="VMHost"
    ,   ParameterSetName='Enable'
    )]
    [Parameter(
       Mandatory=$true
    ,  ValueFromPipeline=$true
    ,  HelpMessage="VMHost"
    ,   ParameterSetName='Disable'
    )]
    [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl]
    $VMHost
  ,
    [Parameter(
      ParameterSetName='Enable'
    )]
    [switch]
    $Enable
  ,
    [Parameter(
      ParameterSetName='Disable'
    )]
    [switch]
    $Disable
  )
  Begin
  {
    $SI = Get-View ServiceInstance -Verbose:$false
    $scheduledTaskManager = `
	  Get-View $SI.Content.ScheduledTaskManager `
        -Verbose:$false
    $OnceTaskScheduler = `
	  New-Object -TypeName VMware.Vim.OnceTaskScheduler
    $OnceTaskScheduler.runat = (get-date).addYears(5)
    $ScheduledTaskSpec = `
	  New-Object -TypeName VMware.Vim.ScheduledTaskSpec
    $ScheduledTaskSpec.Enabled = $true
    $ScheduledTaskSpec.Name = "PowerCLI $(Get-Random)"
    $ScheduledTaskSpec.Scheduler = $OnceTaskScheduler
    $tasks = @()
  }
  Process 
  {
    $VMhosts = $null
    Switch ($PSCmdlet.ParameterSetName)
    {
      "Enable"
      {
        $msg = "Enable lockdown mode on $($VMHost.Name)"
        $ScheduledTaskSpec.Description = $msg
        $ScheduledTaskSpec.Action = New-Object `
          -TypeName VMware.Vim.MethodAction `
          -Property @{name="DisableAdmin"}
        $scheduledTaskSpec.Name = "PowerCLI $(Get-Random)"
        $VMHosts = $VMHost | 
          Where-Object {!$_.ExtensionData.Config.AdminDisabled}
      }
      "Disable"
      {
        $msg = "Disable lockdown mode on $($VMHost.Name)"
        $ScheduledTaskSpec.Description = $msg
        $scheduledTaskSpec.Name = "PowerCLI $(Get-Random)"
        $ScheduledTaskSpec.Action = New-Object `
          -TypeName VMware.Vim.MethodAction `
          -Property @{name="EnableAdmin"}
        $VMHosts = $VMHost | 
          Where-Object {$_.ExtensionData.Config.AdminDisabled}
      }
    }
    IF ($VMhosts)
    {
      Foreach ($VMHost in $VMhosts)
      {
        if ($PSCmdlet.ShouldProcess($VMHost.name,$msg))
        {
         $TaskMoRef=$scheduledTaskManager.CreateScheduledTask( `
            $vmhost.ExtensionData.MoRef, $ScheduledTaskSpec)
          $ScheduledTask = Get-View $TaskMoRef -Verbose:$false
          $ScheduledTask.RunScheduledTask()
          $i = 0
          while ($ScheduledTask.Info.ActiveTask -ne $null -or `
		  $i -ge 100)
          {
            $ScheduledTask.UpdateViewData('Info.ActiveTask')
            $i++
            Start-Sleep -Milliseconds 200
          }
          $tasks += $ScheduledTask
          Write-Output $VMhost
        }
      }
    }
  }
  End 
  {
    Foreach ($task in $tasks)
    {
      $task.RemoveScheduledTask()
    }
  }
}
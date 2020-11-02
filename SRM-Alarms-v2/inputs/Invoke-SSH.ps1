Function Invoke-SSH
{
    <#
    .SYNOPSIS 
    Uses Plink.exe to SSH to a host and execute a list of commands.
    .DESCRIPTION
    Uses Plink.exe to SSH to a host and execute a list of commands.
    .PARAMETER hostname
    The host you wish to connect to.
    .PARAMETER username
    Username to connect with.
    .PARAMETER password
    Password for the specified user account.
    .PARAMETER commandArray
    A single, or list of commands stored in an array object.
    .PARAMETER plinkAndPath
    The location of the plink.exe including the executable (e.g. F:\tools\plink.exe)
    .PARAMETER connectOnceToAcceptHostKey
    If set to true, it will accept the remote host key (use when connecting for the first time)
    .EXAMPLE
    Invoke-SSH -username root -hostname centos-server -password Abzy4321! -plinkAndPath "F:\tools\plink.exe" -commandArray $commands -connectOnceToAcceptHostKey $true
    .EXAMPLE
    Invoke-SSH -username root -hostname centos-server -password Abzy4321! -plinkAndPath "F:\tools\plink.exe" -commandArray ifconfig -connectOnceToAcceptHostKey $true
    .NOTES
    Author: Robin Malik
    Source: Modified from: http://www.zerrouki.com/invoke-ssh/
    #>
     
    Param(
        [Parameter(Mandatory=$true,HelpMessage="Enter a host to connect to.")]
        [string]
        $hostname,
         
        [Parameter(Mandatory=$true,HelpMessage="Enter a username.")]
        [string]
        $username,
         
        [Parameter(Mandatory=$true,HelpMessage="Enter the password.")]
        [string]
        $password,
         
        [Parameter(Mandatory=$true,HelpMessage="Provide a command or comma separated list of commands")]
        [array]
        $commandArray,
         
        [Parameter(Mandatory=$true,HelpMessage="Path to plink (e.g. F:\tools\plink.exe).")]
        [string]
        $plinkAndPath,
         
        [Parameter(HelpMessage="Accept host key if connecting for the first time (the default is `$false)")]
        [string]
        $connectOnceToAcceptHostKey = $false
    )
     
    $target = $username + '@' + $hostname
    $plinkoptions = "-ssh $target -pw $password"
      
    # On first connect to a host, plink will prompt you to accept the remote host key. 
    # This section will login and accept the host key then logout:
    if($ConnectOnceToAcceptHostKey)
    {
        $plinkCommand  = [string]::Format('echo y | & "{0}" {1} exit', $plinkAndPath, $plinkoptions )
        $msg = Invoke-Expression $plinkCommand
    }
     
    # Build the SSH Command by looping through the passed value(s). Append exit in order to logout:
    $commandArray += "exit"
    $commandArray | % { $remoteCommand += [string]::Format('{0}; ', $_) }
     
    # Format the command to pass to plink:
    $plinkCommand = [string]::Format('& "{0}" {1} "{2}"', $plinkAndPath, $plinkoptions , $remoteCommand)
      
    # Execute the command and display the output:
    $msg = Invoke-Expression $plinkCommand
    Write-Output $msg
}
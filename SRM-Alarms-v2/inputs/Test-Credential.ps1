Function Test-Credential #Param [Management.Automation.PSCredential] $userCredential, [String] $domainName ; Returns result as string = "Success" if successful
{Param ([Management.Automation.PSCredential]$userCredential,[String]$domainName)
	$username = $userCredential.username
	$password = $userCredential.GetNetworkCredential().password
	
	# Get current domain using logged-on user's credentials
	$domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$UserName,$Password)
	if ($domain.name -eq $null)
	{
		Return "Fail"
	}
	else
	{
	 	Return "Success"
	}
	$domain = $null
}
#$Cred = Get-Credential
#$domain = "corp.erac.com"
#$Response = Test-Credential $userCred $Targetdomain
#$Response
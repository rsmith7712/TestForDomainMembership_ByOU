<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.2.127
	 Created on:   	8/29/2016 7:19 AM
	 Created by:   	Unknown 
	 Modified by: 	Richard Smith, GSweet
	 Organization: 	
	 Filename:     	git-TestForDomainMembership_ByOU.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

# Import AD Module
Import-Module ActiveDirectory;
Write-Host "AD Module Imported";

# Enable PowerShell Remote Sessions
Enable-PSRemoting -Force;
Write-Host "PSRemoting Enabled";

# Function - Logging file
function Logging($pingerror, $Computer, $Membership)
{
	$outputfile = "\\FILE_SERVER\Shares\UTILITY\log_TestForDomainMembership.txt";
	
	$timestamp = (Get-Date).ToString();
	
	$logstring = "Computer / Domain Status: {0}, {1}" -f $Computer, $Membership;
	
	"$timestamp - $logstring" | out-file $outputfile -Append;
	
	if ($pingerror -eq $false)
	{
		Write-Host "$timestamp - $logstring";
	}
	else
	{
		Write-Host "$timestamp - $logstring" -foregroundcolor red;
	}
	return $null;
}

# Get details of this computer
$computer = Get-WmiObject -Class Win32_ComputerSystem

# Display details
"System Name: {0}" -f $computer.name
"Domain     : {0}" -f $computer.domain

# Sets the Inclusion OU
$OUs = @("OU=Domain Servers")
$SearchBase = "$OUs, DC=DOMAIN, DC=com"

$GetServer = Get-ADComputer -LDAPFilter "(name=*)" -SearchBase $SearchBase
$Servers = $GetServer.name

ForEach ($Server in $Servers)
{
	# Test connection to target server
	Write-Host "Before test connection to target server";
	If (Test-Connection -CN $Server -Quiet)
	{
		Write-Host "After test connection to target server";
		Write-Host;
		
		$Membership = gwmi -Class win32_computersystem | select -ExpandProperty domainrole
		switch ($Membership)
		{
			0 { "Standalone Workstation" }
			1 { "Member Workstation" }
			2 { "Standalone Server" }
			3 { "Member Server" }
			4 { "Backup Domain Controller" }
			5 { "Primary Domain Controller" }
			default { "Domain Membership Unknown" }
		} # end switch
		
		Logging $False $Server $Membership;
	}
}



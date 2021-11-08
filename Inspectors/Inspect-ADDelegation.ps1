<#
.SYNOPSIS
    Gather information about Active Directory High-value target accounts
.DESCRIPTION
    This script checks Active Directory Accounts that are High-value targets and offers remediation steps
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to change admin accounts
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory high-value target accounts
#>

$path = @($out_path)
Function Inspect-Delegation{
    $OUs = Get-ADOrganizationalUnit -Filter {Name -like '*'} 

    If ((Test-Path -Path .\ActiveDirectoryDelegation) -eq $false){
        New-Item -Path . -Name "ActiveDirectoryDelegation" -ItemType "directory"
        }
    
    Foreach ($OU in $OUs){
        dsacls $OU.DistinguishedName | Out-File -FilePath "$path\ActiveDirectoryDelegation\$($OU.Name)_DelegatedRights.txt"
    }

}

Return Inspect-Delegation
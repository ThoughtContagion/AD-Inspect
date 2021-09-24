<#
.SYNOPSIS
    Gather information about Active Directory accounts with long-lived passwords
.DESCRIPTION
    This script checks Active Directory Accounts for long-lived passwords and offers remediation steps
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to change admin accounts
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory accounts with long-lived passwords
#>

Function Inspect-PasswordLongevity{
    $pwdNotchanged = Get-ADUser -filter {(PasswordLastSet -lt (Get-Date).adddays(-120)) -and (PasswordNeverExpires -eq $false)} -Properties PasswordLastSet
    
    if ($pwdNotchanged.count -gt 0 -and $pwdNotchanged.enabled -eq $true){
        Return $pwdNotchanged
    }
}

Return Inspect-PasswordLongevity
<#
.SYNOPSIS
    Gather information about Active Directory accounts with the PasswordNotRequired flag set
.DESCRIPTION
    This script checks Active Directory Accounts for the PasswordNnotRequired attribute and offers remediation steps
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to change admin accounts
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory accounts with PasswordNotRequired flag set
#>

Function Inspect-PasswordNotRequired{
    $pwdNotrequired = Get-ADUser -Filter {UserAccountControl -band 0x0020}
    
    if ($pwdNotrequired.count -ne '0'){
        Return $pwdNotrequired
    }
}

Return Inspect-PasswordNotRequired
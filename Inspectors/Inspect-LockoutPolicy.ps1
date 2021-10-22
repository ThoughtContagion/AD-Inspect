<#
.SYNOPSIS
    Gather information about the Active Directory Domain Account Lockout Policy
.DESCRIPTION
    This script checks Active Directory Active Directory Domain Account Lockout Policy
.COMPONENT
    PowerShell, Active Directory PowerShell Module
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory Active Directory Domain Account Lockout Policy
#>


Function Inspect-LockoutPolicy{
    $domain = Get-ADRootDSE 
    $AccountPolicy = Get-ADObject $domain.defaultNamingContext -Property lockoutDuration, lockoutObservationWindow, lockoutThreshold
    $Info = $AccountPolicy | Select-Object @{n="lockoutDuration";e={"$($_.lockoutDuration / -600000000) minutes"}},@{n="lockoutObservationWindow";e={"$($_.lockoutObservationWindow / -600000000) minutes"}},lockoutThreshold | Format-List

    Return $Info
}

Return Inspect-LockoutPolicy
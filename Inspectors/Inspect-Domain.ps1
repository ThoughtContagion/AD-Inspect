<#
.SYNOPSIS
    Gather information about Active Directory Domain
.DESCRIPTION
    This script checks Active Directory Domain and offers remediation steps
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to change admin accounts
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory Domain
#>


Function Inspect-Domain{
    $Domain = Get-ADDomain
    If (($Domain.DomainMode -notlike "*2016*") -or ($Domain.DomainMode -notlike "*2019*")) {
        Return "$Domain is $($Domain.DomainMode)"
    }
    Return $null
}

Return Inspect-Domain
<#
.SYNOPSIS
    Gather information about Active Directory Forest
.DESCRIPTION
    This script checks Active Directory Forest and offers remediation steps
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to change admin accounts
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory Forest
#>


Function Inspect-Forest{
    $Forest = Get-ADForest
    If (($Forest.ForestMode -notlike "*2016*") -or ($Forest.ForestMode -notlike "*2019*")) {
        Return $Forest
    }
}

Return Inspect-Forest
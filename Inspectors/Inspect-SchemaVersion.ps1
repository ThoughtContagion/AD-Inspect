<#
.SYNOPSIS
    Gather information about Active Directory Schema
.DESCRIPTION
    This script checks Active Directory Schema and offers remediation steps
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to change admin accounts
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory Schema
#>


Function Inspect-SchemaVersion{
    $Schema = Get-ADObject (Get-ADRootDSE).schemaNamingContext -Property objectVersion
    If ($Schema.objectVersion -le "69") {
        Return $Schema
    }
}

Return Inspect-SchemaVersion
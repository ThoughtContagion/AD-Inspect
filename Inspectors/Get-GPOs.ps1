<#
.SYNOPSIS
    Gather information about Active Directory Group Policy Objects
.DESCRIPTION
    This script checks Active Directory Group policy Objects for review
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to change admin accounts
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory Group Policy Objects
#>


Function Get-GPOs{
    $GPOs = Get-GPO -all
    Return $GPOs
}

Return Get-GPOs
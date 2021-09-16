<#
.SYNOPSIS
    Gather information about Active Directory Group Policy Objects
.DESCRIPTION
    This script analyzes Active Directory Group Policy Objects and outputs an HTML report for review
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to read Group Policy
.ROLE
    Domain Admin or Delegated rights
.FUNCTIONALITY
    Gather information about Active Directory Group Policy Objects
#>

Function Get-DomainGPOs{
    #Get Domain
    $domain = Get-ADDomain -Properties *

    #Get the GPO information and generate reports
    Get-GPOReport -All -Domain $domain.DNSRoot -Server $domain.PDCEmulator -ReportType HTML -Path ".\$($domain.DNSRoot)_GPOReportsAll.html"
}

Return Get-DomainGPOs
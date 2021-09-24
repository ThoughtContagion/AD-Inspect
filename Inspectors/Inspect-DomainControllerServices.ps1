<#
.SYNOPSIS
    Gather information about services running on Active Directory Domain Controllers
.DESCRIPTION
    This script checks services running on Active Directory Domain Controllers
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to connect to Domain Controllers
.ROLE
    Domain Admin
.FUNCTIONALITY
    Gather information about services running on Active Directory Domain Controllers
#>

Function Get-Services{
    $DCs = Get-ADDomainController
    
    Foreach ($DC in $DCs) {
        $services = Get-Service -ComputerName $DC.Hostname
        Return $services
    }
}

Return Get-Services
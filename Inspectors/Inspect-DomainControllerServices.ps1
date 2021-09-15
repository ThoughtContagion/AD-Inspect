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
    
    if ($DCs.count -ne '0'){
        Foreach ($DC in $DCs) {
            $services = Invoke-Command -ComputerName $DC.name {Get-Services}
            Return $services
        }
    }
}

Return Get-Services
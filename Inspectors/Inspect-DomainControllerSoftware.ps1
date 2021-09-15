<#
.SYNOPSIS
    Gather information about software installed on Active Directory Domain Controllers
.DESCRIPTION
    This script checks software installed on Active Directory Domain Controllers
.COMPONENT
    PowerShell, Active Directory PowerShell Module, and sufficient rights to connect to Domain Controllers
.ROLE
    Domain Admin
.FUNCTIONALITY
    Gather information about software installed on Active Directory Domain Controllers
#>

Function Get-DCSoftware{
    $DCs = Get-ADDomainController
    
    if ($DCs.count -ne '0'){
        Foreach ($DC in $DCs) {
            $software = Invoke-Command -ComputerName $DC.name {Get-WmiObject -Class Win32_Product}
            Return $software
        }
    }
}

Return Get-DCSoftware
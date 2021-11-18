$path = @($out_path)
Function Inspect-Delegation{
    $OUs = Get-ADOrganizationalUnit -Filter {Name -like '*'} 

    If ((Test-Path -Path $path\ActiveDirectoryDelegation) -eq $false){
        New-Item -Path $path -Name "ActiveDirectoryDelegation" -ItemType "directory"
        }

    $path = "$($path)\ActiveDirectoryDelegation"
    
    Foreach ($OU in $OUs){
        dsacls $OU.DistinguishedName | Out-File -FilePath "$path\$($OU.Name)_DelegatedRights.txt"
    }

}

Return Inspect-Delegation
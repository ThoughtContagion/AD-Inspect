$path = @($out_path)

Function Get-DangerousDelegation {
    $DangerousDelegation = Import-CSV -Path (Get-ChildItem -Path $path -Filter "*_ACLs.csv").FullName | Where-Object {($_.accesscontroltype -like "GenericAll") -or ($_.accesscontroltype -like "*Write*")} 
    If ($DangerousDelegation.Count -ne 0){
        $DangerousDelegation | Export-CSV "$($path)\DangerousDegelationPermissions.csv" -NoTypeInformation
    }
    Return $null
}

Return Get-DangerousDelegation
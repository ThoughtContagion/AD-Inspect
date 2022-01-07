$path = @($out_path)
Function Inspect-UnconstrainedDelegation{
    $Computers = Get-ADComputer -Filter {(TrustedForDelegation -eq $True) -AND (PrimaryGroupID -ne '516') -AND (PrimaryGroupID -ne '521')}
    if ($Computers.count -gt 0){
        Return $Computers.count
        Export-Csv "$path\UnconstrainedDelegation.csv" -NoTypeInformation
    }
}

Return Inspect-UnconstrainedDelegation
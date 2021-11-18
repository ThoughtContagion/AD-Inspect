<#
    $url = "https://adsecurity.org/?p=3164#:~:text=Since%20the%20LAPS%20computer%20attribute,aren't%20actively%20LAPS%20managed."
    This is a placeholder file
#>

function Get-LAPSReaders{
    $OUs = Get-ADOrganizationalUnit -Filter *

    $objects = @()

    $users = @()

    Foreach ($ou in $OUs){
        try {
            $objects += Find-AdmPwdExtendedRights -Identity $ou.distinguishedname | Select-Object -ExpandProperty ExtendedRightHolders -Unique
        }
        catch {
            return $null
        }

    }

    foreach ($object in $objects){
        if ($object -notlike "NT Authority\*"){
            $obj = $object.IndexOf("\")
            $name = $object.substring($obj+1)
            $users += Get-ADObject -filter {($_.objectClass -eq "user") -and ($_.name -like $name)} 
        }
    }

    If ($users.count -gt 0){
        return $users
    }

    return $null
}

Return Get-LAPSReaders
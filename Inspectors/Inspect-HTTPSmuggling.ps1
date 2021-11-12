Function Inspect-HTTPSmuggling{
    #Get Domain
    $domain = Get-ADDomain

    #Get the GPO information and generate reports
    $GPOs = Get-GPO -All -Domain $domain.DNSRoot -Server $domain.PDCEmulator

    $mitigatingPolicies = @()

    #Options to check for
    $replace = 'Properties action="R" fileExtension="js" applicationPath="C:\Windows\System32\Notepad.exe" default="1"'
    $update = 'Properties action="U" fileExtension="js" applicationPath="C:\Windows\System32\Notepad.exe" default="1"'

    Foreach ($gpo in $GPOs){
        $result = Get-GPOReport -Guid $gpo.Id -ReportType XML

        if (($result -match $replace) -or ($report -match $update)) {
            $mitigatingPolicies += $gpo.DisplayName
            }
        }

    If (!$mitigatingPolicies){
        Return @($org_name)
        }
}

Return Inspect-HTTPSmuggling
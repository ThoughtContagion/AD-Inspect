<#
  .SYNOPSIS
  Performs Microsoft Active Directory security assessment.

  .DESCRIPTION
  Automate the security assessment of Microsoft Active Directory environments.

  .PARAMETER Username
  Username of Admin/Auditor account.

  .OUTPUTS
  None. ADInspect.ps1 does not generate any output.

  .EXAMPLE
  PS> .\ADInspect.ps1 -OutPath "C:\Reports"

  .EXAMPLE
  PS> .\ADInspect.ps1 -Username admin -OutPath "C:\Reports"
#>


param (
	[Parameter(Mandatory = $false,
		HelpMessage = 'Admin or Auditor Username')]
	[string] $Username,
	[Parameter(Mandatory = $true,
		HelpMessage = 'Output path for report')]
	[string] $OutPath
)


Function Connect-Services{
    # Log into every service prior to the analysis.
    If ($Username -EQ "*") {
        Get-Credential -Credential $Username
    }
}

#Start Script
Connect-Services


#Define Organization Attributes
$out_path = $OutPath
$org_name = Get-ADDomain | Select-Object DNSRoot
$org_name = $org_name.DNSRoot


# Get a list of every available detection module by parsing the PowerShell
# scripts present in the .\inspectors folder. 
$inspectors = (Get-ChildItem .\inspectors\ | Where-Object -FilterScript { $_.Name -Match ".ps1" }).Name | ForEach-Object { ($_ -split ".ps1")[0] }

$selected_inspectors = $inspectors

New-Item -ItemType Directory -Force -Path $out_path | Out-Null

# Maintain a list of all findings, beginning with an empty list.
$findings = @()

# For every inspector the user wanted to run...
ForEach ($selected_inspector in $selected_inspectors) {
	# ...if the user selected a valid inspector...
	If ($inspectors.Contains($selected_inspector)) {
		Write-Output "Invoking Inspector: $selected_inspector"
		
		# Get the static data (finding description, remediation etc.) associated with that inspector module.
		$finding = Get-Content .\inspectors\$selected_inspector.json | Out-String | ConvertFrom-Json
		
		# Invoke the actual inspector module and store the resulting list of insecure objects.
		$finding.AffectedObjects = Invoke-Expression ".\inspectors\$selected_inspector.ps1"
		
		# Add the finding to the list of all findings.
		$findings += $finding
	}
}

# Function that retrieves templating information from 
function Parse-Template {
	$template = (Get-Content ".\ADInspectDefaultTemplate.html") -join "`n"
	$template -match '\<!--BEGIN_FINDING_LONG_REPEATER-->([\s\S]*)\<!--END_FINDING_LONG_REPEATER-->'
	$findings_long_template = $matches[1]
	
	$template -match '\<!--BEGIN_FINDING_SHORT_REPEATER-->([\s\S]*)\<!--END_FINDING_SHORT_REPEATER-->'
	$findings_short_template = $matches[1]
	
	$template -match '\<!--BEGIN_AFFECTED_OBJECTS_REPEATER-->([\s\S]*)\<!--END_AFFECTED_OBJECTS_REPEATER-->'
	$affected_objects_template = $matches[1]
	
	$template -match '\<!--BEGIN_REFERENCES_REPEATER-->([\s\S]*)\<!--END_REFERENCES_REPEATER-->'
	$references_template = $matches[1]
	
	$template -match '\<!--BEGIN_EXECSUM_TEMPLATE-->([\s\S]*)\<!--END_EXECSUM_TEMPLATE-->'
	$execsum_template = $matches[1]
	
	return @{
		FindingShortTemplate    = $findings_short_template;
		FindingLongTemplate     = $findings_long_template;
		AffectedObjectsTemplate = $affected_objects_template;
		ReportTemplate          = $template;
		ReferencesTemplate      = $references_template;
		ExecsumTemplate         = $execsum_template
	}
}

$templates = Parse-Template

# Maintain a running list of each finding, represented as HTML
$short_findings_html = '' 
$long_findings_html = ''

$findings_count = 0

ForEach ($finding in $findings) {
	# If the result from the inspector was not $null,
	# it identified a real finding that we must process.
	If ($null -NE $finding.AffectedObjects) {
		# Increment total count of findings
		$findings_count += 1
		
		# Keep an HTML variable representing the current finding as HTML
		$short_finding_html = $templates.FindingShortTemplate
		$long_finding_html = $templates.FindingLongTemplate
		
		# Insert finding name and number into template HTML
		$short_finding_html = $short_finding_html.Replace("{{FINDING_NAME}}", $finding.FindingName)
		$short_finding_html = $short_finding_html.Replace("{{FINDING_NUMBER}}", $findings_count.ToString())
		$long_finding_html = $long_finding_html.Replace("{{FINDING_NAME}}", $finding.FindingName)
		$long_finding_html = $long_finding_html.Replace("{{FINDING_NUMBER}}", $findings_count.ToString())
		
		# Finding description
		$long_finding_html = $long_finding_html.Replace("{{DESCRIPTION}}", $finding.Description)
		
		# Finding Remediation
		If ($finding.Remediation.length -GT 300) {
			$short_finding_text = "Complete remediation advice is provided in the body of the report. Clicking the link to the left will take you there."
		}
		Else {
			$short_finding_text = $finding.Remediation
		}
		
		$short_finding_html = $short_finding_html.Replace("{{REMEDIATION}}", $short_finding_text)
		$long_finding_html = $long_finding_html.Replace("{{REMEDIATION}}", $finding.Remediation)
		
		# Affected Objects
		If ($finding.AffectedObjects.Count -GT 15) {
			$condensed = "<a href='{name}'>{count} Affected Objects Identified<a/>."
			$condensed = $condensed.Replace("{count}", $finding.AffectedObjects.Count.ToString())
			$condensed = $condensed.Replace("{name}", $finding.FindingName)
			$affected_object_html = $templates.AffectedObjectsTemplate.Replace("{{AFFECTED_OBJECT}}", $condensed)
			$fname = $finding.FindingName
			$finding.AffectedObjects | Out-File -FilePath $out_path\$fname
		}
		Else {
			$affected_object_html = ''
			ForEach ($affected_object in $finding.AffectedObjects) {
				$affected_object_html += $templates.AffectedObjectsTemplate.Replace("{{AFFECTED_OBJECT}}", $affected_object)
			}
		}
		
		$long_finding_html = $long_finding_html.Replace($templates.AffectedObjectsTemplate, $affected_object_html)
		
		# References
		$reference_html = ''
		ForEach ($reference in $finding.References) {
			$this_reference = $templates.ReferencesTemplate.Replace("{{REFERENCE_URL}}", $reference.Url)
			$this_reference = $this_reference.Replace("{{REFERENCE_TEXT}}", $reference.Text)
			$reference_html += $this_reference
		}
		
		$long_finding_html = $long_finding_html.Replace($templates.ReferencesTemplate, $reference_html)
		
		# Add the completed short and long findings to the running list of findings (in HTML)
		$short_findings_html += $short_finding_html
		$long_findings_html += $long_finding_html
	}
}

# Insert command line execution information. This is coupled kinda badly, as is the Affected Objects html.
$flags = "<b>Prepared for organization:</b><br/>" + $org_name + "<br/><br/>"
$flags = $flags + "<b>Stats</b>:<br/> <b>" + $findings_count + "</b> out of <b>" + $inspectors.Count + "</b> executed inspector modules identified possible opportunities for improvement.<br/><br/>"  
$flags = $flags + "<b>Inspector Modules Executed</b>:<br/>" + [String]::Join("<br/>", $selected_inspectors)

$output = $templates.ReportTemplate.Replace($templates.FindingShortTemplate, $short_findings_html)
$output = $output.Replace($templates.FindingLongTemplate, $long_findings_html)
$output = $output.Replace($templates.ExecsumTemplate, $templates.ExecsumTemplate.Replace("{{CMDLINEFLAGS}}", $flags))

$output | Out-File -FilePath $out_path\$($org_name)_Report_$(Get-Date -Format "yyyy-MM-dd_hh-mm-ss").html

return
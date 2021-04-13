# See https://www.elastic.co/guide/en/beats/auditbeat/current/auditbeat-reference-yml.html for reference
# Last updated 2021-04-13 by Tim Fournet 

param (
    [Parameter(Mandatory = $false)][Int][ValidateRange(0,100)]$MaxFileSizeMB = 10,
    [Parameter(Mandatory = $false)][Int][ValidateRange(0,100)]$ScanMBPerSecond = 20
)


Install-Module -Name AZSBTools -Force
Install-Module -Name Powershell-Yaml -Force
Import-Module AZSBTools 


$beatsSvc = "perch-auditbeat"
$beatsFile = "C:\Program Files\Perch\configs\auditbeat.yml"
$beatsYaml = Get-Content -Path $beatsFile | ConvertFrom-Yaml

# Find the index of the FIMS module in Auditbeat
$moduleCount = ($beatsYaml.'auditbeat.modules'.count)
$i=0
Do {
    if ($beatsYaml.'auditbeat.modules'[$i].module -eq "file_integrity") { $index=$i }
    $i++
} While ($i -le $moduleCount)


$beatsYaml.'auditbeat.modules'[$index].Add("max_file_size",$MaxFileSizeMB)
$beatsYaml.'auditbeat.modules'[$index].Add("scan_rate_per_sec",$ScanMBPerSecond)

# Rewrite the file and restart
Stop-Service $beatsSvc
$beatsYaml | ConvertTo-Yaml | Out-File -FilePath $beatsFile
Start-Service $beatsSvc

 

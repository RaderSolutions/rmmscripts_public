# See https://www.elastic.co/guide/en/beats/auditbeat/current/auditbeat-reference-yml.html for reference
# Last updated 2021-04-13 by Tim Fournet 

param (
    [Parameter(Mandatory = $false)][Int][ValidateRange(0,100)]$MaxFileSizeMB = 10,
    [Parameter(Mandatory = $false)][Int][ValidateRange(0,100)]$ScanMBPerSecond = 20,
    [Parameter(Mandatory = $false)][bool]$ShowIndex = $False 
)

Install-PackageProvider -Name NuGet -Force
Install-Module -Name Powershell-Yaml -Force

$index=-1

$beatsSvc = "perch-auditbeat"
$beatsFile = "C:\Program Files\Perch\configs\auditbeat.yml"
$beatsYaml = Get-Content -Path $beatsFile | ConvertFrom-Yaml

# Find the index of the FIMS module in Auditbeat
$moduleCount = ($beatsYaml.'auditbeat.modules'.count)
$i=0
Do {
    If ($beatsYaml.'auditbeat.modules'[$i].module -eq "file_integrity") { $index=$i }
    $i++
} While ($i -le $moduleCount)

If ($ShowIndex -eq $true) {
"FIMS Index is $index"
}

$file_write = 0 

If ($beatsYaml.'auditbeat.modules'[$index].scan_rate_per_sec -ne $ScanMBPerSecond) {
    $beatsYaml.'auditbeat.modules'[$index].Remove("scan_rate_per_sec")
    $beatsYaml.'auditbeat.modules'[$index].Add("scan_rate_per_sec",$ScanMBPerSecond)
    $file_write = 1
}

if ($beatsYaml.'auditbeat.modules'[$index].max_file_size -ne $ScanMBPerSecond) {
    $beatsYaml.'auditbeat.modules'[$index].Remove("max_file_size")
    $beatsYaml.'auditbeat.modules'[$index].Add("max_file_size",$MaxFileSizeMB)
    $file_write = 1
}


# Rewrite the file and restart
if ($file_write -eq 1) {
    Stop-Service $beatsSvc
    $beatsYaml | ConvertTo-Yaml | Out-File -FilePath $beatsFile
    Start-Service $beatsSvc
}



 

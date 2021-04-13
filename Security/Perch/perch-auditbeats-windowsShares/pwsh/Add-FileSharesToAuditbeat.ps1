Install-Module -Name AZSBTools -Force
Install-Module -Name Powershell-Yaml -Force
Import-Module AZSBTools 

$beatsSvc = "perch-auditbeat"
$beatsFile = "C:\Program Files\Perch\configs\auditbeat.yml"
$beatsYaml = Get-Content -Path $beatsFile | ConvertFrom-Yaml

# Get SMB File Shares and format into the format auditbeats.yml likes
$winShares = (Get-SmbShare | Where-Object Special -eq $false |Select-Object -Unique Path).Path
$winShares = $winShares -replace "\\", "/"

# Find the index of the FIMS module in Auditbeat
$moduleCount = ($beatsYaml.'auditbeat.modules'.count)
$i=0
Do {
    if ($beatsYaml.'auditbeat.modules'[$i].module -eq "file_integrity") { $index=$i }
    $i++
} While ($i -le $moduleCount)

$file_write = 0 
# Adds each file share to the list
$winShares | ForEach-Object {
    if ($beatsYaml.'auditbeat.modules'[$index].paths -notcontains $_) {
        $beatsYaml.'auditbeat.modules'[$index].paths.Add($_)
        $file_write = 1
    }
}
$beatsYaml.'auditbeat.modules'[$index].Add("recursive",$true)

# Rewrite the file and restart
if ($file_write -eq 1) {
    Stop-Service $beatsSvc
    $beatsYaml | ConvertTo-Yaml | Out-File -FilePath $beatsFile
    Start-Service $beatsSvc
}
Install-Module -Name AZSBTools
Install-Module -Name Powershell-Yaml
Import-Module AZSBTools 

$beatsSvc = "perch-auditbeat"
$beatsFile = "C:\Program Files\Perch\configs\auditbeat.yml"
$beatsYaml = Get-Content -Path $beatsFile | ConvertFrom-Yaml

#$winShares = (Get-FileShareInfo | Select-Object -Unique Path).Path
$winShares = (Get-SmbShare | Where-Object Special -eq $false |Select-Object -Unique Path).Path
$winShares = $winShares -replace "\\", "/"

$moduleCount = ($beatsYaml.'auditbeat.modules'.count)
$i=0
Do {
    if ($beatsYaml.'auditbeat.modules'[$i].module -eq "file_integrity") { $index=$i }
    $i++
} While ($i -le $moduleCount)

$winShares | ForEach-Object {
    if ($beatsYaml.'auditbeat.modules'[$index].paths -notcontains $_) {
        $beatsYaml.'auditbeat.modules'[$index].paths.Add($_)
    }
}

$beatsYaml.'auditbeat.modules'[$index].Add("recursive",$true)

Stop-Service $beatsSvc
$beatsYaml | ConvertTo-Yaml | Out-File -FilePath $beatsFile
Start-Service $beatsSvc

 

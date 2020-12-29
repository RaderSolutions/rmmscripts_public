$key=$args[0]

downloadUrl="https://toolset.malwarebytes.com/file/mbts/$key"

tempDir="C:\Windows\Temp"
dlPath="$tempDir\mbts.zip"

(New-Object System.Net.WebClient).DownloadFile($downloadUrl, $dlPath)  

Expand-Archive -Path $destPth -DestinationPath $tempDir

Start-Process -FilePath $tempDir\MBTSLauncher.exe

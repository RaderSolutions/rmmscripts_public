
powershell -c "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/RaderSolutions/rmmscripts_public/master/mbam.ps1' -OutFile '%TEMP%\mbam.ps1'"
powershell -c "Start-Process $env:TEMP\mbam.ps1 -ArgumentList CB9YM-XY6ZB-X43YF-X2UVX"

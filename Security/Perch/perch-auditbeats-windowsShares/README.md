# Perch-WinFIMS

This app adds file shares to the Perch auditbeat.yml 

The heavy lifting is done by a PowerShell script. This script enumerates the any SMB shares that have been created on a machine, and then adds them to the Perch auditbeat.yml file with ConvertFrom-Yaml and ConvertTo-Yaml. 

My goal is to try to make this as compatible as possible with older versions of Windows Server, hence the out-of-band installs of PowerShell into a non-standard directory. 

The golang wrapper is just to be able to send a single executable over in an effort to simplify RMM-style scripting down to basically one-liners. 

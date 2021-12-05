Set-ExecutionPolicy RemoteSigned -Force
Install-PackageProvider chocolateyget -Force -Verbose
Install-Package pwsh -ProviderName chocolateyget -Force -Verbose

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

pwsh {Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ethanbergstrom/winget/master/Install-WinGet.ps1'))}

Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory 'Private'
Set-WSManQuickConfig

.\DevTools.ps1

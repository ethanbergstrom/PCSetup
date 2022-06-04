#region Local Configuration Manager
[DSCLocalConfigurationManager()]
configuration LCMConfig
{
	Node localhost
	{
		Settings
		{
			ConfigurationMode = 'ApplyAndAutoCorrect'
			# Check for updates once a day
			ConfigurationModeFrequencyMins = 1440
			RefreshFrequencyMins = 1440
		}
	}
}

LCMConfig

Set-DscLocalConfigurationManager .\LCMConfig\ -Verbose
Remove-Item .\LCMConfig\ -Force -Recurse
#endregion

#region Package Management
$cred = Get-Credential

$data = @{
	AllNodes =
	@(
		@{
			NodeName = 'localhost'
			Packages = @(
				'Balena.Etcher',
				'CPUID.HWMonitor',
				'dbeaver.dbeaver',
				'Docker.DockerDesktop',
				'Git.Git',
				'Hashicorp.Vagrant',
				'Inkscape.Inkscape',
				'Microsoft.PowerShell',
				'Microsoft.WindowsTerminal',
				'Mozilla.Firefox',
				'Notepad++.Notepad++',
				'Telerik.Fiddler.Classic',
				'WinSCP.WinSCP'
			)
			# This is not secure! Encrypt DSC MOFs with certificates for secure usage.
			PSDscAllowDomainUser = $true
			PsDscAllowPlainTextPassword = $true
			Credential = $cred
		}
	)
}

Configuration DevTools {
	Import-DscResource -Name PackageManagement,PackageManagementSource

	Node $AllNodes.NodeName {
		PackageManagement WinGet {
			Name = 'WinGet'
			Source = 'PSGallery'
		}
		foreach ($package in $Node.Packages) {
			PackageManagement $package {
				Name = $package
				ProviderName = 'WinGet'
				RequiredVersion = 'latest'
				DependsOn = @('[PackageManagement]WinGet')
				# Required for the LCM to interact with your WinGet execution alias / source data
				PsDscRunAsCredential = $Node.Credential
			}
		}
	}
}

DevTools -ConfigurationData $data

Start-DscConfiguration .\DevTools -Force -Wait -Verbose
Remove-Item .\DevTools\ -Recurse -Force
#endregion
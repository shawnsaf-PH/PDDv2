. "$PSScriptRoot\..\src\Configuration\PlatformConfigurationService.ps1"
. "$PSScriptRoot\..\src\Models\PlatformConfiguration.ps1"

$config = Get-PlatformConfiguration

Write-Host ""
Write-Host "InstallerACC:" $config.InstallerACC

Write-Host ""
Write-Host "JoinACC:" $config.JoinACC

Write-Host ""
Write-Host "InstallMachinePART:" $config.InstallMachinePART

Write-Host ""
Write-Host "InstallUserPART:" $config.InstallUserPART

Write-Host ""
Write-Host "VerifySelections:" $config.VerifySelections
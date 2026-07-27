. "$PSScriptRoot\..\src\Configuration\PlatformConfigurationService.ps1"
. "$PSScriptRoot\..\src\Manifests\ManifestReader.ps1"
. "$PSScriptRoot\..\src\Deployment\ManifestExecutor.ps1"

$config =
    Get-PlatformConfiguration

$manifest =
    Read-DeploymentManifest `
        -Path "\\USDBTLBCA1MSH20\pdd$\Config\PF6BVBW1.ini"

$manifest.Steps =
    @(
        $manifest.Steps |
        Select-Object -First 3
    )
    
$results =
    Invoke-DeploymentManifest `
        -Manifest $manifest `
        -Configuration $config

Write-Host ""
Write-Host "Execution Results"
Write-Host "================="

$results |
    Format-Table `
        ApplicationName,
        Success,
        ExitCode,
        DurationSeconds
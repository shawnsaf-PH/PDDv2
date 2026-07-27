. "$PSScriptRoot\..\src\Configuration\PlatformConfigurationService.ps1"
. "$PSScriptRoot\..\src\Manifests\ManifestReader.ps1"
. "$PSScriptRoot\..\src\Deployment\DeploymentResolver.ps1"
. "$PSScriptRoot\..\src\Deployment\DeploymentExecutor.ps1"

$config =
    Get-PlatformConfiguration

$manifest =
    Read-DeploymentManifest `
        -Path "\\USDBTLBCA1MSH20\pdd$\Config\SD016P49.ini"

$step =
    $manifest.Steps[0]

$resolved =
    Resolve-DeploymentStep `
        -Step $step `
        -Configuration $config

$resolved | Format-List

Write-Host ""
Write-Host "READY FOR EXECUTION TEST"
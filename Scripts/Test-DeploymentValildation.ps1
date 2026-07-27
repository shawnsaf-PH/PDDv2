. "$PSScriptRoot\..\src\Configuration\PlatformConfigurationService.ps1"
. "$PSScriptRoot\..\src\Manifests\ManifestReader.ps1"
. "$PSScriptRoot\..\src\Deployment\DeploymentValidation.ps1"

$config =
    Get-PlatformConfiguration

$manifest =
    Read-DeploymentManifest `
        -Path "\\USDBTLBCA1MSH20\pdd$\Config\SD016P49-DT.ini"

$results =
    Test-DeploymentManifest `
        -Manifest $manifest `
        -Configuration $config

$results |
    Format-Table `
        ApplicationName,
        Valid,
        Message
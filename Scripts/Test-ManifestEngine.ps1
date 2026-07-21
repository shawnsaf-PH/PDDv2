. "$PSScriptRoot\..\src\Catalogs\CatalogService.ps1"
. "$PSScriptRoot\..\src\Manifests\ManifestService.ps1"
. "$PSScriptRoot\..\src\Configuration\PlatformConfigurationService.ps1"

$config = Get-PlatformConfiguration

$apps = Get-AllCatalogApplications `
    -CatalogDirectory $config.IniFilesDirectory `
    -Catalogs $config.Catalogs

$selectedApps =
    <#$apps |
    Select-Object -First 20#>
    Get-SelectedApplications

$manifest =
    New-DeploymentManifest `
        -Applications $selectedApps

Write-Host ""
Write-Host "Manifest Steps:"
Write-Host $manifest.Steps.Count
Write-Host ""

$manifest.Steps |
    Format-Table `
        StepNumber,
        Name,
        Reboot

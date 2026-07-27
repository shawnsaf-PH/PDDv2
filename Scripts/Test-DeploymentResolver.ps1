#----------- Imports -----------

. "$PSScriptRoot\..\src\Configuration\PlatformConfigurationService.ps1"
. "$PSScriptRoot\..\src\Manifests\ManifestReader.ps1"
. "$PSScriptRoot\..\src\Deployment\DeploymentResolver.ps1"

#----------- Configuration -----------

$config =
    [Object]::new()

$config =
    Get-PlatformConfiguration

Write-Host ""
Write-Host "Toolboxes Loaded:" $config.Toolboxes.Count

$config.Toolboxes.GetEnumerator() |
    Format-Table Name, Value

#----------- Manifest -----------

$manifestPath =
    "\\USDBTLBCA1MSH20\pdd$\Config\SD016P49-DT.ini"

$manifest =
    Read-DeploymentManifest `
        -Path $manifestPath

Write-Host ""
Write-Host "Manifest:" $manifestPath
Write-Host "Steps:" $manifest.Steps.Count
Write-Host ""

#----------- Resolution -----------

foreach ($step in $manifest.Steps) {

    $resolved =
        Resolve-DeploymentStep `
            -Step $step `
            -Configuration $config

    Write-Host "----------------------------------------"
    Write-Host "Application:" $step.Name
    Write-Host "Directory :" $step.Directory
    Write-Host ""
    Write-Host "Application Path:"
    Write-Host $resolved.ApplicationPath
    Write-Host ""
    Write-Host "Application Path Exists:" $resolved.ApplicationPathExists
    Write-Host "Machine EXE Exists     :" $resolved.MachineExeExists
    Write-Host "User EXE Exists        :" $resolved.UserExeExists
    Write-Host ""
}
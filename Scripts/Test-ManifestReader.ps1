. "$PSScriptRoot\..\src\Manifests\ManifestReader.ps1"

$manifest =
    Read-DeploymentManifest `
        -Path "\\USDBTLBCA1MSH20\pdd$\Config\SD016P49.ini"

Write-Host ""
Write-Host "Manifest Steps:"
Write-Host ""

$manifest.Steps |
    Format-Table `
        StepNumber,
        Name,
        Directory,
        MachineExe,
        UserExe,
        Reboot
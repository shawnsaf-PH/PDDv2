. "$PSScriptRoot\..\src\Configuration\PlatformConfigurationService.ps1"
. "$PSScriptRoot\..\src\Catalogs\CatalogService.ps1"

$config = Get-PlatformConfiguration

$apps = Get-AllCatalogApplications -CatalogDirectory "\\USDBTLBCA1MS1IT\pdd$\Inifiles" -Catalogs $config.Catalogs
$deployableApps = Get-DeployableApplications -Applications $apps

Write-Host ""
Write-Host "=============================="
Write-Host "PDD v2 Console Viewer"
Write-Host "=============================="

Write-Host ""
Write-Host ""
Write-Host "Raw Catalog Entries:"
Write-Host $apps.Count

Write-Host ""
Write-Host "Deployable Applications:"
Write-Host $deployableApps.Count

$apps |
    Group-Object Department |
    Sort-Object Count -Descending |
    Select-Object Name, Count |
    Format-Table -AutoSize

$duplicates = $apps |
    Group-Object Name |
    Where-Object Count -gt 1

Write-Host ""
Write-Host "Duplicate Applications:"
Write-Host $duplicates.Count

if ($duplicates.Count -gt 0) {
    $duplicates |
        Select-Object Name, Count |
        Format-Table -AutoSize
}

$apps |
    Where-Object {
        [string]::IsNullOrWhiteSpace($_.Department)
    } |
    Select-Object Name, Directory

$apps |
    Where-Object Department -eq "_Placeholder" |
    Select-Object Name, Directory, MachineExe

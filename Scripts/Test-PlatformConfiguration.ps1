. "$PSScriptRoot\..\src\Configuration\PlatformConfigurationService.ps1"

$config = Get-PlatformConfiguration

Write-Host ""
Write-Host "PDD Directory:"
Write-Host $config.PddDirectory

Write-Host ""
Write-Host "Config Directory:"
Write-Host $config.ConfigDirectory

Write-Host ""
Write-Host "Toolboxes:"
$config.Toolboxes.GetEnumerator() |
    Sort-Object Name |
    Format-Table -AutoSize

Write-Host ""
Write-Host "Catalogs:"
$config.Catalogs

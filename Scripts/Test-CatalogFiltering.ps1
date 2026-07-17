. "$PSScriptRoot\..\src\Catalogs\CatalogService.ps1"

$apps = Get-CatalogApplications `
    -Path "\\USDBTLBCA1MS1IT\pdd$\Inifiles\Win11.ini"

Write-Host ""
Write-Host "OPTION Applications"
Write-Host "==================="

Get-ApplicationsByDepartment `
    -Applications $apps `
    -Department "OPTION" |
    Format-Table Name, Department

Write-Host ""
Write-Host "Optional Applications"
Write-Host "====================="

Get-OptionalApplications `
    -Applications $apps |
    Format-Table Name, Optional

Write-Host ""
Write-Host "Search Results: Chrome"
Write-Host "======================"

Find-Application `
    -Applications $apps `
    -SearchText "Chrome" |
    Format-Table Name
. "$PSScriptRoot\..\src\Catalogs\CatalogService.ps1"

$apps = Get-CatalogApplications -Path "\\USDBTLBCA1MS1IT\pdd$\Inifiles\Win11.ini"

Write-Host ""
Write-Host "Applications Found:"
Write-Host ""

$apps |
    Select-Object `
        Name,
        Department,
        Optional |
    Format-Table -AutoSize

Write-Host ""
Write-Host "Total Applications:"
Write-Host $apps.Count
. "$PSScriptRoot\MainWindow.ps1"
<#Get-ChildItem `
    "\\USDBTLBCA1MSH20\PDD$\Toolbox\Global_Site_Toolbox" `
    -Recurse `
    -Directory |
    Where-Object {
        $_.FullName -like "*AdobeAcrobat*"
    } |
    Select-Object FullName#>
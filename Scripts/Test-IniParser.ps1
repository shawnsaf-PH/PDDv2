. "$PSScriptRoot\..\src\Configuration\IniParser.ps1"

$configData = Read-IniFile -Path "\\USDBTLBCA1MS1IT\pdd$\PDD\Config.ini"

$configData.GetEnumerator() | Sort-Object Name

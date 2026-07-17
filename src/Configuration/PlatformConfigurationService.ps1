using module ..\Models\PlatformConfiguration.ps1

function Get-PlatformConfiguration {

    $config = [PlatformConfiguration]::new()

    $config.PddDirectory = "\\USDBTLBCA1MS1IT\pdd$\PDD"
    $config.ConfigDirectory = "\\USDBTLBCA1MS1IT\pdd$\Config"
    $config.LogDirectory = "\\USDBTLBCA1MS1IT\pdd$\LogFiles"
    $config.IniFilesDirectory = "\\USDBTLBCA1MS1IT\pdd$\IniFiles"

    $config.Toolboxes["BASIC"] = "\\USDBTLBCA1MS1IT\Toolbox$\Basic_Toolbox"
    $config.Toolboxes["OPTION"] = "\\USDBTLBCA1MS1IT\Toolbox$\Option_Toolbox"
    $config.Toolboxes["SITE"] = "\\USDBTLBCA1MS1IT\Toolbox$\Site_Toolbox"

    $config.Catalogs += "Win11.ini"
    $config.Catalogs += "Site.ini"

    return $config
}

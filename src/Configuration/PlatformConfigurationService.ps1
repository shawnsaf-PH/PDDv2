 . "$PSScriptRoot\..\Models\PlatformConfiguration.ps1"
 . "$PSScriptRoot\IniParser.ps1"

function Get-PlatformConfiguration {
    #throw "ENTERED GET-PLATFORMCONFIGURATION"
    
    $configPath = "\\usdbtlbca1msh20.code1.emi.philips.com\pdd$\Pddv2\PDDv2.ini"

    $configData = Read-IniFile -Path $configPath

    $config = [PlatformConfiguration]::new()

    #
    # Core PDDv2 Directories
    #

    $config.PddDirectory = $configData["PDDDIR"]

    $config.ConfigDirectory = $configData["ConfigDIR"]

    $config.LogDirectory = $configData["LogDIR"]

    $config.IniFilesDirectory = $configData["IniFilesDIR"]

    $config.ProfileDirectory = $configData["ProfileDIR"]

    $config.LocalWorkingDirectory = $configData["LocalWorkingDirectory"]

    $config.ResumeLauncher = $configData["ResumeLauncher"]

    $config.Toolboxes["Basic"] =
    $configData["BasicTOOLBOX"]

    $config.Toolboxes["ChassisPatches"] =
        $configData["ChassisPatchesTOOLBOX"]

    $config.Toolboxes["Custom"] =
        $configData["CustomTOOLBOX"]

    $config.Toolboxes["Language"] =
        $configData["LanguageTOOLBOX"]

    $config.Toolboxes["Option"] =
        $configData["OptionTOOLBOX"]

    $config.Toolboxes["Prep"] =
        $configData["PrepTOOLBOX"]

    $config.Toolboxes["Site"] =
        $configData["SiteTOOLBOX"]

    $config.Toolboxes["GlobalSite"] =
        $configData["GlobalSiteTOOLBOX"]

    $config.Toolboxes["Zeppelin"] =
        $configData["ZeppelinTOOLBOX"]

    $config.Catalogs = @()

    $config.Catalogs += $configData["OS"]

    $config.Catalogs += $configData["IMAGE"]

    $siteCatalogs = $configData["SITE"]

    $siteCatalogs = $siteCatalogs.Replace('"', '')

    $config.Catalogs += $siteCatalogs.Split(',')

    #
    # Legacy / Configuration Settings
    #

    $config.InstallerEnabled = ConvertTo-Bool $configData["InstallerEnabled"]

    $config.InstallerACC = $configData["InstallerACC"]

    $config.InstallerPASS = $configData["InstallerPASS"]

    $config.JoinACC = $configData["JoinACC"]

    $config.JoinPASS = $configData["JoinPASS"]

    $config.LocalAdminName = $configData["LocalAdminName"]

    $config.LocalAdminPASS = $configData["LocalAdminPASS"]

    $config.InstallMachinePART = ConvertTo-Bool $configData["InstallMachinePART"]

    $config.InstallUserPART = ConvertTo-Bool $configData["InstallUserPART"]

    $config.VerifySelections = ConvertTo-Bool $configData["VerifySelections"]

    $config.UpdateBIOS = ConvertTo-Bool $configData["UpdateBIOS"]

    $config.LayoutEnabled = ConvertTo-Bool $configData["LayoutEnabled"]

    $config.LayoutExtra = $configData["LayoutExtra"]

    $config.LayoutDefault = $configData["LayoutDefault"]
    
    if (-not (Test-Path $config.LocalWorkingDirectory)) {

        New-Item `
            -Path $config.LocalWorkingDirectory `
            -ItemType Directory `
            -Force | Out-Null
    }
    
    return $config
}

function ConvertTo-Bool {

    param(
        [string]$Value
    )

    return $Value.ToUpper() -eq "TRUE"
}

Get-platformConfiguration

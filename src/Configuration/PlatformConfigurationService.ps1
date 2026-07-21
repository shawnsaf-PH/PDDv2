 . "$PSScriptRoot\..\Models\PlatformConfiguration.ps1"
 . "$PSScriptRoot\IniParser.ps1"

function Get-PlatformConfiguration {
    #throw "ENTERED GET-PLATFORMCONFIGURATION"
    
    $configPath = "\\USDBTLBCA1MSH20\pdd$\pdd\PDDv2.ini"

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
    
    Write-Host ""
    Write-Host "Catalogs Loaded:"
    Write-Host ($config.Catalogs -join ', ')
    
    return $config
}

function ConvertTo-Bool {

    param(
        [string]$Value
    )

    return $Value.ToUpper() -eq "TRUE"
}

Get-platformConfiguration

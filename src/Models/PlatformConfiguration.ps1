class PlatformConfiguration {

    [string]$PddDirectory
    [string]$ConfigDirectory
    [string]$LogDirectory
    [string]$IniFilesDirectory
    [string]$ProfileDirectory

    [hashtable]$Toolboxes
    [string[]]$Catalogs

    [bool]$InstallerEnabled
    [string]$InstallerACC
    [string]$InstallerPASS

    [string]$JoinACC
    [string]$JoinPASS

    [string]$LocalAdminName
    [string]$LocalAdminPASS

    [bool]$InstallMachinePART
    [bool]$InstallUserPART

    [bool]$VerifySelections

    [bool]$UpdateBIOS

    [bool]$LayoutEnabled
    [string]$LayoutExtra
    [string]$LayoutDefault

    PlatformConfiguration() {

        $this.Toolboxes = @{}
        $this.Catalogs = @()
    }
}

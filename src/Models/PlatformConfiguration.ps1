class PlatformConfiguration {

    [string]$PddDirectory
    [string]$ConfigDirectory
    [string]$LogDirectory
    [string]$IniFilesDirectory

    [hashtable]$Toolboxes
    [string[]]$Catalogs

    PlatformConfiguration() {
        $this.Toolboxes = @{}
        $this.Catalogs = @()
    }
}

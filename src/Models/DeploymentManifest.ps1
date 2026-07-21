class DeploymentManifest {

    [bool]$InstallMachinePart

    [bool]$InstallUserPart

    [System.Collections.ArrayList]$Steps

    DeploymentManifest() {

        $this.InstallMachinePart = $true
        $this.InstallUserPart = $true

        $this.Steps =
            [System.Collections.ArrayList]::new()
    }
}
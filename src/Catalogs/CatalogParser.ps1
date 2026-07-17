. "$PSScriptRoot\..\Models\ApplicationDefinition.ps1"

function Read-CatalogFile {

    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $applications = @()

    $currentApp = $null

    Get-Content $Path | ForEach-Object {

        $line = $_.Trim()

        if ([string]::IsNullOrWhiteSpace($line)) {
            return
        }

        if ($line.StartsWith(';')) {
            return
        }

        if ($line -match '^\[(.+)\]$') {

            if ($null -ne $currentApp) {
                $applications += $currentApp
            }

            $currentApp = [ApplicationDefinition]::new()
            $currentApp.Name = $matches[1]

            return
        }

        if ($null -eq $currentApp) {
            return
        }

        if ($line -match '^(.*?)=(.*)$') {

            $key = $matches[1].Trim()
            $value = $matches[2].Trim()

            switch ($key.ToUpper()) {

                'OPTIONAL' {
                    $currentApp.Optional = ($value -eq 'TRUE')
                }

                'DIRECTORY' {
                    $currentApp.Directory = $value
                }

                'MACHINEEXE' {
                    $currentApp.MachineExe = $value
                }

                'USEREXE' {
                    $currentApp.UserExe = $value
                }

                'DEPARTMENT' {
                    $currentApp.Department = $value
                }

                'REBOOT' {
                    $currentApp.Reboot = ($value -eq 'TRUE')
                }
            }
        }
    }

    if ($null -ne $currentApp) {
        $applications += $currentApp
    }

    return $applications
}

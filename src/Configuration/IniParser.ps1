function Read-IniFile {

    param(
        [string]$Path
    )

    $result = @{}

    Get-Content $Path | ForEach-Object {

        $line = $_.Trim()

        if ([string]::IsNullOrWhiteSpace($line)) {
            return
        }

        if ($line.StartsWith(';')) {
            return
        }

        if ($line -match '^(.*?)=(.*)$') {

            $key = $matches[1].Trim()
            $value = $matches[2].Trim()

            $result[$key] = $value
        }
    }

    return $result
}

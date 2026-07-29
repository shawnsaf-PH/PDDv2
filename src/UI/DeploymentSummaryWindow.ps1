function New-DeploymentSummaryWindow {

    $xamlPath =
        Join-Path `
            $PSScriptRoot `
            "DeploymentSummaryWindow.xaml"

    $reader =
        [System.Xml.XmlReader]::Create($xamlPath)

    $window =
        [Windows.Markup.XamlReader]::Load($reader)

    return $window
}
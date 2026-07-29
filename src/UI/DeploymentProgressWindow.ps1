function New-DeploymentProgressWindow {

    $xamlPath =
        Join-Path `
            $PSScriptRoot `
            "DeploymentProgressWindow.xaml"

    $reader =
        [System.Xml.XmlReader]::Create($xamlPath)

    $window =
        [Windows.Markup.XamlReader]::Load($reader)

    return $window
}
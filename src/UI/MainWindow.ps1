write-host "Loading MainWindow.ps1"
Add-Type -AssemblyName PresentationFramework

[xml]$xaml =
Get-Content `
    "$PSScriptRoot\MainWindow.xaml" -Raw

$reader =
    New-Object System.Xml.XmlNodeReader $xaml

$window =
    [Windows.Markup.XamlReader]::Load($reader)

$applicationList =
    $window.FindName("ApplicationList")

$applicationList.Items.Add("Google Chrome")
$applicationList.Items.Add("Adobe Reader")
$applicationList.Items.Add("Minitab")

$window.ShowDialog()
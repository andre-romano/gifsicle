
$ErrorActionPreference = 'Stop'

$packageName = 'gifsicle'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$unzipLocation = Join-Path "$toolsDir" "$packageName"

$executables = @('gifsicle', 'gifdiff')

Write-Output "Remove shim files..."
foreach ($executable in $executables) {
    Uninstall-BinFile -Name "$executable"
}

Write-Output "Removing extracted files ..."
Remove-Item -Recurse -Force "$unzipLocation"
if (Test-Path "$unzipLocation") {
    Write-Error "Unzip folder still exists: $unzipLocation"
    Exit 1
}

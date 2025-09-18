
$ErrorActionPreference = 'Stop'

$packageName = 'gifsicle'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$unzipLocation = Join-Path "$toolsDir" "$packageName"

$executables = @('gifsicle', 'gifdiff')

if (Test-Path "$unzipLocation") {
    Write-Warning "Unzip folder \"$unzipLocation\" exists, removing ..."
    Remove-Item -Recurse -Force "$unzipLocation"
}

Install-ChocolateyZipPackage `
    -PackageName "$packageName" `
    -UnzipLocation "$unzipLocation" `
    -Url64bit "https://eternallybored.org/misc/gifsicle/releases/gifsicle-1.95-win64.zip" `
    -Checksum64 "7e47dd0bfd5ee47f911464c57faeed89a8709a7625dd1c449b16579889539ee8" `
    -ChecksumType64 'sha256' `
    -Url "https://eternallybored.org/misc/gifsicle/releases/gifsicle-1.95-win32.zip" `
    -Checksum "f31464e334b9fb83d4dc60a25bde7cfa35829564bc378c40f0d3c6350910256c" `
    -ChecksumType 'sha256'    

Write-Output "Check installed files ..."
foreach ($executable in $executables) {
    $exePath = Join-Path "$unzipLocation" "$executable.exe"
    if (-Not (Test-Path "$exePath")) {
        Write-Error "File not found: $exePath"
        Exit 1
    }
    & "$exePath" --version # test command
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Test failed: $LASTEXITCODE"
        Exit $LASTEXITCODE
    }
    Write-Output "$executable : OK"    
}

Write-Output "Installing shim files..."
foreach ($executable in $executables) {
    $exePath = Join-Path "$unzipLocation" "$executable.exe"
    Install-BinFile -Name "$executable" -Path "$exePath"
}
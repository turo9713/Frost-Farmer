$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$dotnet = if (Test-Path "$root\.dotnet\dotnet.exe") { "$root\.dotnet\dotnet.exe" } else { 'dotnet' }
$env:DOTNET_CLI_HOME = "$root\.dotnet-home"
$env:APPDATA = "$root\.appdata"
$env:USERPROFILE = "$root\.profile"
$output = "$root\artifacts\FrostFarmer-4.0.0-win-x64"
if (Test-Path $output) { Remove-Item $output -Recurse -Force }
& $dotnet publish "$root\src\FrostFarmer" -c Release -r win-x64 --self-contained false -o $output
Copy-Item "$root\README.md","$root\LICENSE" $output -ErrorAction SilentlyContinue
Compress-Archive -Path "$output\*" -DestinationPath "$output.zip" -Force
Write-Host "Package: $output.zip"

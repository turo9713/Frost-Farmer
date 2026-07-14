param([string]$InstallDirectory = "$env:LOCALAPPDATA\FrostFarmer")
$ErrorActionPreference = 'Stop'
$package = Join-Path (Split-Path $PSScriptRoot -Parent) 'artifacts\FrostFarmer-4.0.0-win-x64'
if (!(Test-Path $package)) { throw 'Run scripts/package.ps1 first.' }
New-Item -ItemType Directory -Force -Path $InstallDirectory | Out-Null
Copy-Item "$package\*" $InstallDirectory -Recurse -Force
Write-Host "Installed to $InstallDirectory. Run FrostFarmer.exe to start."

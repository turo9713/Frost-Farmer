$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$dotnet = if (Test-Path "$root\.dotnet\dotnet.exe") { "$root\.dotnet\dotnet.exe" } else { 'dotnet' }
$env:DOTNET_CLI_HOME = "$root\.dotnet-home"
$env:NUGET_PACKAGES = "$root\.nuget\packages"
$env:APPDATA = "$root\.appdata"
$env:USERPROFILE = "$root\.profile"
$env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'
& $dotnet build "$root\FrostFarmer.sln" --configuration Release
& $dotnet run --project "$root\tests\FrostFarmer.Tests" --configuration Release --no-build

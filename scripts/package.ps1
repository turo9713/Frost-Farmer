$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot 'validate.ps1')

$versionLine = Select-String -LiteralPath (Join-Path $root 'FrostFarmer.toc') -Pattern '^## Version: (.+)$'
if (!$versionLine) { throw 'Version is missing from FrostFarmer.toc.' }
$version = $versionLine.Matches[0].Groups[1].Value
$artifacts = Join-Path $root 'artifacts'
$stage = Join-Path $artifacts 'stage'
$addon = Join-Path $stage 'FrostFarmer'
$archive = Join-Path $artifacts "FrostFarmer-$version.zip"

if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage -Recurse -Force }
New-Item -ItemType Directory -Path $addon -Force | Out-Null

$releaseFiles = @('FrostFarmer.toc', 'Core.lua', 'Tracker.lua', 'Planner.lua', 'MacroManager.lua', 'ActionBar.lua', 'UI.lua', 'Commands.lua', 'README.md', 'LICENSE')
foreach ($file in $releaseFiles) {
    Copy-Item -LiteralPath (Join-Path $root $file) -Destination $addon
}
if (Test-Path -LiteralPath $archive) { Remove-Item -LiteralPath $archive -Force }
Compress-Archive -LiteralPath $addon -DestinationPath $archive -CompressionLevel Optimal
Remove-Item -LiteralPath $stage -Recurse -Force
Write-Host "Created $archive"

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$toc = Join-Path $root 'FrostFarmer.toc'

if (!(Test-Path -LiteralPath $toc)) { throw 'FrostFarmer.toc is missing.' }
$tocText = Get-Content -LiteralPath $toc -Raw
if ($tocText -notmatch '(?m)^## Interface: 120000$') { throw 'Unsupported or missing Interface value.' }
if ($tocText -notmatch '(?m)^## SavedVariables: FrostFarmerDB$') { throw 'SavedVariables declaration is missing.' }

$files = Get-Content -LiteralPath $toc | Where-Object { $_ -match '\.lua$' }
if ($files.Count -eq 0) { throw 'The TOC does not load any Lua files.' }
foreach ($file in $files) {
    $path = Join-Path $root $file
    if (!(Test-Path -LiteralPath $path)) { throw "TOC references missing file: $file" }
}

$lua = Get-ChildItem -LiteralPath $root -Filter '*.lua' -File
$forbidden = 'RunMacroText|CastSpellByName|MoveForwardStart|JumpOrAscendStart|SendChatMessage\s*\('
foreach ($file in $lua) {
    $content = Get-Content -LiteralPath $file.FullName -Raw
    if ($content -match $forbidden) { throw "Forbidden automation API in $($file.Name)." }
    if ($content -notmatch 'local _, FF = \.\.\.|local addonName, FF = \.\.\.') { throw "Missing addon namespace in $($file.Name)." }
}

Write-Host "Validated $($lua.Count) Lua files and $($files.Count) TOC entries."

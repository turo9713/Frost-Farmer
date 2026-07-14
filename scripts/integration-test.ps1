$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$dotnet = if (Test-Path "$root\.dotnet\dotnet.exe") { "$root\.dotnet\dotnet.exe" } else { 'dotnet' }
$env:APPDATA = "$root\.appdata"; $env:USERPROFILE = "$root\.profile"; $env:DOTNET_CLI_HOME = "$root\.dotnet-home"
$env:FROST_FrostFarmer__ApiKey = 'integration-secret'
$env:FROST_Urls = 'http://127.0.0.1:5089'
$process = Start-Process $dotnet -ArgumentList @('run','--project',"$root\src\FrostFarmer",'--configuration','Release','--no-build') -PassThru -WindowStyle Hidden
try {
  $ready = $false
  foreach ($attempt in 1..30) {
    try { $health = Invoke-RestMethod 'http://127.0.0.1:5089/health'; if ($health.status -eq 'healthy') { $ready = $true; break } } catch { Start-Sleep -Milliseconds 250 }
  }
  if (!$ready) { throw 'Server did not become healthy.' }
  try { Invoke-RestMethod 'http://127.0.0.1:5089/api/tasks' | Out-Null; throw 'Unauthenticated request unexpectedly succeeded.' } catch { if ($_.Exception.Response.StatusCode.value__ -ne 401) { throw } }
  $headers = @{ 'X-Api-Key' = 'integration-secret' }
  $task = Invoke-RestMethod 'http://127.0.0.1:5089/api/tasks' -Method Post -Headers $headers -ContentType 'application/json' -Body '{"goal":"echo integration works","priority":5}'
  $completed = $null
  foreach ($attempt in 1..30) {
    Start-Sleep -Milliseconds 250
    $completed = Invoke-RestMethod "http://127.0.0.1:5089/api/tasks/$($task.id)" -Headers $headers
    if ($completed.status -eq 'Completed') { break }
  }
  if ($completed.status -ne 'Completed' -or $completed.result -notmatch 'integration works') { throw 'Scheduled task did not complete correctly.' }
  Write-Host 'PASS authenticated REST API, scheduler, agents, plugin, memory persistence'
} finally { if (!$process.HasExited) { Stop-Process -Id $process.Id -Force } }

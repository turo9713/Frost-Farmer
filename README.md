# Frost Farmer 4.0

Frost Farmer is a locally hosted agent runtime. Version 4.0 accepts goals through an authenticated REST API or web dashboard, plans them, schedules concurrent work, dispatches agent steps, invokes matching plugins, and persists tasks and memory.

## Requirements

- Windows, Linux, or macOS with the .NET 8 SDK
- PowerShell 7+ for the supplied automation scripts (Windows PowerShell 5.1 also works)

No third-party NuGet packages are required.

## Build and test

```powershell
./scripts/build.ps1
./scripts/integration-test.ps1
```

The first script performs a Release build and runs the unit test executable. The second starts a real HTTP server and verifies authentication, task creation, scheduling, agent execution, plugin dispatch, and persistence.

## Run locally

For development, `change-me` is the default key:

```powershell
dotnet run --project src/FrostFarmer
```

Open <http://localhost:5080> and enter the API key. For any non-development deployment, configure a strong key:

```powershell
$env:FROST_FrostFarmer__ApiKey = 'replace-with-a-long-random-secret'
dotnet run --project src/FrostFarmer --configuration Release
```

API routes are `/health`, `/api/runtime`, `/api/tasks`, `/api/tasks/{id}`, `/api/memory`, and `/api/update`. All `/api` routes require `X-Api-Key`.

## Plugins

Create a .NET 8 class library referencing `FrostFarmer.dll`, implement `IFrostPlugin`, and copy its DLL to `plugins/`. Plugins are discovered at startup. A working `echo` plugin is built in and handles goals such as `echo hello`.

## Data and configuration

Tasks and memories are atomically persisted to `data/frost-farmer.db.json`. Settings live in `appsettings.json` and can be overridden using `FROST_` environment variables. `UpdateManifestUrl` may point to JSON shaped like:

```json
{ "version": "4.0.1", "packageUrl": "https://example/releases/4.0.1.zip", "sha256": "..." }
```

The update endpoint checks version metadata; installation remains an explicit administrator action.

## Package and install

```powershell
./scripts/package.ps1
./scripts/install.ps1
```

Packaging produces `artifacts/FrostFarmer-4.0.0-win-x64.zip`. The installer copies the expanded release to `%LOCALAPPDATA%\FrostFarmer` by default. Run `FrostFarmer.exe` there after setting the production API key.

## Architecture

- `FrostRuntime` owns task lifecycle and writes execution results to memory.
- `PlanningEngine` turns validated goals into agent steps.
- `TaskSchedulerService` prioritizes queued tasks with bounded concurrency.
- `AgentSystem` routes steps to analysis and execution agents.
- `PluginCatalog` discovers external plugin assemblies.
- `JsonDatabase` provides locked, atomic durable storage without an external database service.
- ASP.NET Core provides REST, authentication middleware, structured JSON logs, health checks, and the dashboard.

## Known limitations

- The built-in executor is deterministic; integrations with external AI providers must be supplied as plugins.
- JSON storage is intended for a single process and moderate local workloads, not multi-node transactional use.
- API-key authentication has no user accounts, roles, or browser sessions.
- The updater checks signed-release metadata fields but does not automatically download or execute packages.

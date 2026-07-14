# Frost Farmer 4.0

Frost Farmer is a deployable agent runtime. Version 4.0 accepts goals through an authenticated REST API or web dashboard, plans them, schedules concurrent work, dispatches agent steps, invokes matching plugins, and persists tasks and memory.

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

Start the development server and create the first administrator in the dashboard:

```powershell
dotnet run --project src/FrostFarmer
```

Open <http://localhost:5080>. The first account becomes administrator; subsequent public registration is automatically rejected because only the first user may bootstrap the installation.

API routes include `/health/live`, `/health/ready`, `/api/auth/*`, `/api/runtime`, `/api/tasks`, `/api/memory`, and `/api/update`. Protected routes require `Authorization: Bearer TOKEN`.

## Plugins

Create a .NET 8 class library referencing `FrostFarmer.dll`, implement `IFrostPlugin`, and copy its DLL to `plugins/`. Plugins are discovered at startup. A working `echo` plugin is built in and handles goals such as `echo hello`.

## Data and configuration

Development tasks, users and memories are atomically persisted to `data/frost-farmer.db.json`. Production uses PostgreSQL when `FROST_FrostFarmer__DatabaseConnectionString` is set. Settings live in `appsettings.json` and can be overridden using `FROST_` environment variables. `UpdateManifestUrl` may point to JSON shaped like:

```json
{ "version": "4.0.1", "packageUrl": "https://example/releases/4.0.1.zip", "sha256": "..." }
```

The update endpoint checks version metadata; installation remains an explicit administrator action.

## Package and install

```powershell
./scripts/package.ps1
./scripts/install.ps1
```

Packaging produces `artifacts/FrostFarmer-4.0.0-win-x64.zip`. The installer copies the expanded release to `%LOCALAPPDATA%\FrostFarmer` by default. Run `FrostFarmer.exe` there and create the first administrator through the dashboard.

## Online production deployment

Production uses the root [Dockerfile](Dockerfile) and the stack in `deploy/`: Frost Farmer, PostgreSQL 16 and Caddy with automatic HTTPS. Copy `deploy/.env.example` to `deploy/.env`, configure the domain, ACME email and a random database password, then run `deploy/deploy.sh` on the server. Detailed instructions are in [deploy/README.md](deploy/README.md).

Pushes to `main` build a GHCR image. The manual `deploy-production` workflow deploys a selected image tag over SSH after GitHub environment approval.

## Architecture

- `FrostRuntime` owns task lifecycle and writes execution results to memory.
- `PlanningEngine` turns validated goals into agent steps.
- `TaskSchedulerService` prioritizes queued tasks with bounded concurrency.
- `AgentSystem` routes steps to analysis and execution agents.
- `PluginCatalog` discovers external plugin assemblies.
- `PostgresDatabase` provides pooled production persistence and idempotent schema migrations; `JsonDatabase` is the development fallback.
- ASP.NET Core provides REST, authentication middleware, structured JSON logs, health checks, and the dashboard.

## Known limitations

- The built-in executor is deterministic; integrations with external AI providers must be supplied as plugins.
- Multi-node scheduler coordination is not implemented; run one application replica until task leasing is added.
- Roles are persisted but the current API exposes only administrator capabilities.
- The updater only checks version metadata and does not automatically download or execute packages.

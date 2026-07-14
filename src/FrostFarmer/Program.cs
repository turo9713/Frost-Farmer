using System.Security.Cryptography;
using System.Text;
using System.Text.Json.Serialization;
using FrostFarmer;
using Microsoft.Extensions.Options;

var builder = WebApplication.CreateBuilder(args);
builder.Configuration.AddJsonFile("appsettings.json", optional: false).AddEnvironmentVariables("FROST_");
builder.Services.Configure<FrostOptions>(builder.Configuration.GetSection(FrostOptions.Section));
builder.Services.ConfigureHttpJsonOptions(json => json.SerializerOptions.Converters.Add(new JsonStringEnumConverter()));
builder.Services.AddSingleton<JsonDatabase>();
builder.Services.AddSingleton<PlanningEngine>();
builder.Services.AddSingleton<PluginCatalog>();
builder.Services.AddSingleton<IFrostPlugin, EchoPlugin>();
builder.Services.AddSingleton<IFrostAgent, AnalysisAgent>();
builder.Services.AddSingleton<IFrostAgent, ExecutionAgent>();
builder.Services.AddSingleton<AgentSystem>();
builder.Services.AddSingleton<FrostRuntime>();
builder.Services.AddHttpClient<UpdateService>();
builder.Services.AddHostedService<TaskSchedulerService>();
builder.Logging.AddJsonConsole();

var app = builder.Build();
var options = app.Services.GetRequiredService<IOptions<FrostOptions>>().Value;
if (options.ApiKey == "change-me" && !app.Environment.IsDevelopment())
    throw new InvalidOperationException("Set FrostFarmer:ApiKey or FROST_APIKEY before production startup.");

app.UseDefaultFiles(new DefaultFilesOptions { FileProvider = new Microsoft.Extensions.FileProviders.PhysicalFileProvider(Path.Combine(app.Environment.ContentRootPath, "Dashboard")) });
app.UseStaticFiles(new StaticFileOptions { FileProvider = new Microsoft.Extensions.FileProviders.PhysicalFileProvider(Path.Combine(app.Environment.ContentRootPath, "Dashboard")) });
app.Use(async (context, next) =>
{
    if (!context.Request.Path.StartsWithSegments("/api")) { await next(); return; }
    var supplied = context.Request.Headers["X-Api-Key"].ToString();
    var expected = Encoding.UTF8.GetBytes(options.ApiKey);
    var actual = Encoding.UTF8.GetBytes(supplied);
    if (expected.Length != actual.Length || !CryptographicOperations.FixedTimeEquals(expected, actual))
    {
        context.Response.StatusCode = StatusCodes.Status401Unauthorized;
        await context.Response.WriteAsJsonAsync(new { error = "A valid X-Api-Key header is required." });
        return;
    }
    await next();
});

app.MapGet("/health", () => Results.Ok(new { status = "healthy", version = "4.0.0" }));
app.MapGet("/api/runtime", async (FrostRuntime runtime, PluginCatalog catalog, IEnumerable<IFrostPlugin> builtIns) =>
{
    var plugins = builtIns.Concat(catalog.Plugins).Select(x => new PluginDescriptor(x.Name, x.Version, x.Description)).ToArray();
    return Results.Ok(await runtime.SnapshotAsync(plugins));
});
app.MapGet("/api/tasks", async (JsonDatabase database) => Results.Ok(await database.TasksAsync()));
app.MapGet("/api/tasks/{id:guid}", async (Guid id, JsonDatabase database) => await database.TaskAsync(id) is { } task ? Results.Ok(task) : Results.NotFound());
app.MapPost("/api/tasks", async (CreateTask request, FrostRuntime runtime) =>
    string.IsNullOrWhiteSpace(request.Goal) ? Results.BadRequest(new { error = "Goal is required." }) : Results.Created("/api/tasks", await runtime.EnqueueAsync(request.Goal, request.Priority)));
app.MapGet("/api/memory", async (string? query, JsonDatabase database) => Results.Ok(await database.SearchMemoryAsync(query ?? string.Empty)));
app.MapGet("/api/update", async (UpdateService updates, CancellationToken cancellationToken) => Results.Ok(await updates.CheckAsync(cancellationToken)));
app.MapFallbackToFile("index.html", new StaticFileOptions { FileProvider = new Microsoft.Extensions.FileProviders.PhysicalFileProvider(Path.Combine(app.Environment.ContentRootPath, "Dashboard")) });
app.Run();

public sealed record CreateTask(string Goal, int Priority = 0);
public partial class Program;

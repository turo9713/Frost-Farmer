using System.Text.Json.Serialization;
using System.Threading.RateLimiting;
using FrostFarmer;
using Microsoft.Extensions.Options;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.RateLimiting;
using Npgsql;

var builder = WebApplication.CreateBuilder(args);
builder.Configuration.AddJsonFile("appsettings.json", optional: false).AddEnvironmentVariables("FROST_");
builder.Services.Configure<FrostOptions>(builder.Configuration.GetSection(FrostOptions.Section));
builder.Services.ConfigureHttpJsonOptions(json => json.SerializerOptions.Converters.Add(new JsonStringEnumConverter()));
var frost = builder.Configuration.GetSection(FrostOptions.Section).Get<FrostOptions>() ?? new FrostOptions();
if (!string.IsNullOrWhiteSpace(frost.DatabaseConnectionString))
{
    builder.Services.AddSingleton(_ => NpgsqlDataSource.Create(frost.DatabaseConnectionString));
    builder.Services.AddSingleton<IFrostDatabase, PostgresDatabase>();
}
else builder.Services.AddSingleton<IFrostDatabase, JsonDatabase>();
builder.Services.AddSingleton<PlanningEngine>();
builder.Services.AddSingleton<PluginCatalog>();
builder.Services.AddSingleton<IFrostPlugin, EchoPlugin>();
builder.Services.AddSingleton<IFrostAgent, AnalysisAgent>();
builder.Services.AddSingleton<IFrostAgent, ExecutionAgent>();
builder.Services.AddSingleton<AgentSystem>();
builder.Services.AddSingleton<FrostRuntime>();
builder.Services.AddSingleton<AuthenticationService>();
builder.Services.AddHttpClient<UpdateService>();
builder.Services.AddHostedService<TaskSchedulerService>();
builder.Services.AddHealthChecks();
builder.Services.Configure<ForwardedHeadersOptions>(o=>{o.ForwardedHeaders=ForwardedHeaders.XForwardedFor|ForwardedHeaders.XForwardedProto;o.ForwardLimit=1;if(!string.IsNullOrWhiteSpace(frost.DatabaseConnectionString)){o.KnownNetworks.Clear();o.KnownProxies.Clear();}});
builder.Services.AddRateLimiter(o=>{o.RejectionStatusCode=429;o.GlobalLimiter=PartitionedRateLimiter.Create<HttpContext,string>(ctx=>RateLimitPartition.GetFixedWindowLimiter(ctx.Connection.RemoteIpAddress?.ToString()??"unknown",_=>new(){PermitLimit=frost.RequestsPerMinute,Window=TimeSpan.FromMinutes(1),QueueLimit=0}));o.AddFixedWindowLimiter("auth",x=>{x.PermitLimit=10;x.Window=TimeSpan.FromMinutes(1);x.QueueLimit=0;});});
builder.Logging.AddJsonConsole();

var app = builder.Build();
var database=app.Services.GetRequiredService<IFrostDatabase>();
await database.InitializeAsync();

app.UseForwardedHeaders();
app.UseRateLimiter();
app.Use(async(context,next)=>{context.Response.Headers["X-Content-Type-Options"]="nosniff";context.Response.Headers["X-Frame-Options"]="DENY";context.Response.Headers["Referrer-Policy"]="no-referrer";context.Response.Headers["Content-Security-Policy"]="default-src 'self'; style-src 'self'; script-src 'self'; connect-src 'self'";await next();});
app.UseDefaultFiles(new DefaultFilesOptions { FileProvider = new Microsoft.Extensions.FileProviders.PhysicalFileProvider(Path.Combine(app.Environment.ContentRootPath, "Dashboard")) });
app.UseStaticFiles(new StaticFileOptions { FileProvider = new Microsoft.Extensions.FileProviders.PhysicalFileProvider(Path.Combine(app.Environment.ContentRootPath, "Dashboard")) });
app.Use(async (context, next) =>
{
    if (!context.Request.Path.StartsWithSegments("/api")) { await next(); return; }
    if(context.Request.Path.StartsWithSegments("/api/auth/login")||context.Request.Path.StartsWithSegments("/api/auth/register")){await next();return;}
    var header=context.Request.Headers.Authorization.ToString();var raw=header.StartsWith("Bearer ",StringComparison.OrdinalIgnoreCase)?header[7..]:string.Empty;
    var user=await context.RequestServices.GetRequiredService<AuthenticationService>().AuthenticateAsync(raw);
    if (user is null)
    {
        context.Response.StatusCode = StatusCodes.Status401Unauthorized;
        await context.Response.WriteAsJsonAsync(new { error = "A valid bearer token is required." });
        return;
    }
    context.Items["user"]=user;context.Items["token"]=raw;
    await next();
});

app.MapGet("/health/live", () => Results.Ok(new { status = "healthy", version = "4.0.0" }));
app.MapGet("/health/ready", async (IFrostDatabase db,CancellationToken ct) => await db.IsHealthyAsync(ct)?Results.Ok(new{status="ready"}):Results.StatusCode(503));
app.MapGet("/health",()=>Results.Redirect("/health/ready"));
app.MapPost("/api/auth/register",async(AuthRequest r,AuthenticationService auth)=>{try{return Results.Ok(await auth.RegisterAsync(r.Username,r.Password));}catch(Exception e)when(e is ArgumentException or InvalidOperationException){return Results.BadRequest(new{error=e.Message});}}).RequireRateLimiting("auth");
app.MapPost("/api/auth/login",async(AuthRequest r,AuthenticationService auth)=>await auth.LoginAsync(r.Username,r.Password) is{} result?Results.Ok(result):Results.Json(new{error="Invalid credentials."},statusCode:401)).RequireRateLimiting("auth");
app.MapPost("/api/auth/logout",async(HttpContext c,AuthenticationService auth)=>{await auth.LogoutAsync((string)c.Items["token"]!);return Results.NoContent();});
app.MapGet("/api/auth/me",(HttpContext c)=>{var u=(UserAccount)c.Items["user"]!;return Results.Ok(new{u.Id,u.Username,u.Role});});
app.MapGet("/api/runtime", async (FrostRuntime runtime, PluginCatalog catalog, IEnumerable<IFrostPlugin> builtIns) =>
{
    var plugins = builtIns.Concat(catalog.Plugins).Select(x => new PluginDescriptor(x.Name, x.Version, x.Description)).ToArray();
    return Results.Ok(await runtime.SnapshotAsync(plugins));
});
app.MapGet("/api/tasks", async (IFrostDatabase database) => Results.Ok(await database.TasksAsync()));
app.MapGet("/api/tasks/{id:guid}", async (Guid id, IFrostDatabase database) => await database.TaskAsync(id) is { } task ? Results.Ok(task) : Results.NotFound());
app.MapPost("/api/tasks", async (CreateTask request, FrostRuntime runtime) =>
    string.IsNullOrWhiteSpace(request.Goal) ? Results.BadRequest(new { error = "Goal is required." }) : Results.Created("/api/tasks", await runtime.EnqueueAsync(request.Goal, request.Priority)));
app.MapGet("/api/memory", async (string? query, IFrostDatabase database) => Results.Ok(await database.SearchMemoryAsync(query ?? string.Empty)));
app.MapGet("/api/update", async (UpdateService updates, CancellationToken cancellationToken) => Results.Ok(await updates.CheckAsync(cancellationToken)));
app.MapFallbackToFile("index.html", new StaticFileOptions { FileProvider = new Microsoft.Extensions.FileProviders.PhysicalFileProvider(Path.Combine(app.Environment.ContentRootPath, "Dashboard")) });
app.Run();

public sealed record CreateTask(string Goal, int Priority = 0);
public sealed record AuthRequest(string Username,string Password);
public partial class Program;

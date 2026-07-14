using System.Reflection;
using System.Runtime.Loader;
using Microsoft.Extensions.Options;

namespace FrostFarmer;

public sealed class PluginCatalog
{
    private readonly List<IFrostPlugin> _plugins = [];
    public IReadOnlyList<IFrostPlugin> Plugins => _plugins;

    public PluginCatalog(IOptions<FrostOptions> options, ILogger<PluginCatalog> logger)
    {
        Directory.CreateDirectory(options.Value.PluginDirectory);
        foreach (var path in Directory.EnumerateFiles(options.Value.PluginDirectory, "*.dll"))
        {
            try
            {
                var assembly = AssemblyLoadContext.Default.LoadFromAssemblyPath(Path.GetFullPath(path));
                var types = assembly.GetTypes().Where(x => !x.IsAbstract && typeof(IFrostPlugin).IsAssignableFrom(x));
                foreach (var type in types)
                    if (Activator.CreateInstance(type) is IFrostPlugin plugin) _plugins.Add(plugin);
            }
            catch (Exception error) { logger.LogError(error, "Failed to load plugin {Path}", path); }
        }
    }
}

public sealed class EchoPlugin : IFrostPlugin
{
    public string Name => "echo";
    public string Version => "4.0.0";
    public string Description => "Returns text for goals starting with 'echo '";
    public bool CanHandle(string goal) => goal.StartsWith("echo ", StringComparison.OrdinalIgnoreCase);
    public Task<string> ExecuteAsync(string goal, CancellationToken cancellationToken) => Task.FromResult(goal[5..]);
}

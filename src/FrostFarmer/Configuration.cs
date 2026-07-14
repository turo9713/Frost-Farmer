namespace FrostFarmer;

public sealed class FrostOptions
{
    public const string Section = "FrostFarmer";
    public string DataDirectory { get; set; } = "data";
    public string PluginDirectory { get; set; } = "plugins";
    public int SchedulerPollMilliseconds { get; set; } = 250;
    public int MaxConcurrentTasks { get; set; } = 2;
    public string? UpdateManifestUrl { get; set; }
    public string? DatabaseConnectionString { get; set; }
    public bool AllowBootstrapRegistration { get; set; } = true;
    public int TokenLifetimeHours { get; set; } = 24;
    public int RequestsPerMinute { get; set; } = 120;
    public string[] AllowedHosts { get; set; } = ["localhost"];
}

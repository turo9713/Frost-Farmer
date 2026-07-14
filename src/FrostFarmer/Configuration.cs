namespace FrostFarmer;

public sealed class FrostOptions
{
    public const string Section = "FrostFarmer";
    public string DataDirectory { get; set; } = "data";
    public string PluginDirectory { get; set; } = "plugins";
    public string ApiKey { get; set; } = "change-me";
    public int SchedulerPollMilliseconds { get; set; } = 250;
    public int MaxConcurrentTasks { get; set; } = 2;
    public string? UpdateManifestUrl { get; set; }
}

using System.Net.Http.Json;
using Microsoft.Extensions.Options;

namespace FrostFarmer;

public sealed record UpdateManifest(string Version, string PackageUrl, string? Sha256);
public sealed record UpdateStatus(string CurrentVersion, bool Configured, bool UpdateAvailable, UpdateManifest? Latest);

public sealed class UpdateService(HttpClient client, IOptions<FrostOptions> options)
{
    public async Task<UpdateStatus> CheckAsync(CancellationToken cancellationToken)
    {
        const string current = "4.0.0";
        if (string.IsNullOrWhiteSpace(options.Value.UpdateManifestUrl)) return new(current, false, false, null);
        var manifest = await client.GetFromJsonAsync<UpdateManifest>(options.Value.UpdateManifestUrl, cancellationToken)
            ?? throw new InvalidOperationException("The update manifest was empty.");
        var available = Version.TryParse(manifest.Version, out var latest) && latest > new Version(current);
        return new(current, true, available, manifest);
    }
}

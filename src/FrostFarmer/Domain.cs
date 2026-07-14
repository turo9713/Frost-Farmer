namespace FrostFarmer;

public enum WorkStatus { Queued, Running, Completed, Failed, Cancelled }
public sealed record WorkTask(Guid Id, string Goal, WorkStatus Status, int Priority, DateTimeOffset CreatedAt, DateTimeOffset? UpdatedAt = null, string? Result = null, string? Error = null);
public sealed record MemoryEntry(Guid Id, string Scope, string Content, DateTimeOffset CreatedAt);
public sealed record PlanStep(int Order, string Description, string Agent, bool Completed = false);
public sealed record Plan(Guid TaskId, IReadOnlyList<PlanStep> Steps);
public sealed record AgentDescriptor(string Name, string Description);
public sealed record PluginDescriptor(string Name, string Version, string Description);
public sealed record RuntimeSnapshot(string Version, DateTimeOffset StartedAt, int Queued, int Running, int Completed, int Failed, IReadOnlyList<AgentDescriptor> Agents, IReadOnlyList<PluginDescriptor> Plugins);

public interface IFrostPlugin
{
    string Name { get; }
    string Version { get; }
    string Description { get; }
    bool CanHandle(string goal);
    Task<string> ExecuteAsync(string goal, CancellationToken cancellationToken);
}

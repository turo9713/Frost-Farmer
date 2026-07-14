namespace FrostFarmer;

public interface IFrostAgent
{
    AgentDescriptor Descriptor { get; }
    bool CanHandle(PlanStep step);
    Task<string> ExecuteAsync(PlanStep step, CancellationToken cancellationToken);
}

public sealed class AnalysisAgent : IFrostAgent
{
    public AgentDescriptor Descriptor => new("analyst", "Extracts intent and validates a task goal");
    public bool CanHandle(PlanStep step) => step.Agent == Descriptor.Name;
    public Task<string> ExecuteAsync(PlanStep step, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        return Task.FromResult($"Validated: {step.Description}");
    }
}

public sealed class ExecutionAgent(IEnumerable<IFrostPlugin> plugins, PluginCatalog catalog) : IFrostAgent
{
    public AgentDescriptor Descriptor => new("executor", "Executes goals through registered plugins or the built-in processor");
    public bool CanHandle(PlanStep step) => step.Agent == Descriptor.Name;
    public async Task<string> ExecuteAsync(PlanStep step, CancellationToken cancellationToken)
    {
        var plugin = plugins.Concat(catalog.Plugins).FirstOrDefault(x => x.CanHandle(step.Description));
        return plugin is null
            ? $"Processed: {step.Description}"
            : await plugin.ExecuteAsync(step.Description, cancellationToken);
    }
}

public sealed class AgentSystem(IEnumerable<IFrostAgent> agents)
{
    private readonly IReadOnlyList<IFrostAgent> _agents = agents.ToArray();
    public IReadOnlyList<AgentDescriptor> Descriptors => _agents.Select(x => x.Descriptor).ToArray();

    public Task<string> ExecuteAsync(PlanStep step, CancellationToken cancellationToken)
    {
        var agent = _agents.FirstOrDefault(x => x.CanHandle(step)) ?? throw new InvalidOperationException($"No agent can execute '{step.Agent}'.");
        return agent.ExecuteAsync(step, cancellationToken);
    }
}

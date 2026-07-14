namespace FrostFarmer;

public sealed class FrostRuntime(JsonDatabase database, PlanningEngine planner, AgentSystem agents, ILogger<FrostRuntime> logger)
{
    private readonly DateTimeOffset _startedAt = DateTimeOffset.UtcNow;

    public async Task<WorkTask> EnqueueAsync(string goal, int priority = 0)
    {
        var task = new WorkTask(Guid.NewGuid(), goal.Trim(), WorkStatus.Queued, priority, DateTimeOffset.UtcNow);
        _ = planner.Create(task);
        await database.SaveTaskAsync(task);
        logger.LogInformation("Task {TaskId} queued with priority {Priority}", task.Id, priority);
        return task;
    }

    public async Task ExecuteAsync(WorkTask task, CancellationToken cancellationToken)
    {
        var running = task with { Status = WorkStatus.Running, UpdatedAt = DateTimeOffset.UtcNow };
        await database.SaveTaskAsync(running);
        try
        {
            var outputs = new List<string>();
            foreach (var step in planner.Create(running).Steps)
                outputs.Add(await agents.ExecuteAsync(step, cancellationToken));
            var result = string.Join(Environment.NewLine, outputs);
            await database.AddMemoryAsync(new MemoryEntry(Guid.NewGuid(), task.Id.ToString(), result, DateTimeOffset.UtcNow));
            await database.SaveTaskAsync(running with { Status = WorkStatus.Completed, Result = result, UpdatedAt = DateTimeOffset.UtcNow });
        }
        catch (OperationCanceledException)
        {
            await database.SaveTaskAsync(running with { Status = WorkStatus.Cancelled, UpdatedAt = DateTimeOffset.UtcNow });
        }
        catch (Exception error)
        {
            logger.LogError(error, "Task {TaskId} failed", task.Id);
            await database.SaveTaskAsync(running with { Status = WorkStatus.Failed, Error = error.Message, UpdatedAt = DateTimeOffset.UtcNow });
        }
    }

    public async Task<RuntimeSnapshot> SnapshotAsync(IReadOnlyList<PluginDescriptor> plugins)
    {
        var tasks = await database.TasksAsync();
        return new("4.0.0", _startedAt, tasks.Count(x => x.Status == WorkStatus.Queued), tasks.Count(x => x.Status == WorkStatus.Running), tasks.Count(x => x.Status == WorkStatus.Completed), tasks.Count(x => x.Status == WorkStatus.Failed), agents.Descriptors, plugins);
    }
}

using Microsoft.Extensions.Options;

namespace FrostFarmer;

public sealed class TaskSchedulerService(JsonDatabase database, FrostRuntime runtime, IOptions<FrostOptions> options, ILogger<TaskSchedulerService> logger) : BackgroundService
{
    private readonly SemaphoreSlim _slots = new(options.Value.MaxConcurrentTasks, options.Value.MaxConcurrentTasks);

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        logger.LogInformation("Scheduler started with {Slots} execution slots", options.Value.MaxConcurrentTasks);
        while (!stoppingToken.IsCancellationRequested)
        {
            var queued = (await database.TasksAsync()).Where(x => x.Status == WorkStatus.Queued).OrderByDescending(x => x.Priority).ThenBy(x => x.CreatedAt).ToArray();
            foreach (var task in queued)
            {
                if (!await _slots.WaitAsync(0, stoppingToken)) break;
                _ = RunAsync(task, stoppingToken);
            }
            await Task.Delay(options.Value.SchedulerPollMilliseconds, stoppingToken);
        }
    }

    private async Task RunAsync(WorkTask task, CancellationToken cancellationToken)
    {
        try
        {
            if ((await database.TaskAsync(task.Id))?.Status == WorkStatus.Queued)
                await runtime.ExecuteAsync(task, cancellationToken);
        }
        finally { _slots.Release(); }
    }
}

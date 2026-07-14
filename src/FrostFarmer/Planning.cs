namespace FrostFarmer;

public sealed class PlanningEngine
{
    public Plan Create(WorkTask task)
    {
        if (string.IsNullOrWhiteSpace(task.Goal)) throw new ArgumentException("A goal is required.", nameof(task));
        return new(task.Id,
        [
            new PlanStep(1, task.Goal.Trim(), "analyst"),
            new PlanStep(2, task.Goal.Trim(), "executor")
        ]);
    }
}

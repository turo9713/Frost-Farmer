using System.Text.Json;
using Microsoft.Extensions.Options;

namespace FrostFarmer;

public sealed class JsonDatabase
{
    private readonly string _path;
    private readonly SemaphoreSlim _gate = new(1, 1);
    private State _state = new([], []);
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web) { WriteIndented = true };

    public JsonDatabase(IOptions<FrostOptions> options)
    {
        Directory.CreateDirectory(options.Value.DataDirectory);
        _path = Path.Combine(options.Value.DataDirectory, "frost-farmer.db.json");
        if (File.Exists(_path)) _state = JsonSerializer.Deserialize<State>(File.ReadAllText(_path), JsonOptions) ?? _state;
    }

    public async Task<IReadOnlyList<WorkTask>> TasksAsync()
    {
        await _gate.WaitAsync();
        try { return _state.Tasks.OrderByDescending(x => x.CreatedAt).ToArray(); }
        finally { _gate.Release(); }
    }

    public async Task<WorkTask?> TaskAsync(Guid id) => (await TasksAsync()).SingleOrDefault(x => x.Id == id);

    public async Task SaveTaskAsync(WorkTask task)
    {
        await _gate.WaitAsync();
        try
        {
            _state.Tasks.RemoveAll(x => x.Id == task.Id);
            _state.Tasks.Add(task);
            await PersistAsync();
        }
        finally { _gate.Release(); }
    }

    public async Task AddMemoryAsync(MemoryEntry entry)
    {
        await _gate.WaitAsync();
        try { _state.Memory.Add(entry); await PersistAsync(); }
        finally { _gate.Release(); }
    }

    public async Task<IReadOnlyList<MemoryEntry>> SearchMemoryAsync(string query, int limit = 20)
    {
        await _gate.WaitAsync();
        try { return _state.Memory.Where(x => x.Content.Contains(query, StringComparison.OrdinalIgnoreCase) || x.Scope.Contains(query, StringComparison.OrdinalIgnoreCase)).OrderByDescending(x => x.CreatedAt).Take(limit).ToArray(); }
        finally { _gate.Release(); }
    }

    private Task PersistAsync()
    {
        var temporary = _path + ".tmp";
        File.WriteAllText(temporary, JsonSerializer.Serialize(_state, JsonOptions));
        File.Move(temporary, _path, true);
        return Task.CompletedTask;
    }

    private sealed record State(List<WorkTask> Tasks, List<MemoryEntry> Memory);
}

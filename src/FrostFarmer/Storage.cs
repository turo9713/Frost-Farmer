using System.Text.Json;
using Microsoft.Extensions.Options;

namespace FrostFarmer;

public interface IFrostDatabase
{
    Task InitializeAsync(CancellationToken cancellationToken = default);
    Task<IReadOnlyList<WorkTask>> TasksAsync();
    Task<WorkTask?> TaskAsync(Guid id);
    Task SaveTaskAsync(WorkTask task);
    Task AddMemoryAsync(MemoryEntry entry);
    Task<IReadOnlyList<MemoryEntry>> SearchMemoryAsync(string query, int limit = 20);
    Task<int> UserCountAsync();
    Task<UserAccount?> UserByNameAsync(string username);
    Task<UserAccount?> UserByIdAsync(Guid id);
    Task SaveUserAsync(UserAccount user);
    Task<bool> TryCreateFirstUserAsync(UserAccount user);
    Task SaveTokenAsync(AccessToken token);
    Task<AccessToken?> TokenByHashAsync(string hash);
    Task RevokeTokenAsync(string hash);
    Task<bool> IsHealthyAsync(CancellationToken cancellationToken = default);
}

public sealed class JsonDatabase : IFrostDatabase
{
    private readonly string _path; private readonly SemaphoreSlim _gate = new(1,1);
    private State _state = new([],[],[],[]);
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web){WriteIndented=true};
    public JsonDatabase(IOptions<FrostOptions> options){Directory.CreateDirectory(options.Value.DataDirectory);_path=Path.Combine(options.Value.DataDirectory,"frost-farmer.db.json");if(File.Exists(_path))_state=JsonSerializer.Deserialize<State>(File.ReadAllText(_path),Json)??_state;}
    public Task InitializeAsync(CancellationToken cancellationToken=default)=>Task.CompletedTask;
    public async Task<IReadOnlyList<WorkTask>> TasksAsync()=>await Read(s=>s.Tasks.OrderByDescending(x=>x.CreatedAt).ToArray());
    public async Task<WorkTask?> TaskAsync(Guid id)=>(await TasksAsync()).SingleOrDefault(x=>x.Id==id);
    public Task SaveTaskAsync(WorkTask task)=>Write(s=>{s.Tasks.RemoveAll(x=>x.Id==task.Id);s.Tasks.Add(task);});
    public Task AddMemoryAsync(MemoryEntry entry)=>Write(s=>s.Memory.Add(entry));
    public async Task<IReadOnlyList<MemoryEntry>> SearchMemoryAsync(string q,int limit=20)=>await Read(s=>s.Memory.Where(x=>x.Content.Contains(q,StringComparison.OrdinalIgnoreCase)||x.Scope.Contains(q,StringComparison.OrdinalIgnoreCase)).OrderByDescending(x=>x.CreatedAt).Take(limit).ToArray());
    public async Task<int> UserCountAsync()=>await Read(s=>s.Users.Count);
    public async Task<UserAccount?> UserByNameAsync(string name)=>await Read(s=>s.Users.SingleOrDefault(x=>x.Username.Equals(name,StringComparison.OrdinalIgnoreCase)));
    public async Task<UserAccount?> UserByIdAsync(Guid id)=>await Read(s=>s.Users.SingleOrDefault(x=>x.Id==id));
    public Task SaveUserAsync(UserAccount user)=>Write(s=>{s.Users.RemoveAll(x=>x.Id==user.Id);s.Users.Add(user);});
    public async Task<bool> TryCreateFirstUserAsync(UserAccount user){await _gate.WaitAsync();try{if(_state.Users.Count!=0)return false;_state.Users.Add(user);var temp=_path+".tmp";await File.WriteAllTextAsync(temp,JsonSerializer.Serialize(_state,Json));File.Move(temp,_path,true);return true;}finally{_gate.Release();}}
    public Task SaveTokenAsync(AccessToken token)=>Write(s=>{s.Tokens.RemoveAll(x=>x.Id==token.Id);s.Tokens.Add(token);s.Tokens.RemoveAll(x=>x.ExpiresAt<DateTimeOffset.UtcNow);});
    public async Task<AccessToken?> TokenByHashAsync(string hash)=>await Read(s=>s.Tokens.SingleOrDefault(x=>x.TokenHash==hash&&x.ExpiresAt>DateTimeOffset.UtcNow));
    public Task RevokeTokenAsync(string hash)=>Write(s=>s.Tokens.RemoveAll(x=>x.TokenHash==hash));
    public Task<bool> IsHealthyAsync(CancellationToken cancellationToken=default)=>Task.FromResult(true);
    private async Task<T> Read<T>(Func<State,T> read){await _gate.WaitAsync();try{return read(_state);}finally{_gate.Release();}}
    private async Task Write(Action<State> write){await _gate.WaitAsync();try{write(_state);var temp=_path+".tmp";await File.WriteAllTextAsync(temp,JsonSerializer.Serialize(_state,Json));File.Move(temp,_path,true);}finally{_gate.Release();}}
    private sealed record State(List<WorkTask> Tasks,List<MemoryEntry> Memory,List<UserAccount> Users,List<AccessToken> Tokens);
}

using FrostFarmer;
using Microsoft.Extensions.Options;
var tests = new (string, Func<Task>)[] { ("planner", Planner), ("persistence", Persistence), ("plugin", Plugin) }; var failed = 0;
foreach (var (name, run) in tests) try { await run(); Console.WriteLine($"PASS {name}"); } catch (Exception e) { failed++; Console.Error.WriteLine($"FAIL {name}: {e.Message}"); }
Console.WriteLine($"{tests.Length-failed}/{tests.Length} tests passed"); return failed;
static Task Planner() { var p = new PlanningEngine().Create(new WorkTask(Guid.NewGuid(), "harvest", WorkStatus.Queued, 0, DateTimeOffset.UtcNow)); Eq(2,p.Steps.Count); Eq("analyst",p.Steps[0].Agent); Eq("executor",p.Steps[1].Agent); return Task.CompletedTask; }
static async Task Persistence() { var dir=Path.Combine(Path.GetTempPath(),"frost-tests-"+Guid.NewGuid()); try { var o=Options.Create(new FrostOptions{DataDirectory=dir}); var db=new JsonDatabase(o); var t=new WorkTask(Guid.NewGuid(),"persist",WorkStatus.Queued,3,DateTimeOffset.UtcNow); await db.SaveTaskAsync(t); await db.AddMemoryAsync(new MemoryEntry(Guid.NewGuid(),"test","remember",DateTimeOffset.UtcNow)); var copy=new JsonDatabase(o); Eq(t.Id,(await copy.TaskAsync(t.Id)??throw new Exception("Task missing")).Id); Eq(1,(await copy.SearchMemoryAsync("remember")).Count); } finally { if(Directory.Exists(dir))Directory.Delete(dir,true); } }
static async Task Plugin() { var p=new EchoPlugin(); True(p.CanHandle("echo frost")); Eq("frost",await p.ExecuteAsync("echo frost",CancellationToken.None)); }
static void Eq<T>(T expected,T actual) where T:notnull { if(!EqualityComparer<T>.Default.Equals(expected,actual))throw new Exception($"Expected {expected}, got {actual}"); } static void True(bool value){if(!value)throw new Exception("Expected true");}

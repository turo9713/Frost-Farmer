local Benchmark = {}
function Benchmark:Start() return GetTime and GetTime() or 0 end
return Benchmark

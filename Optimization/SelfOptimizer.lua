-- Self Optimizer
local SelfOptimizer = {}

function SelfOptimizer.run(metrics)
    return {optimized = true, source = metrics}
end

return SelfOptimizer
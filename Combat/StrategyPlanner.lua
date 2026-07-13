local StrategyPlanner = {}
function StrategyPlanner.Plan(context)
    return {strategy = "safe", context = context}
end
return StrategyPlanner

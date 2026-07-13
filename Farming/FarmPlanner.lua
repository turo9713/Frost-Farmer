local FarmPlanner = {}

function FarmPlanner.CreatePlan(resources)
    return { target = resources or {}, status = "planned" }
end

return FarmPlanner

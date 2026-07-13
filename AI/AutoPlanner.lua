local AutoPlanner = {}

function AutoPlanner:Plan(context)
    return { context = context, status = "planned" }
end

return AutoPlanner

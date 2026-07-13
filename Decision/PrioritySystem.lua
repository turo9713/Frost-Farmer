local PrioritySystem = {}

function PrioritySystem.getPriority(task)
    if task == "critical" then
        return 1
    end
    return 3
end

return PrioritySystem

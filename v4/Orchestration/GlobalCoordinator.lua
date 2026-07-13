local Coordinator = {}

function Coordinator.assign(task, agents)
    return {
        task = task,
        assigned = #agents
    }
end

return Coordinator

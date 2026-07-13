-- Multi Agent Coordination
local Coordinator = {}

function Coordinator.assign(agent, task)
    return {agent = agent, task = task, status = "assigned"}
end

return Coordinator

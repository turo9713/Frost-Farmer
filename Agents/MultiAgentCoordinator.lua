-- Multi Agent Coordination
local Coordinator = {}

function Coordinator.assign(agent, task)
    return {agent = agent, task = task, status = "assigned"}
end

function Coordinator.coordinate(agents)
    return {agents = agents or {}, status = "coordinated"}
end

return Coordinator

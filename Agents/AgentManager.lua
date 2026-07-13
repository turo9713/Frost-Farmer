local AgentManager = {}

AgentManager.agents = {}

function AgentManager.register(name, agent)
    AgentManager.agents[name] = agent
end

function AgentManager.get(name)
    return AgentManager.agents[name]
end

return AgentManager

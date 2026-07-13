-- Frost-Farmer v2 Agent Network
local Network = {}
Network.agents = {}
function Network.register(agent)
 table.insert(Network.agents, agent)
end
return Network

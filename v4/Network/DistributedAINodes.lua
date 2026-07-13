-- Frost-Farmer v4 Distributed AI Nodes
local DistributedAINodes = {}

function DistributedAINodes.register(node)
  return {status="registered", node=node}
end

function DistributedAINodes.sync(nodes)
  return {status="synced", count=#nodes}
end

return DistributedAINodes

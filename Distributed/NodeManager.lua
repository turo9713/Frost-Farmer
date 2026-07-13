local NodeManager = {}

function NodeManager.register(node)
    return {node = node, status = "online"}
end

return NodeManager

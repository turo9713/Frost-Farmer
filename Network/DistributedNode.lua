-- Distributed Node Base
local Node = {}

function Node.connect(id)
    return {node=id, connected=true}
end

return Node

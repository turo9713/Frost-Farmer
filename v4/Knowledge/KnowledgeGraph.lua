-- Frost-Farmer v4 Knowledge Graph
local KnowledgeGraph = {}

KnowledgeGraph.nodes = {}

function KnowledgeGraph.add(node)
    table.insert(KnowledgeGraph.nodes, node)
end

return KnowledgeGraph

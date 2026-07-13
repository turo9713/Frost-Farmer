-- Semantic Search
local SemanticSearch = {}

function SemanticSearch.find(query)
    return {query = query, matches = {}}
end

return SemanticSearch
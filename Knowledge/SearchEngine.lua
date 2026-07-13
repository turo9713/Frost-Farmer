-- Frost-Farmer AI Search Engine
local SearchEngine = {}

function SearchEngine.find(knowledge, query)
    local results = {}
    for key, value in pairs(knowledge) do
        if string.find(string.lower(key), string.lower(query)) then
            table.insert(results, value)
        end
    end
    return results
end

return SearchEngine

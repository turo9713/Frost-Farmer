-- Frost-Farmer AI Knowledge Base
local KnowledgeBase = {}

KnowledgeBase.entries = {}

function KnowledgeBase.add(key, value)
    KnowledgeBase.entries[key] = value
end

function KnowledgeBase.get(key)
    return KnowledgeBase.entries[key]
end

return KnowledgeBase

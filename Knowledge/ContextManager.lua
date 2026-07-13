-- Frost-Farmer AI Context Manager
local ContextManager = {}

ContextManager.context = {}

function ContextManager.set(key, value)
    ContextManager.context[key] = value
end

function ContextManager.get(key)
    return ContextManager.context[key]
end

return ContextManager

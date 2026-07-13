-- Frost-Farmer v0.6 Storage Engine
local StorageEngine = {}

function StorageEngine.save(key, value)
    return {saved = true, key = key, value = value}
end

function StorageEngine.load(key)
    return {key = key, value = nil}
end

return StorageEngine

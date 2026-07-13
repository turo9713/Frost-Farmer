-- Frost-Farmer v3 Memory Layer
local Memory = {}
Memory.storage = {}

function Memory.save(key,value)
    Memory.storage[key] = value
end

function Memory.load(key)
    return Memory.storage[key]
end

return Memory

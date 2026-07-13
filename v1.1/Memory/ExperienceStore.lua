-- Frost-Farmer Experience Memory v1.1
local Memory = {}

Memory.data = {}

function Memory.save(event)
    table.insert(Memory.data, event)
end

function Memory.getAll()
    return Memory.data
end

return Memory

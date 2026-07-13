local Memory = {}
Memory.__index = Memory

function Memory.new()
    return setmetatable({data = {}}, Memory)
end

function Memory:save(value)
    table.insert(self.data, value)
end

function Memory:getAll()
    return self.data
end

return Memory

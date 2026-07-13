local Memory = {}
FrostFarmer.CompanionMemory = Memory

Memory.data = {}

function Memory:Store(key, value)
    self.data[key] = value
end

return Memory

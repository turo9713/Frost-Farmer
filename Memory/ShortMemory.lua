local ShortMemory = {}

ShortMemory.data = {}

function ShortMemory.store(key, value)
    ShortMemory.data[key] = value
end

function ShortMemory.get(key)
    return ShortMemory.data[key]
end

return ShortMemory

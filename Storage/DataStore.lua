local DataStore = {}

DataStore.data = {}

function DataStore.save(key, value)
    DataStore.data[key] = value
end

function DataStore.load(key)
    return DataStore.data[key]
end

return DataStore

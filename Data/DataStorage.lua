local DataStorage = {}

DataStorage.Cache = {}

function DataStorage.Save(key, value)
    DataStorage.Cache[key] = value
end

function DataStorage.Load(key)
    return DataStorage.Cache[key]
end

return DataStorage
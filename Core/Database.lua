local ADDON_NAME, FrostFarmer = ...

FrostFarmer.Database = {}

function FrostFarmer.Database:Initialize()
    self.data = {}
end

function FrostFarmer.Database:Get(key)
    return self.data[key]
end

function FrostFarmer.Database:Set(key, value)
    self.data[key] = value
end

return FrostFarmer.Database

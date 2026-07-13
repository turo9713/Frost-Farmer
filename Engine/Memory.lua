local FrostFarmer = _G.FrostFarmer

FrostFarmer.Memory = FrostFarmer.Memory or {}

function FrostFarmer.Memory:Set(key, value)
    self[key] = value
end

function FrostFarmer.Memory:Get(key)
    return self[key]
end

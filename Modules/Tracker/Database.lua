local FrostFarmer = _G.FrostFarmer or {}
FrostFarmer.TrackerDB = FrostFarmer.TrackerDB or {}

function FrostFarmer.TrackerDB:Save(key, value)
    self[key] = value
end

_G.FrostFarmer = FrostFarmer

local FrostFarmer = _G.FrostFarmer or {}
FrostFarmer.Items = FrostFarmer.Items or {}

function FrostFarmer.Items:Register(id, name)
    self[id] = name
end

_G.FrostFarmer = FrostFarmer

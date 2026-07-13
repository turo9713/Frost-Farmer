local FrostFarmer = _G.FrostFarmer or {}
FrostFarmer.FarmPanel = FrostFarmer.FarmPanel or {}

function FrostFarmer.FarmPanel:Update(stats)
    self.stats = stats or {}
end

return FrostFarmer.FarmPanel

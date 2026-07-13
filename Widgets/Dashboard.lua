local FrostFarmer = _G.FrostFarmer or {}
FrostFarmer.Dashboard = FrostFarmer.Dashboard or {}

function FrostFarmer.Dashboard:Refresh(data)
    self.data = data or {}
end

return FrostFarmer.Dashboard

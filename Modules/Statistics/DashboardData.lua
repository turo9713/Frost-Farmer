local FrostFarmer = _G.FrostFarmer or {}
FrostFarmer.DashboardData = FrostFarmer.DashboardData or {}

function FrostFarmer.DashboardData:Get()
    return self.data or {}
end

return FrostFarmer.DashboardData

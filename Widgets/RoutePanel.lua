local FrostFarmer = _G.FrostFarmer or {}
FrostFarmer.RoutePanel = FrostFarmer.RoutePanel or {}

function FrostFarmer.RoutePanel:SetRoute(route)
    self.route = route or {}
end

return FrostFarmer.RoutePanel

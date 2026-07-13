local FrostFarmer = _G.FrostFarmer

FrostFarmer.Optimizer = {}

function FrostFarmer.Optimizer:ScoreRoute(route)
    return #route
end

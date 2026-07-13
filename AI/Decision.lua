local FrostFarmer = _G.FrostFarmer

FrostFarmer.AI = FrostFarmer.AI or {}

function FrostFarmer.AI:Decide(options)
    return options and options[1]
end

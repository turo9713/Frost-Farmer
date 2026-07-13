local FrostFarmer = _G.FrostFarmer

FrostFarmer.AI = FrostFarmer.AI or {}

function FrostFarmer.AI:Suggest(action)
    return {
        action = action,
        confidence = 0
    }
end

local FrostFarmer = _G.FrostFarmer or {}

function FrostFarmer:Log(message)
    print("[FrostFarmer] " .. tostring(message))
end

_G.FrostFarmer = FrostFarmer

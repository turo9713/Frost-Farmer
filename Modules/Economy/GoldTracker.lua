local FrostFarmer = FrostFarmer or {}
FrostFarmer.Economy = FrostFarmer.Economy or {}

function FrostFarmer.Economy:GetGold()
    return GetMoney and GetMoney() or 0
end

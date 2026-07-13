local FrostFarmer = _G.FrostFarmer
FrostFarmer.Statistics = {}

function FrostFarmer.Statistics:Record(item, amount)
    self[item] = (self[item] or 0) + amount
end

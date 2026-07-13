local FrostFarmer = _G.FrostFarmer

FrostFarmer.AI = FrostFarmer.AI or {}

function FrostFarmer.AI:Learn(data)
    self.history = self.history or {}
    table.insert(self.history, data)
end

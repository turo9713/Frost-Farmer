local ADDON, FrostFarmer = ...

FrostFarmer.Tracker = FrostFarmer.Tracker or {}
FrostFarmer.Tracker.Items = {}

function FrostFarmer.Tracker.Items:Add(itemID)
    table.insert(self, itemID)
end

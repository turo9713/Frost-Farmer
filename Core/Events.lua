local ADDON_NAME, FrostFarmer = ...

FrostFarmer.Events = {}

function FrostFarmer.Events:Register(event, callback)
    local frame = CreateFrame("Frame")
    frame:RegisterEvent(event)
    frame:SetScript("OnEvent", callback)
end

return FrostFarmer.Events

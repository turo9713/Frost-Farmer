local addonName, FrostFarmer = ...

FrostFarmer.Widgets = FrostFarmer.Widgets or {}

function FrostFarmer.Widgets:CreateMainFrame()
    local frame = CreateFrame("Frame", "FrostFarmerMainFrame", UIParent)
    frame:SetSize(320, 220)
    return frame
end

local addonName, FrostFarmer = ...

FrostFarmer.Widgets = FrostFarmer.Widgets or {}

function FrostFarmer.Widgets:CreateStatusBar(parent)
    local bar = CreateFrame("StatusBar", nil, parent)
    bar:SetMinMaxValues(0, 100)
    bar:SetValue(0)
    return bar
end

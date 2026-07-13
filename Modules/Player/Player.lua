local ADDON, FF = ...

local Player = {}

function Player:GetName()
    return UnitName("player")
end

function Player:GetLevel()
    return UnitLevel("player")
end

FF:RegisterModule("Player", Player)

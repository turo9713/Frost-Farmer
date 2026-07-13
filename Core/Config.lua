-- FrostFarmer Configuration Layer
local FF = FrostFarmer

FF.Config = FF.Config or {}

function FF.Config:Get(key)
    return self[key]
end

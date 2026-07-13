local ADDON, FF = ...

local Session = {}

function Session:Initialize()
    self.startTime = GetTime()
end

function Session:GetDuration()
    return GetTime() - (self.startTime or GetTime())
end

FF:RegisterModule("Session", Session)

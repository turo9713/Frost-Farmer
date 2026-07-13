local ADDON, FrostFarmer = ...

FrostFarmer.EventBus = FrostFarmer.EventBus or {}

function FrostFarmer.EventBus:Register(event, callback)
    self[event] = self[event] or {}
    table.insert(self[event], callback)
end

function FrostFarmer.EventBus:Fire(event, ...)
    if not self[event] then return end
    for _, callback in ipairs(self[event]) do
        callback(...)
    end
end

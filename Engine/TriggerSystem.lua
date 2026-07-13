local TriggerSystem = {}

function TriggerSystem:Register(event, callback)
    self.events = self.events or {}
    self.events[event] = callback
end

return TriggerSystem

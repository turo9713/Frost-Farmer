local Analytics = FrostFarmer:CreateModule("Analytics")

function Analytics:Collect(event, data)
    self.events = self.events or {}
    table.insert(self.events, {event = event, data = data})
end

return Analytics

-- Frost-Farmer v0.6 Production Monitor
local Monitor = {}

function Monitor.status()
    return {online = true, health = "ok"}
end

return Monitor

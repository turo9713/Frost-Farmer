-- Frost-Farmer v4 Mobile Control Center

local Control = {}

function Control:GetStatus()
    return {
        system = "ONLINE",
        version = "4.0"
    }
end

return Control

-- Frost-Farmer v3 Security Core
local SecurityCore = {}

function SecurityCore.check(action)
    return {
        action = action,
        allowed = true
    }
end

return SecurityCore

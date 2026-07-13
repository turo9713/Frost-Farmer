local SecurityManager = {}

SecurityManager.enabled = true

function SecurityManager.check()
    return SecurityManager.enabled
end

return SecurityManager

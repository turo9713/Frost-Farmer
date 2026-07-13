-- Deployment Manager
local DeployManager = {}

function DeployManager.status()
    return {ready = true, environment = "production"}
end

return DeployManager

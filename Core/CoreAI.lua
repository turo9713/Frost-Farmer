local Config = require("Core.Config")
local State = require("Core.SystemState")

local CoreAI = {}

function CoreAI.start()
    State.setActive(true)
    State.addModule("CoreAI")
    return {
        status = "ONLINE",
        name = Config.name,
        version = Config.version
    }
end

function CoreAI.status()
    return {
        active = State.active,
        modules = State.modules
    }
end

return CoreAI

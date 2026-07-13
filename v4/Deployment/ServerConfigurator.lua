-- Frost-Farmer v4 Deployment Server Configurator

local ServerConfigurator = {}

function ServerConfigurator.initialize(config)
    return {
        status = "READY",
        environment = config or "production"
    }
end

return ServerConfigurator

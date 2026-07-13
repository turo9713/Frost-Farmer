local HealthCheck = {}

function HealthCheck.Run()
    return {
        runtime = true,
        modules = true,
        status = "ready"
    }
end

return HealthCheck

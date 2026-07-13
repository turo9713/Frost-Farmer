local HealthCheck = {}

function HealthCheck.status()
    return {
        system = "Frost-Farmer",
        status = "READY"
    }
end

return HealthCheck

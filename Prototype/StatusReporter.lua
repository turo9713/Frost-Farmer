local Reporter = {}

function Reporter.status()
    return {
        core = "ready",
        modules = "loaded",
        system = "online"
    }
end

return Reporter

local SystemConnector = {}

function SystemConnector.connect(source, target)
    return {
        source = source,
        target = target,
        status = "connected"
    }
end

return SystemConnector

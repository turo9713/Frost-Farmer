local Console = {}

function Console.handle(command)
    if command == "status" then
        return "System ONLINE"
    elseif command == "optimize" then
        return "Optimization task queued"
    elseif command == "learn" then
        return "Learning cycle started"
    end

    return "Unknown command"
end

return Console

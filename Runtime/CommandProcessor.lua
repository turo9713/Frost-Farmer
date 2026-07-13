local CommandProcessor = {}

function CommandProcessor.process(command)
    if command == "status" then
        return "System status requested"
    end

    if command == "learn" then
        return "Learning cycle requested"
    end

    return "Command received: " .. command
end

return CommandProcessor

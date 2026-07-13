local Engine = {}

Engine.status = "offline"
Engine.commands = {}

function Engine.start()
    Engine.status = "online"
    return "Runtime Engine started"
end

function Engine.registerCommand(name, handler)
    Engine.commands[name] = handler
end

function Engine.execute(command)
    local action = Engine.commands[command]
    if action then
        return action()
    end
    return "Unknown command"
end

return Engine

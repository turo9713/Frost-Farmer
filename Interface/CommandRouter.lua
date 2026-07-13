local CommandRouter = {}

function CommandRouter.route(command, ai)
    if command == "status" then
        return ai:process("status")
    elseif command == "optimize" then
        return ai:process("optimize")
    elseif command == "learn" then
        return ai:process("learn")
    end

    return ai:process(command)
end

return CommandRouter

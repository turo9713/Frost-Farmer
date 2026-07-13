local CommandHandler = {}

function CommandHandler.handle(command)
    return {
        command = command,
        status = "received"
    }
end

return CommandHandler

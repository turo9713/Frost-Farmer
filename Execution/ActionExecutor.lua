local ActionExecutor = {}

function ActionExecutor.execute(action)
    return {
        action = action,
        status = "completed"
    }
end

return ActionExecutor

local ResultHandler = {}

function ResultHandler.handle(result)
    return {
        result = result,
        processed = true
    }
end

return ResultHandler

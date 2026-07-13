local Feedback = {}

function Feedback.evaluate(result)
    return {
        success = result ~= nil,
        result = result
    }
end

return Feedback

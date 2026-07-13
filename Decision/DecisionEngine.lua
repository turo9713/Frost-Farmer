local DecisionEngine = {}

function DecisionEngine.analyze(command)
    return {
        command = command,
        action = "observe",
        confidence = 0.5
    }
end

return DecisionEngine

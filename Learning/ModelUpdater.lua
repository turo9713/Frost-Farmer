local ModelUpdater = {}

function ModelUpdater.update(model, feedback)
    return {
        model = model,
        updated = true,
        feedback = feedback
    }
end

return ModelUpdater

local PromptManager = {}

function PromptManager.build(context, task)
    return {
        context = context,
        task = task
    }
end

return PromptManager

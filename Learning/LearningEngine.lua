local LearningEngine = {}

function LearningEngine.learn(experience)
    return {
        status = "learned",
        experience = experience
    }
end

return LearningEngine

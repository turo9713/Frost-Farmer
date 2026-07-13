local LearningEngine = {}

LearningEngine.Models = {}

function LearningEngine.Learn(data)
    table.insert(LearningEngine.Models, data)
    return true
end

return LearningEngine
-- Adaptive Learning
local AdaptiveLearning = {}

function AdaptiveLearning.update(experience)
    return {learned = true, source = experience}
end

function AdaptiveLearning.score(result)
    return {score = result and 1 or 0}
end

return AdaptiveLearning

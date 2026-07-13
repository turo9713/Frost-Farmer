-- Adaptive Learning
local AdaptiveLearning = {}

function AdaptiveLearning.update(experience)
    return {learned = true, source = experience}
end

return AdaptiveLearning

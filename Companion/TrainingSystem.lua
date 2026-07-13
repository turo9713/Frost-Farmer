local TrainingSystem = {}

function TrainingSystem.Train(companion, points)
    return { companion = companion, progress = points }
end

return TrainingSystem

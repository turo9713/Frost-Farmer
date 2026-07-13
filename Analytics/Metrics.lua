local Metrics = {}

function Metrics:CalculateEfficiency(stats)
    return stats and stats.time > 0 and stats.value / stats.time or 0
end

return Metrics

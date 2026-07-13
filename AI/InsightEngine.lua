local InsightEngine = {}

function InsightEngine:Analyze(metrics)
    return {recommendation = "optimize route", metrics = metrics}
end

return InsightEngine

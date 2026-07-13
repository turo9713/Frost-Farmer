local RiskAnalyzer = {}

function RiskAnalyzer.evaluate(action)
    return {
        action = action,
        risk = "low"
    }
end

return RiskAnalyzer

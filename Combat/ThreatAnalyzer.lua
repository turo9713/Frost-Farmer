local ThreatAnalyzer = {}
function ThreatAnalyzer.Analyze(targets)
    return {risk = 0, threats = targets or {}}
end
return ThreatAnalyzer

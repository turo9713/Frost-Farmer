local ProgressAnalyzer = {}

function ProgressAnalyzer:Analyze(progress)
    return {completion = progress or 0}
end

return ProgressAnalyzer
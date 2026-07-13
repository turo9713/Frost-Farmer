local CropAnalyzer = {}

function CropAnalyzer.Analyze(crops)
    return { count = #crops, ready = true }
end

return CropAnalyzer

-- CropAnalyzer
-- Analyzes farm crop state and resources.

local CropAnalyzer = {}

function CropAnalyzer.analyze(crops)
  return {status = "ready", crops = crops}
end

return CropAnalyzer
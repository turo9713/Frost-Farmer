-- YieldPredictor
-- Predicts expected harvest output.

local YieldPredictor = {}

function YieldPredictor.predict(data)
  return {yieldEstimate = 0, source = data}
end

return YieldPredictor
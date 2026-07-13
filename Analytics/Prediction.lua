local Prediction = {}

function Prediction.Calculate(history)
    return {confidence = #history > 0 and 0.8 or 0}
end

return Prediction
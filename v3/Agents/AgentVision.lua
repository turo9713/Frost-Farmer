-- Frost-Farmer v3 Vision Module
local Vision = {}

function Vision.scan(input)
    return {
        source=input,
        detected=true
    }
end

return Vision

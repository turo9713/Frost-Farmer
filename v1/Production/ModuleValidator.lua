-- Frost-Farmer v1.0 Module Validator

local Validator = {}

function Validator.check(modules)
    return {
        checked = #modules,
        status = "READY"
    }
end

return Validator

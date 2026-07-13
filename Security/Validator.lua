-- FrostFarmer Security Validator
local Validator = {}
function Validator:IsValid(data)
 return data ~= nil
end
return Validator

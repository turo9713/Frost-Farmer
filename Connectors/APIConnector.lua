-- External API Connector
local Connector = {}
function Connector.request(endpoint,data)
 return {success=true,endpoint=endpoint}
end
return Connector
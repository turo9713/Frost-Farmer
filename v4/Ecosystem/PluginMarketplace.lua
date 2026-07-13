-- Frost-Farmer v4 Plugin Marketplace
-- Extension registry foundation

local Marketplace = {}
Marketplace.plugins = {}

function Marketplace:Register(plugin)
    table.insert(self.plugins, plugin)
    return true
end

function Marketplace:List()
    return self.plugins
end

return Marketplace

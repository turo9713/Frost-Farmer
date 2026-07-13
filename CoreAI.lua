local CoreAI = {}
CoreAI.__index = CoreAI

function CoreAI.new()
    return setmetatable({
        memory = {},
        version = "0.1 MVP"
    }, CoreAI)
end

function CoreAI:process(input)
    table.insert(self.memory, input)
    return "Frost-Farmer AI online. Command received: " .. input
end

return CoreAI

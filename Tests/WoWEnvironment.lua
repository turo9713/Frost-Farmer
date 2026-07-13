local Environment = {}

Environment.MockPlayer = {
    level = 1,
    inventory = {}
}

Environment.MockEvents = {}

function Environment.Check()
    return true
end

function Environment.LoadMockData()
    return Environment.MockPlayer
end

return Environment

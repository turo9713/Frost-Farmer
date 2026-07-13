local DataProcessor = {}

function DataProcessor.Process(data)
    data.processed = true
    return data
end

return DataProcessor
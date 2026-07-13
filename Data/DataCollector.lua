local DataCollector = {}

function DataCollector.Collect(event)
    return {event = event, timestamp = os.time()}
end

return DataCollector
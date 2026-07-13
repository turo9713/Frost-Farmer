local EventBus = {}

EventBus.listeners = {}

function EventBus.subscribe(event, callback)
    EventBus.listeners[event] = EventBus.listeners[event] or {}
    table.insert(EventBus.listeners[event], callback)
end

function EventBus.emit(event, data)
    if EventBus.listeners[event] then
        for _, callback in ipairs(EventBus.listeners[event]) do
            callback(data)
        end
    end
end

return EventBus

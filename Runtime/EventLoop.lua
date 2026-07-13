local EventLoop = {}

EventLoop.running = false
EventLoop.events = {}

function EventLoop.add(event)
    table.insert(EventLoop.events, event)
end

function EventLoop.start()
    EventLoop.running = true
    return "Event loop active"
end

function EventLoop.stop()
    EventLoop.running = false
end

return EventLoop

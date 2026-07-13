local State = {
    active = false,
    currentTask = nil,
    modules = {}
}

function State.setActive(value)
    State.active = value
end

function State.addModule(name)
    State.modules[name] = true
end

return State

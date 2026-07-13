local Container = {}
Container.services = {}

function Container.Register(name, service)
    Container.services[name] = service
end

function Container.Get(name)
    return Container.services[name]
end

return Container

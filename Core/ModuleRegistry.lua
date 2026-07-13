local Registry = {}

Registry.Modules = {}

function Registry:Register(name, module)
    self.Modules[name] = module
end

function Registry:Get(name)
    return self.Modules[name]
end

return Registry

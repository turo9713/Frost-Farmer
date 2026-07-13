local ModuleLoader = {}

ModuleLoader.modules = {}

function ModuleLoader.register(name, module)
    ModuleLoader.modules[name] = module
end

function ModuleLoader.get(name)
    return ModuleLoader.modules[name]
end

return ModuleLoader

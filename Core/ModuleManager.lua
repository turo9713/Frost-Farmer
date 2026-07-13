local ADDON, FF = ...

FF.Modules = FF.Modules or {}

function FF:RegisterModule(name, module)
    self.Modules[name] = module
end

function FF:GetModule(name)
    return self.Modules[name]
end

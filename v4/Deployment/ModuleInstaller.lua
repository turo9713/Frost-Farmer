-- Frost-Farmer v4 Module Installer

local Installer = {}

function Installer.install(module)
    return {
        module = module,
        installed = true
    }
end

return Installer

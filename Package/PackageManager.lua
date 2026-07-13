-- Package Manager
local PackageManager = {}

function PackageManager.install(name)
    return {installed = name}
end

return PackageManager

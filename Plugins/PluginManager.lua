local PluginManager = {}

PluginManager.plugins = {}

function PluginManager.register(name, plugin)
    PluginManager.plugins[name] = plugin
end

function PluginManager.list()
    return PluginManager.plugins
end

return PluginManager

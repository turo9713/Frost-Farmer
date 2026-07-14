local addonName, FF = ...

_G.FrostFarmer = FF
FF.name = addonName
FF.version = "4.0.0"
FF.modules = {}

local defaults = {
    schema = 1,
    settings = {
        autoStart = false,
        historyLimit = 20,
    },
    session = nil,
    history = {},
}

local function copyDefaults(source, target)
    for key, value in pairs(source) do
        if type(value) == "table" then
            if type(target[key]) ~= "table" then
                target[key] = {}
            end
            copyDefaults(value, target[key])
        elseif target[key] == nil then
            target[key] = value
        end
    end
end

function FF:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff8ee8ffFrost Farmer:|r " .. tostring(message))
end

function FF:FormatMoney(copper)
    copper = math.floor(tonumber(copper) or 0)
    local gold = math.floor(copper / 10000)
    local silver = math.floor((copper % 10000) / 100)
    local bronze = copper % 100
    return string.format("%dg %02ds %02dc", gold, silver, bronze)
end

function FF:FormatDuration(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    return string.format("%02d:%02d:%02d", math.floor(seconds / 3600), math.floor(seconds / 60) % 60, seconds % 60)
end

function FF:RegisterModule(name, module)
    assert(type(name) == "string" and type(module) == "table", "Invalid Frost Farmer module")
    self.modules[name] = module
end

function FF:Notify(event, ...)
    for _, module in pairs(self.modules) do
        local handler = module[event]
        if type(handler) == "function" then
            local ok, message = pcall(handler, module, ...)
            if not ok then
                self:Print("Module error: " .. tostring(message))
            end
        end
    end
end

function FF:Initialize()
    FrostFarmerDB = FrostFarmerDB or {}
    copyDefaults(defaults, FrostFarmerDB)
    self.db = FrostFarmerDB
    self:Notify("OnInitialize")
    self:Print("v" .. self.version .. " loaded. Type /ff to open.")
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local loaded = ...
        if loaded ~= addonName then return end
        eventFrame:UnregisterEvent("ADDON_LOADED")
        FF:Initialize()
    else
        FF:Notify(event, ...)
    end
end)

function FF:RegisterEvent(event)
    eventFrame:RegisterEvent(event)
end

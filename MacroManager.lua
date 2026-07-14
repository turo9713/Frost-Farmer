local _, FF = ...

local MacroManager = {
    definitions = {
        { name = "FF: Panel", icon = 134400, body = "/ff" },
        { name = "FF: Session", icon = 132149, body = "/ff session" },
        { name = "FF: Point", icon = 237381, body = "/ff point" },
        { name = "FF: Skills", icon = 135932, body = "/ff bar" },
    },
}

function MacroManager:Install()
    if not FF.db.settings.autoCreateMacros then return end
    if InCombatLockdown() then
        self.pending = true
        return
    end
    self.pending = false
    local macroNames = {}
    local created = 0
    for _, definition in ipairs(self.definitions) do
        local index = GetMacroIndexByName(definition.name)
        if index == 0 then
            index = CreateMacro(definition.name, definition.icon, definition.body, true)
            if index then created = created + 1 end
        end
        if index and index > 0 then macroNames[#macroNames + 1] = definition.name end
    end
    if #macroNames < #self.definitions then
        FF:Print("Not all helper macros could be created; character macro slots may be full.")
    elseif created > 0 then
        FF:Print(created .. " helper macros created. Open /macro to view them.")
    end
    if FF.ActionBar then FF.ActionBar:InstallDefaultMacros(macroNames) end
end

function MacroManager:OnInitialize()
    FF:RegisterEvent("PLAYER_LOGIN")
    FF:RegisterEvent("PLAYER_REGEN_ENABLED")
end

function MacroManager:PLAYER_LOGIN()
    C_Timer.After(1, function() self:Install() end)
end

function MacroManager:PLAYER_REGEN_ENABLED()
    if self.pending then self:Install() end
end

FF.MacroManager = MacroManager
FF:RegisterModule("MacroManager", MacroManager)

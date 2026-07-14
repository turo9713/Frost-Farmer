local _, FF = ...

local ActionBar = {
    buttonCount = 12,
    buttons = {},
}

local function profileKey()
    local specialization = GetSpecialization and GetSpecialization()
    local specializationID = specialization and GetSpecializationInfo(specialization)
    return tostring(specializationID or "default")
end

function ActionBar:GetProfile()
    local key = profileKey()
    FF.db.actionBar.profiles[key] = FF.db.actionBar.profiles[key] or { slots = {} }
    return FF.db.actionBar.profiles[key]
end

function ActionBar:GetCursorAction()
    local cursorType, id, subType = GetCursorInfo()
    if cursorType == "spell" then
        return { kind = "spell", id = id }
    elseif cursorType == "item" then
        return { kind = "item", id = id }
    elseif cursorType == "macro" then
        local name = GetMacroInfo(id)
        return { kind = "macro", id = name or id }
    elseif cursorType == "action" then
        local actionType, actionID = GetActionInfo(id)
        if actionType == "spell" or actionType == "item" or actionType == "macro" then
            return { kind = actionType, id = actionID }
        end
    end
    return nil, subType
end

function ActionBar:GetDisplay(data)
    if not data then return nil, nil end
    if data.kind == "spell" then
        local info = C_Spell.GetSpellInfo(data.id)
        return info and info.name, info and info.iconID
    elseif data.kind == "item" and C_Container.GetItemCooldown then
        local name = C_Item.GetItemNameByID(data.id)
        return name or ("Item " .. data.id), C_Item.GetItemIconByID(data.id)
    elseif data.kind == "macro" then
        local name, icon = GetMacroInfo(data.id)
        return name, icon
    end
    return nil, nil
end

function ActionBar:ApplySlot(index)
    if InCombatLockdown() then return end
    local button = self.buttons[index]
    if not button then return end
    local data = self:GetProfile().slots[index]
    button:SetAttribute("type1", nil)
    button:SetAttribute("spell1", nil)
    button:SetAttribute("item1", nil)
    button:SetAttribute("macro1", nil)
    if data then
        button:SetAttribute("type1", data.kind)
        if data.kind == "spell" then
            button:SetAttribute("spell1", data.id)
        elseif data.kind == "item" then
            button:SetAttribute("item1", "item:" .. data.id)
        elseif data.kind == "macro" then
            button:SetAttribute("macro1", data.id)
        end
    end
    local _, icon = self:GetDisplay(data)
    button.icon:SetTexture(icon or "Interface/Buttons/UI-Quickslot2")
    button.icon:SetDesaturated(not data)
    self:UpdateHotkey(index)
    self:UpdateCooldown(index)
end

function ActionBar:SetSlot(index, data)
    if InCombatLockdown() then
        FF:Print("The skill bar cannot be edited during combat.")
        return
    end
    self:GetProfile().slots[index] = data
    self:ApplySlot(index)
end

function ActionBar:InstallDefaultMacros(indices)
    if FF.db.actionBar.defaultMacrosAssigned or not indices then return end
    local profile = self:GetProfile()
    for slot, macroIndex in ipairs(indices) do
        if slot <= self.buttonCount and not profile.slots[slot] then
            profile.slots[slot] = { kind = "macro", id = macroIndex }
        end
    end
    FF.db.actionBar.defaultMacrosAssigned = true
    self:ApplyProfile()
end

function ActionBar:ReceiveDrag(index)
    if InCombatLockdown() then return end
    local data = self:GetCursorAction()
    if not data then
        FF:Print("Drag a spell, item, macro, or action-bar ability here.")
        return
    end
    self:SetSlot(index, data)
    ClearCursor()
end

function ActionBar:Pickup(index)
    if InCombatLockdown() then return end
    local data = self:GetProfile().slots[index]
    if not data then return end
    if data.kind == "spell" and C_Spell.PickupSpell then
        C_Spell.PickupSpell(data.id)
    elseif data.kind == "item" and C_Item.PickupItem then
        C_Item.PickupItem(data.id)
    elseif data.kind == "macro" then
        PickupMacro(data.id)
    end
end

function ActionBar:UpdateCooldown(index)
    local button = self.buttons[index]
    local data = self:GetProfile().slots[index]
    if not button or not data then
        if button then button.cooldown:Clear() end
        return
    end
    if data.kind == "spell" then
        local cooldown = C_Spell.GetSpellCooldown(data.id)
        if cooldown then
            CooldownFrame_Set(button.cooldown, cooldown.startTime, cooldown.duration, cooldown.isEnabled)
        end
    elseif data.kind == "item" then
        local startTime, duration, enable = C_Container.GetItemCooldown(data.id)
        CooldownFrame_Set(button.cooldown, startTime or 0, duration or 0, enable or 0)
    else
        button.cooldown:Clear()
    end
end

function ActionBar:UpdateAllCooldowns()
    for index = 1, self.buttonCount do self:UpdateCooldown(index) end
end

function ActionBar:UpdateHotkey(index)
    local button = self.buttons[index]
    if not button then return end
    local key = GetBindingKey("CLICK " .. button:GetName() .. ":LeftButton")
    button.hotkey:SetText(key or index)
end

function ActionBar:Bind(index, key)
    if InCombatLockdown() then
        FF:Print("Key bindings cannot be changed during combat.")
        return
    end
    local button = self.buttons[index]
    if not button or not key or key == "" then
        FF:Print("Usage: /ff bind 1 SHIFT-F")
        return
    end
    if SetBindingClick(key:upper(), button:GetName(), "LeftButton") then
        SaveBindings(GetCurrentBindingSet())
        self:UpdateHotkey(index)
        FF:Print("Button " .. index .. " bound to " .. key:upper() .. ".")
    else
        FF:Print("WoW rejected that key binding.")
    end
end

function ActionBar:Unbind(index)
    if InCombatLockdown() then return end
    local button = self.buttons[index]
    if not button then return end
    local command = "CLICK " .. button:GetName() .. ":LeftButton"
    local key1, key2 = GetBindingKey(command)
    if key1 then SetBinding(key1) end
    if key2 then SetBinding(key2) end
    SaveBindings(GetCurrentBindingSet())
    self:UpdateHotkey(index)
    FF:Print("Bindings removed from button " .. index .. ".")
end

function ActionBar:SetLocked(locked)
    FF.db.actionBar.locked = locked
    self.frame:EnableMouse(not locked)
    self.frame.background:SetShown(not locked)
    FF:Print(locked and "Skill bar locked." or "Skill bar unlocked; drag its background to move it.")
end

function ActionBar:SavePosition()
    local point, _, _, x, y = self.frame:GetPoint(1)
    FF.db.actionBar.point = { point, math.floor(x + 0.5), math.floor(y + 0.5) }
end

function ActionBar:CreateButton(index)
    local button = CreateFrame("Button", "FrostFarmerActionButton" .. index, self.frame, "SecureActionButtonTemplate")
    button:SetSize(38, 38)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetPoint("LEFT", (index - 1) * 41 + 3, 0)

    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints()
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    button.icon = icon

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface/Buttons/UI-Quickslot")
    border:SetAllPoints()

    local hotkey = button:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    hotkey:SetPoint("TOPRIGHT", -2, -2)
    button.hotkey = hotkey

    local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    cooldown:SetAllPoints()
    button.cooldown = cooldown

    button:SetScript("OnReceiveDrag", function() self:ReceiveDrag(index) end)
    button:SetScript("OnDragStart", function() self:Pickup(index) end)
    button:SetScript("OnMouseUp", function(_, mouseButton)
        if mouseButton == "RightButton" and IsShiftKeyDown() and not FF.db.actionBar.locked then
            self:SetSlot(index, nil)
        end
    end)
    button:SetScript("OnEnter", function(owner)
        GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
        local data = self:GetProfile().slots[index]
        if data and data.kind == "spell" then GameTooltip:SetSpellByID(data.id)
        elseif data and data.kind == "item" then GameTooltip:SetItemByID(data.id)
        elseif data and data.kind == "macro" then GameTooltip:SetText((GetMacroInfo(data.id)) or "Macro")
        else GameTooltip:SetText("Drop a spell, item, or macro here") end
        GameTooltip:AddLine("Shift-right-click while unlocked to clear.", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", GameTooltip_Hide)
    self.buttons[index] = button
end

function ActionBar:Create()
    local frame = CreateFrame("Frame", "FrostFarmerActionBar", UIParent, "BackdropTemplate")
    frame:SetSize(self.buttonCount * 41 + 3, 44)
    local point = FF.db.actionBar.point
    frame:SetPoint(point[1], UIParent, point[1], point[2], point[3])
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(owner)
        if not FF.db.actionBar.locked and not InCombatLockdown() then owner:StartMoving() end
    end)
    frame:SetScript("OnDragStop", function(owner)
        owner:StopMovingOrSizing()
        self:SavePosition()
    end)
    frame:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 10 })
    frame:SetBackdropColor(0.03, 0.08, 0.10, 0.85)
    frame.background = frame:CreateTexture(nil, "BACKGROUND", nil, -1)
    frame.background:SetAllPoints()
    frame.background:SetColorTexture(0.2, 0.8, 1, 0.12)
    self.frame = frame
    for index = 1, self.buttonCount do self:CreateButton(index) end
    self:SetLocked(FF.db.actionBar.locked)
    frame:SetShown(FF.db.actionBar.enabled)
    self:ApplyProfile()
end

function ActionBar:ApplyProfile()
    if InCombatLockdown() then
        self.pendingProfile = true
        return
    end
    self.pendingProfile = false
    for index = 1, self.buttonCount do self:ApplySlot(index) end
end

function ActionBar:Toggle()
    FF.db.actionBar.enabled = not FF.db.actionBar.enabled
    self.frame:SetShown(FF.db.actionBar.enabled)
end

function ActionBar:OnInitialize()
    self:Create()
    FF:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    FF:RegisterEvent("PLAYER_REGEN_ENABLED")
    FF:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    FF:RegisterEvent("BAG_UPDATE_COOLDOWN")
end

function ActionBar:PLAYER_SPECIALIZATION_CHANGED(unit)
    if not unit or unit == "player" then self:ApplyProfile() end
end

function ActionBar:PLAYER_REGEN_ENABLED()
    if self.pendingProfile then self:ApplyProfile() end
end

function ActionBar:SPELL_UPDATE_COOLDOWN() self:UpdateAllCooldowns() end
function ActionBar:BAG_UPDATE_COOLDOWN() self:UpdateAllCooldowns() end

FF.ActionBar = ActionBar
FF:RegisterModule("ActionBar", ActionBar)

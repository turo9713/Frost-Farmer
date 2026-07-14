local _, FF = ...

local UI = {}

local function createButton(parent, text, width)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width or 100, 24)
    button:SetText(text)
    return button
end

function UI:Create()
    if self.frame then return end
    local frame = CreateFrame("Frame", "FrostFarmerMainFrame", UIParent, "BackdropTemplate")
    frame:SetSize(520, 470)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)
    frame:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 14, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
    frame:SetBackdropColor(0.03, 0.08, 0.10, 0.96)
    frame:Hide()

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 18, -16)
    title:SetText("Frost Farmer |cff8ee8ff4.0|r")

    local close = createButton(frame, "X", 28)
    close:SetPoint("TOPRIGHT", -12, -12)
    close:SetScript("OnClick", function() frame:Hide() end)

    local start = createButton(frame, "Start", 92)
    start:SetPoint("TOPLEFT", 18, -52)
    start:SetScript("OnClick", function()
        if FF.Tracker:IsRunning() then FF.Tracker:Stop() else FF.Tracker:Start() end
    end)
    self.startButton = start

    local point = createButton(frame, "Add point", 92)
    point:SetPoint("LEFT", start, "RIGHT", 8, 0)
    point:SetScript("OnClick", function() FF.Tracker:AddPoint() end)

    local reset = createButton(frame, "Reset", 92)
    reset:SetPoint("LEFT", point, "RIGHT", 8, 0)
    reset:SetScript("OnClick", function() FF.Tracker:Reset() end)

    local skills = createButton(frame, "Skill bar", 92)
    skills:SetPoint("LEFT", reset, "RIGHT", 8, 0)
    skills:SetScript("OnClick", function() FF.ActionBar:Toggle() end)

    local summary = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    summary:SetPoint("TOPLEFT", 18, -90)
    summary:SetPoint("RIGHT", -18, 0)
    summary:SetJustifyH("LEFT")
    summary:SetJustifyV("TOP")
    self.summary = summary

    local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 18, -160)
    scroll:SetPoint("BOTTOMRIGHT", -34, 18)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(460, 1)
    scroll:SetScrollChild(content)
    local details = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    details:SetPoint("TOPLEFT")
    details:SetWidth(450)
    details:SetJustifyH("LEFT")
    details:SetJustifyV("TOP")
    self.content = content
    self.details = details
    self.frame = frame
end

function UI:Refresh()
    if not self.frame then return end
    local session = FF.Tracker:GetSession()
    self.startButton:SetText(FF.Tracker:IsRunning() and "Stop & save" or "Start")
    if not session then
        self.summary:SetText("No active farming session.\nUse Start to begin tracking bags, gold and route points.")
        local history = FF.db.history[1]
        if history then
            self.details:SetText("|cff8ee8ffLast session|r\nZone: " .. (history.zone or UNKNOWN) .. "\nDuration: " .. FF:FormatDuration(FF.Tracker:GetElapsed(history)) .. "\nValue: " .. FF:FormatMoney(history.money + history.vendorValue) .. "\nItems: " .. history.itemCount)
        else
            self.details:SetText("Your completed sessions will appear here.")
        end
    else
        self.summary:SetText(string.format("|cff7fffc3%s|r  %s\nZone: %s | Gold: %s | Vendor value: %s | Items: %d | Points: %d", session.running and "RUNNING" or "STOPPED", FF:FormatDuration(FF.Tracker:GetElapsed(session)), session.zone or UNKNOWN, FF:FormatMoney(session.money), FF:FormatMoney(session.vendorValue), session.itemCount, #session.points))
        local lines = { "|cff8ee8ffLoot|r" }
        local items = {}
        for _, item in pairs(session.items) do items[#items + 1] = item end
        table.sort(items, function(a, b) return a.value > b.value end)
        for _, item in ipairs(items) do
            lines[#lines + 1] = string.format("%s x%d — %s", item.link or item.name, item.count, FF:FormatMoney(item.value))
        end
        if #items == 0 then lines[#lines + 1] = "No new items detected." end
        lines[#lines + 1] = "\n|cff8ee8ffRecommendations|r"
        for _, recommendation in ipairs(FF.Planner:GetRecommendations(session)) do
            lines[#lines + 1] = "• " .. recommendation
        end
        self.details:SetText(table.concat(lines, "\n"))
    end
    self.content:SetHeight(math.max(280, self.details:GetStringHeight() + 20))
end

function UI:Toggle()
    self:Create()
    if self.frame:IsShown() then self.frame:Hide() else self:Refresh(); self.frame:Show() end
end

function UI:OnInitialize()
    self:Create()
    self.ticker = C_Timer.NewTicker(1, function()
        if self.frame:IsShown() then self:Refresh() end
    end)
end

function UI:OnSessionChanged()
    self:Refresh()
end

FF.UI = UI
FF:RegisterModule("UI", UI)

local _, FF = ...

local Tracker = {
    bagSnapshot = {},
}

local function now()
    return GetServerTime and GetServerTime() or time()
end

local function bagIds()
    local ids = {}
    for bag = 0, (NUM_BAG_SLOTS or 4) do
        ids[#ids + 1] = bag
    end
    local reagentBag = Enum and Enum.BagIndex and Enum.BagIndex.ReagentBag
    if reagentBag and reagentBag > (NUM_BAG_SLOTS or 4) then
        ids[#ids + 1] = reagentBag
    end
    return ids
end

function Tracker:ReadBags()
    local snapshot = {}
    if not C_Container then return snapshot end
    for _, bag in ipairs(bagIds()) do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.itemID then
                snapshot[info.itemID] = (snapshot[info.itemID] or 0) + (info.stackCount or 1)
            end
        end
    end
    return snapshot
end

function Tracker:GetSession()
    return FF.db and FF.db.session
end

function Tracker:IsRunning()
    local session = self:GetSession()
    return session and session.running == true
end

function Tracker:Start()
    if self:IsRunning() then
        FF:Print("A farming session is already running.")
        return
    end
    FF.db.session = {
        running = true,
        startedAt = now(),
        startMoney = GetMoney(),
        money = 0,
        vendorValue = 0,
        itemCount = 0,
        items = {},
        points = {},
        zone = GetRealZoneText() or UNKNOWN,
    }
    self.bagSnapshot = self:ReadBags()
    FF:Notify("OnSessionChanged")
    FF:Print("Farming session started in " .. FF.db.session.zone .. ".")
end

function Tracker:Stop()
    local session = self:GetSession()
    if not self:IsRunning() then
        FF:Print("No farming session is running.")
        return
    end
    self:UpdateMoney()
    session.running = false
    session.endedAt = now()
    table.insert(FF.db.history, 1, session)
    while #FF.db.history > FF.db.settings.historyLimit do
        table.remove(FF.db.history)
    end
    FF.db.session = nil
    FF:Notify("OnSessionChanged")
    FF:Print("Session saved: " .. FF:FormatMoney(session.money) .. ", " .. session.itemCount .. " items.")
end

function Tracker:Reset()
    FF.db.session = nil
    self.bagSnapshot = self:ReadBags()
    FF:Notify("OnSessionChanged")
    FF:Print("Current session reset.")
end

function Tracker:UpdateMoney()
    local session = self:GetSession()
    if not self:IsRunning() then return end
    session.money = GetMoney() - session.startMoney
end

function Tracker:ScanLoot()
    local current = self:ReadBags()
    local session = self:GetSession()
    if self:IsRunning() then
        for itemID, count in pairs(current) do
            local gained = count - (self.bagSnapshot[itemID] or 0)
            if gained > 0 then
                local name, link, quality, _, _, _, _, _, _, icon, sellPrice = C_Item.GetItemInfo(itemID)
                local item = session.items[itemID]
                if not item then
                    item = { id = itemID, name = name or ("Item " .. itemID), link = link, quality = quality or 1, icon = icon, count = 0, value = 0 }
                    session.items[itemID] = item
                end
                item.count = item.count + gained
                item.value = item.value + ((sellPrice or 0) * gained)
                session.itemCount = session.itemCount + gained
                session.vendorValue = session.vendorValue + ((sellPrice or 0) * gained)
            end
        end
        FF:Notify("OnSessionChanged")
    end
    self.bagSnapshot = current
end

function Tracker:AddPoint()
    if not self:IsRunning() then
        FF:Print("Start a session before recording route points.")
        return
    end
    local mapID = C_Map.GetBestMapForUnit("player")
    local position = mapID and C_Map.GetPlayerMapPosition(mapID, "player")
    if not position then
        FF:Print("Player position is unavailable here.")
        return
    end
    local x, y = position:GetXY()
    local point = { mapID = mapID, x = x, y = y, zone = GetRealZoneText() or UNKNOWN, at = now() }
    table.insert(FF.db.session.points, point)
    FF:Notify("OnSessionChanged")
    FF:Print(string.format("Route point added: %.1f, %.1f.", x * 100, y * 100))
end

function Tracker:GetElapsed(session)
    if not session then return 0 end
    return math.max(0, (session.endedAt or now()) - session.startedAt)
end

function Tracker:GetGoldPerHour(session)
    local elapsed = self:GetElapsed(session)
    if elapsed <= 0 then return 0 end
    return math.floor((session.money + session.vendorValue) * 3600 / elapsed)
end

function Tracker:OnInitialize()
    FF:RegisterEvent("PLAYER_LOGIN")
    FF:RegisterEvent("PLAYER_MONEY")
    FF:RegisterEvent("BAG_UPDATE_DELAYED")
    self.bagSnapshot = self:ReadBags()
end

function Tracker:PLAYER_LOGIN()
    self.bagSnapshot = self:ReadBags()
    if FF.db.settings.autoStart and not self:IsRunning() then self:Start() end
end

function Tracker:PLAYER_MONEY()
    self:UpdateMoney()
    FF:Notify("OnSessionChanged")
end

function Tracker:BAG_UPDATE_DELAYED()
    self:ScanLoot()
end

FF.Tracker = Tracker
FF:RegisterModule("Tracker", Tracker)

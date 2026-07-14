local _, FF = ...

SLASH_FROSTFARMER1 = "/frostfarmer"
SLASH_FROSTFARMER2 = "/ff"

SlashCmdList.FROSTFARMER = function(message)
    local input = strtrim(message or "")
    local command, argument1, argument2 = input:match("^(%S*)%s*(%S*)%s*(%S*)$")
    command = (command or ""):lower()
    if command == "start" then
        FF.Tracker:Start()
    elseif command == "stop" then
        FF.Tracker:Stop()
    elseif command == "point" then
        FF.Tracker:AddPoint()
    elseif command == "reset" then
        FF.Tracker:Reset()
    elseif command == "session" then
        if FF.Tracker:IsRunning() then FF.Tracker:Stop() else FF.Tracker:Start() end
    elseif command == "bar" then
        FF.ActionBar:Toggle()
    elseif command == "unlock" then
        FF.ActionBar:SetLocked(false)
    elseif command == "lock" then
        FF.ActionBar:SetLocked(true)
    elseif command == "bind" then
        FF.ActionBar:Bind(tonumber(argument1), argument2)
    elseif command == "unbind" then
        FF.ActionBar:Unbind(tonumber(argument1))
    elseif command == "status" then
        local session = FF.Tracker:GetSession()
        if session then
            FF:Print(string.format("%s, %d items, %s total value.", FF:FormatDuration(FF.Tracker:GetElapsed(session)), session.itemCount, FF:FormatMoney(session.money + session.vendorValue)))
        else
            FF:Print("No active session.")
        end
    elseif command == "help" then
        FF:Print("/ff — panel; session; start; stop; point; status; reset; bar; unlock; lock; bind 1 SHIFT-F; unbind 1")
    else
        FF.UI:Toggle()
    end
end

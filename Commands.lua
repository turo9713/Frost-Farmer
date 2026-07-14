local _, FF = ...

SLASH_FROSTFARMER1 = "/frostfarmer"
SLASH_FROSTFARMER2 = "/ff"

SlashCmdList.FROSTFARMER = function(message)
    local command = strtrim(message or ""):lower()
    if command == "start" then
        FF.Tracker:Start()
    elseif command == "stop" then
        FF.Tracker:Stop()
    elseif command == "point" then
        FF.Tracker:AddPoint()
    elseif command == "reset" then
        FF.Tracker:Reset()
    elseif command == "status" then
        local session = FF.Tracker:GetSession()
        if session then
            FF:Print(string.format("%s, %d items, %s total value.", FF:FormatDuration(FF.Tracker:GetElapsed(session)), session.itemCount, FF:FormatMoney(session.money + session.vendorValue)))
        else
            FF:Print("No active session.")
        end
    elseif command == "help" then
        FF:Print("/ff — panel; /ff start; /ff stop; /ff point; /ff status; /ff reset")
    else
        FF.UI:Toggle()
    end
end

local _, FF = ...

local Planner = {}

function Planner:GetRecommendations(session)
    if not session then
        return { "Start a session, gather resources, and Frost Farmer will analyze the run." }
    end
    local recommendations = {}
    local elapsed = FF.Tracker:GetElapsed(session)
    if elapsed < 300 then
        recommendations[#recommendations + 1] = "Run at least 5 minutes for a useful gold-per-hour estimate."
    end
    if session.itemCount == 0 then
        recommendations[#recommendations + 1] = "No new bag items detected yet. Loot or gather an item to track it."
    end
    if #session.points < 3 then
        recommendations[#recommendations + 1] = "Record at least 3 route points to document this farming loop."
    else
        recommendations[#recommendations + 1] = "Route has " .. #session.points .. " points and can be repeated next session."
    end
    if FF.Tracker:GetGoldPerHour(session) > 0 then
        recommendations[#recommendations + 1] = "Estimated value per hour: " .. FF:FormatMoney(FF.Tracker:GetGoldPerHour(session)) .. "."
    end
    return recommendations
end

FF.Planner = Planner
FF:RegisterModule("Planner", Planner)

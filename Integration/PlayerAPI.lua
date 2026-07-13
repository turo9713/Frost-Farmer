local PlayerAPI = {}

function PlayerAPI:GetProfile()
    return {
        name = UnitName and UnitName('player') or 'Unknown'
    }
end

return PlayerAPI
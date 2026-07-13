local TeamManager = {}

function TeamManager.CreateTeam(name)
    return { Name = name, Members = {} }
end

return TeamManager

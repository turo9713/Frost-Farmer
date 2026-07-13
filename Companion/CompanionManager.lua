local CompanionManager = {}

function CompanionManager.GetStatus(companion)
    return { name = companion, active = true }
end

return CompanionManager

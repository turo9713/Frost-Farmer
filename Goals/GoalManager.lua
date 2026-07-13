-- Frost-Farmer AI Goal Manager
local GoalManager = {}

GoalManager.goals = {}

function GoalManager:addGoal(name, priority)
    local goal = {
        name = name,
        priority = priority or "normal",
        status = "pending"
    }
    table.insert(self.goals, goal)
    return goal
end

function GoalManager:listGoals()
    return self.goals
end

return GoalManager

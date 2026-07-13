-- Frost-Farmer v4 Goal Management

local GoalManager = {}
GoalManager.goals = {}

function GoalManager:Add(goal)
    table.insert(self.goals, goal)
end

function GoalManager:GetAll()
    return self.goals
end

return GoalManager

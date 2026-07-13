-- Frost-Farmer v2 Autonomous Planner
local Planner = {}
function Planner.createPlan(goal)
 return {goal=goal,status='planned'}
end
return Planner

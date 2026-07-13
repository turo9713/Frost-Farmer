-- Task planner module
local TaskPlanner = {}
function TaskPlanner.plan(task)
  return {task = task, status = "planned"}
end
return TaskPlanner
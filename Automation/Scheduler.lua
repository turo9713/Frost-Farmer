-- Scheduler module
local Scheduler = {}
function Scheduler.queue(action)
  return {action = action, scheduled = true}
end
return Scheduler
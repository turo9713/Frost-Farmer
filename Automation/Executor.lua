-- Executor module
local Executor = {}
function Executor.run(action)
  return {executed = action}
end
return Executor
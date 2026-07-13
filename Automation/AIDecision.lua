-- Full Automation Loop: AI decision input
local AIDecision = {}
function AIDecision.evaluate(context)
  return context.nextAction or "idle"
end
return AIDecision
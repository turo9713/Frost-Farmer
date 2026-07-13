-- Frost-Farmer AI Scheduler
local Scheduler = {}

function Scheduler:run(task)
    if task then
        return {
            task = task,
            status = "running"
        }
    end
    return nil
end

return Scheduler

local Scheduler = {}

function Scheduler.queue(task)
    return {task = task, state = "queued"}
end

return Scheduler

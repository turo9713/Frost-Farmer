-- Frost-Farmer AI Task Queue
local TaskQueue = {}

TaskQueue.tasks = {}

function TaskQueue:add(task)
    table.insert(self.tasks, task)
end

function TaskQueue:next()
    return table.remove(self.tasks, 1)
end

return TaskQueue

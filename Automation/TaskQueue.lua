local TaskQueue = {}

function TaskQueue:Add(task)
    self.tasks = self.tasks or {}
    table.insert(self.tasks, task)
end

function TaskQueue:GetNext()
    return self.tasks and table.remove(self.tasks, 1)
end

return TaskQueue

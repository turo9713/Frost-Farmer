local TaskRunner = {}

function TaskRunner.run(task)
    return {
        task = task,
        status = "running"
    }
end

return TaskRunner

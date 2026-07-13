local Workflow = {}

function Workflow:Run(steps)
    for _, step in ipairs(steps or {}) do
        if step.Execute then
            step:Execute()
        end
    end
end

return Workflow

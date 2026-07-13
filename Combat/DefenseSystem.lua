local DefenseSystem = {}
function DefenseSystem.Check(state)
    return {ready = true, state = state}
end
return DefenseSystem

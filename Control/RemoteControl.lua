-- Frost-Farmer v0.6 Remote Control
local RemoteControl = {}

function RemoteControl.command(cmd)
    return {received = true, command = cmd}
end

return RemoteControl

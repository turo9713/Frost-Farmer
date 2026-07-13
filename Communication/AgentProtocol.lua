-- Agent Communication Protocol
local Protocol = {}

function Protocol.send(from, to, message)
    return {from = from, to = to, message = message}
end

return Protocol
-- Frost-Farmer v3 Voice Assistant
local VoiceAssistant = {}

function VoiceAssistant.process(command)
    return {
        status = "received",
        command = command
    }
end

return VoiceAssistant

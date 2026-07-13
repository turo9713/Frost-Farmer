local CommandRouter = require("Interface.CommandRouter")
local CoreAI = require("Core.CoreAI")

local ai = CoreAI.new()

print(CommandRouter.route("status", ai))
print(CommandRouter.route("optimize", ai))
print(CommandRouter.route("learn", ai))

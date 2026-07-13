local Core = require("Core.Main")
local Reporter = require("Prototype.StatusReporter")

Core.start()
return Reporter.status()

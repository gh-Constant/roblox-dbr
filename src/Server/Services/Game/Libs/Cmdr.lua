local Cmdr = require("@Packages/cmdr")
local CommandsFolder = game.ServerScriptService.Server.Commands.Game

local function Start()
    Cmdr:RegisterCommandsIn(CommandsFolder)
end

Start()
return nil

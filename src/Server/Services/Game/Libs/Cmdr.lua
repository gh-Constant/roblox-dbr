local Cmdr = require("@Packages/cmdr")
local CommandsFolder = game.ServerScriptService.Server.Game.Commands

local function Start()
    Cmdr:RegisterCommandsIn(CommandsFolder)
end

Start()
return nil

-- Game Runtime
local Config = require("@Common/Config")

if not game.PlaceId == Config.PlaceIds.Game then
	script.Disabled = true
	script.Name = "GameRuntime (DISABLED - NOT GAME PLACE)"
	return
end

require("@GameServices/TestService")
require("@GameServices/Player/Interactables")
require("@GameServices/Libs/Cmdr")
require("@GameServices/Player/MovementRestrictions")

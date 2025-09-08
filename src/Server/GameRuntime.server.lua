-- Game Runtime
local Config = require("@Common/Config")

if game.PlaceId ~= Config.PlaceIds.Game then
	script.Disabled = true
	script.Name = "GameRuntime (DISABLED - NOT GAME PLACE)"
	return
end

-- Initialize game services
require("@GameServices/GameManager")
require("@GameServices/Lobby/ReadyService")
require("@GameServices/Player/Interactables")
require("@GameServices/Libs/Cmdr")
require("@GameServices/Player/MovementRestrictions")
print("[GameRuntime] All services initialized successfully")

-- Game Runtime
local Config = require("@Common/Config")

if game.PlaceId ~= Config.PlaceIds.Game then
	script.Disabled = true
	script.Name = "GameRuntime (DISABLED - NOT GAME PLACE)"
	return
end

-- Initialize game services
require("@GameServices/GameManager")
require("@GameServices/Libs/Cmdr")

print("[GameRuntime] All services initialized successfully")

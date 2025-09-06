-- Menu Runtime
local Config = require("@Common/Config")

if game.PlaceId ~= Config.PlaceIds.Menu then
	script.Disabled = true
	script.Name = "MenuRuntime (DISABLED - NOT MENU PLACE)"
	return
end

require("@MenuServices/Libs/Cmdr")
require("@MenuServices/MatchmakingService"):Start()
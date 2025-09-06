local Config = require("@Common/Config")

if not game.PlaceId == Config.PlaceIds.Menu then
    script.Disabled = true
    script.Name = "MenuRuntime (DISABLED - NOT MENU PLACE)"
    return
end


require("@MenuUI/Controllers/UIController")
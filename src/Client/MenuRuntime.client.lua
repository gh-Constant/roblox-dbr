local Config = require("@Common/Config")

if not game.PlaceId == Config.PlaceIds.Menu then
    script.Disabled = true
    script.Name = "MenuRuntime (DISABLED - NOT MENU PLACE)"
    return
end

-- Initialize Menu UI
local MenuController = require("@Client/UI/Menu/Controllers/MenuController")
MenuController.Init()
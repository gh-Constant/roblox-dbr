local lobbyFolder = workspace.Lobby
local Config = require("@Common/Config")

local LobbyConfig = {
    -- Pod folders for different roles
    survivorsPod = lobbyFolder.Survivors,
    killersPod = lobbyFolder.Killers,

    -- Camera positions for different roles
    survivorsCamera = lobbyFolder.Cameras.survivorCamera,
    killerCamera = lobbyFolder.Cameras.killerCamera,

    -- Y-axis offset for teleporting players to pods
    yOffset = 4,

    -- Maximum number of players per role
    maxSurvivors = Config.RequiredKillers,
    maxKillers = Config.RequiredSurvivors,
}

return LobbyConfig
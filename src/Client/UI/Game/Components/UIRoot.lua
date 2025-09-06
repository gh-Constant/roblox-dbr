local React = require("@Packages/React")

local ScreenGui = require("@RobloxComponents/ScreenGui")
local LobbyUI = require(script.Parent.LobbyUI)

local e = React.createElement

local function UIRoot()
	return e(ScreenGui, {
		key = "GameUIRoot",
		Name = "GameUI",
	}, {
		LobbyUI = e(LobbyUI),
	})
end

return UIRoot
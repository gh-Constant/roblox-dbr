local React = require("@Packages/React")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Common.Game.Remotes)

local ScreenGui = require("@RobloxComponents/ScreenGui")
local LobbyUI = require(script.Parent.LobbyUI)
local LoadingScreen = require(script.Parent.LoadingScreen)

local e = React.createElement

local function UIRoot()
	-- State to track loading screen visibility
	local showLoading, setShowLoading = React.useState(false)
	local loadingText, setLoadingText = React.useState("Preparing game...")
	
	-- Listen for game state changes
	React.useEffect(function()
		-- Listen for game starting event
		local connection = Remotes.GameStateChanged.listen(function(data)
			if data.gameState == "Starting" then
				setShowLoading(true)
				setLoadingText("Loading map: " .. (data.mapName or "Unknown") .. "...")
			elseif data.gameState == "InProgress" then
				setShowLoading(false)
			end
		end)
		
		return function()
			connection:Disconnect()
		end
	end, {})
	
	return e(ScreenGui, {
		key = "GameUIRoot",
		Name = "GameUI",
		IgnoreGuiInset = true,
	}, {
		LobbyUI = e(LobbyUI),
		LoadingScreen = e(LoadingScreen, {
			visible = showLoading,
			loadingText = loadingText,
		}),
	})
end

return UIRoot
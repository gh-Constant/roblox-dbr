local React = require("@Packages/React")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Common.Game.Remotes)

local ScreenGui = require("@RobloxComponents/ScreenGUI")
local LobbyUI = require(script.Parent.LobbyUI)
local LoadingScreen = require(script.Parent.LoadingScreen)

local e = React.createElement

local function UIRoot()
	-- State to track loading screen visibility
	local showLoading, setShowLoading = React.useState(false)
	local loadingText, setLoadingText = React.useState("Preparing game...")
	-- State to track lobby UI visibility
	local showLobbyUI, setShowLobbyUI = React.useState(true)
	
	-- Listen for UI control events
	React.useEffect(function()
		-- Listen for loading screen show event
		local showConnection = Remotes.LoadingScreenShow.listen(function(data)
			setShowLoading(true)
			setLoadingText(data.message or "Loading...")
		end)
		
		-- Listen for loading screen hide event
		local hideConnection = Remotes.LoadingScreenHide.listen(function(data)
			setShowLoading(false)
		end)
		
		-- Listen for lobby UI hide event
		local lobbyHideConnection = Remotes.LobbyUIHide.listen(function(data)
			setShowLobbyUI(false)
		end)
		
		return function()
			showConnection:Disconnect()
			hideConnection:Disconnect()
			lobbyHideConnection:Disconnect()
		end
	end, {})
	
	return e(ScreenGui, {
		key = "GameUIRoot",
		Name = "GameUI",
		IgnoreGuiInset = true,
	}, {
		LobbyUI = showLobbyUI and e(LobbyUI) or nil,
		LoadingScreen = e(LoadingScreen, {
			visible = showLoading,
			loadingText = loadingText,
		}),
	})
end

return UIRoot
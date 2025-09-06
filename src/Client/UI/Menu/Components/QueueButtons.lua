local React = require("@Packages/React")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Common.Menu.Matchmaking.Config)
local Remotes = require(ReplicatedStorage.Common.Menu.Matchmaking.Remotes)

local e = React.createElement

local function QueueButtons()
	-- Handler for survivor queue button
	local function handleSurvivorClick()
		if Config.Debug.Matchmaking then
			print("[QueueButtons] Play Survivor button clicked")
		end
		Remotes.JoinSurvivorQueue.send()
	end
	
	-- Handler for killer queue button
	local function handleKillerClick()
		if Config.Debug.Matchmaking then
			print("[QueueButtons] Play Killer button clicked")
		end
		Remotes.JoinKillerQueue.send()
	end

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.3),
		Size = UDim2.fromOffset(300, 150),
		BackgroundTransparency = 1,
	}, {
		Layout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 20),
		}),
		
		SurvivorButton = e("TextButton", {
			Name = "PlaySurvivor",
			Size = UDim2.fromOffset(200, 50),
			BackgroundColor3 = Color3.fromRGB(0, 120, 215),
			Text = "Join Survivor Queue",
			TextColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.GothamBold,
			TextSize = 18,
			[React.Event.Activated] = handleSurvivorClick,
		}, {
			UICorner = e("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
		}),
		
		KillerButton = e("TextButton", {
			Name = "PlayKiller",
			Size = UDim2.fromOffset(200, 50),
			BackgroundColor3 = Color3.fromRGB(194, 24, 7),
			Text = "Join Killer Queue",
			TextColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.GothamBold,
			TextSize = 18,
			[React.Event.Activated] = handleKillerClick,
		}, {
			UICorner = e("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
		}),
	})
end

return QueueButtons
local React = require("@Packages/React")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Common.Game.Remotes)

local e = React.createElement

local function LobbyUI()
	-- State to track if player is ready
	local isReady, setIsReady = React.useState(false)
	
	-- Handler for ready button
	local function handleReadyClick()
		local newReadyState = not isReady
		setIsReady(newReadyState)
		
		-- Send ready state to server via ByteNet
		Remotes.PlayerReady.send({
			isReady = newReadyState
		})
		
		print("[LobbyUI] Player ready state:", newReadyState)
	end
	
	return e("Frame", {
		Name = "LobbyUI",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 0.95),
		Size = UDim2.fromOffset(400, 300),
		BackgroundColor3 = Color3.fromRGB(45, 45, 45),
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0, 12),
		}),
		
		UIStroke = e("UIStroke", {
			Color = Color3.fromRGB(70, 70, 70),
			Thickness = 2,
		}),
		
		Layout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 20),
		}),
		
		Padding = e("UIPadding", {
			PaddingTop = UDim.new(0, 30),
			PaddingBottom = UDim.new(0, 30),
			PaddingLeft = UDim.new(0, 30),
			PaddingRight = UDim.new(0, 30),
		}),
		
		Title = e("TextLabel", {
			Name = "Title",
			Size = UDim2.fromOffset(0, 40),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			Text = "Game Lobby",
			TextColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.GothamBold,
			TextSize = 24,
			TextXAlignment = Enum.TextXAlignment.Center,
		}),
		
		StatusText = e("TextLabel", {
			Name = "StatusText",
			Size = UDim2.fromOffset(0, 30),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			Text = isReady and "You are ready!" or "Waiting for you to ready up...",
			TextColor3 = isReady and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 0),
			Font = Enum.Font.Gotham,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Center,
		}),
		
		ReadyButton = e("TextButton", {
			Name = "ReadyButton",
			Size = UDim2.fromOffset(200, 60),
			BackgroundColor3 = isReady and Color3.fromRGB(220, 53, 69) or Color3.fromRGB(40, 167, 69),
			Text = isReady and "Not Ready" or "Ready Up!",
			TextColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.GothamBold,
			TextSize = 20,
			[React.Event.Activated] = handleReadyClick,
		}, {
			UICorner = e("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
			
			UIStroke = e("UIStroke", {
				Color = isReady and Color3.fromRGB(180, 43, 59) or Color3.fromRGB(30, 137, 59),
				Thickness = 2,
			}),
		}),
		
		Instructions = e("TextLabel", {
			Name = "Instructions",
			Size = UDim2.fromOffset(300, 40),
			BackgroundTransparency = 1,
			Text = "Click the button to toggle your ready status",
			TextColor3 = Color3.fromRGB(180, 180, 180),
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextWrapped = true,
		}),
	})
end

return LobbyUI
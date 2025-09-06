local React = require("@Packages/React")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Common.Menu.Matchmaking.Config)
local Remotes = require(ReplicatedStorage.Common.Menu.Matchmaking.Remotes)

local e = React.createElement

local function QueueButtons()  
	-- State to track if player is in queue and which role
	local inQueue, setInQueue = React.useState(false)
	local queueRole, setQueueRole = React.useState(nil) -- "survivor" or "killer"
	-- Handler for survivor queue button
	local function handleSurvivorClick()
		if inQueue and queueRole == "survivor" then
			-- Cancel queue
			if Config.Debug.Matchmaking then
				print("[QueueButtons] Canceling Survivor queue")
			end
			setInQueue(false)
			setQueueRole(nil)
			Remotes.JoinSurvivorQueue.send() -- Reusing the same remote for cancel
		elseif not inQueue then
			-- Join queue
			if Config.Debug.Matchmaking then
				print("[QueueButtons] Play Survivor button clicked")
			end
			setInQueue(true)
			setQueueRole("survivor")
			Remotes.JoinSurvivorQueue.send()
		end
	end
	
	-- Handler for killer queue button
	local function handleKillerClick()
		if inQueue and queueRole == "killer" then
			-- Cancel queue
			if Config.Debug.Matchmaking then
				print("[QueueButtons] Canceling Killer queue")
			end
			setInQueue(false)
			setQueueRole(nil)
			Remotes.JoinKillerQueue.send() -- Reusing the same remote for cancel
		elseif not inQueue then
			-- Join queue
			if Config.Debug.Matchmaking then
				print("[QueueButtons] Play Killer button clicked")
			end
			setInQueue(true)
			setQueueRole("killer")
			Remotes.JoinKillerQueue.send()
		end
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
			Text = inQueue and queueRole == "survivor" and "Cancel Queue" or "Join Survivor Queue",
			TextColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.GothamBold,
			TextSize = 18,
			[React.Event.Activated] = handleSurvivorClick,
			Active = not (inQueue and queueRole == "killer"), -- Disable if in killer queue
			BackgroundTransparency = (inQueue and queueRole == "killer") and 0.5 or 0,
		}, {
			UICorner = e("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
		}),
		
		KillerButton = e("TextButton", {
			Name = "PlayKiller",
			Size = UDim2.fromOffset(200, 50),
			BackgroundColor3 = Color3.fromRGB(194, 24, 7),
			Text = inQueue and queueRole == "killer" and "Cancel Queue" or "Join Killer Queue",
			TextColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.GothamBold,
			TextSize = 18,
			[React.Event.Activated] = handleKillerClick,
			Active = not (inQueue and queueRole == "survivor"), -- Disable if in survivor queue
			BackgroundTransparency = (inQueue and queueRole == "survivor") and 0.5 or 0,
		}, {
			UICorner = e("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
		}),
	})
end

return QueueButtons
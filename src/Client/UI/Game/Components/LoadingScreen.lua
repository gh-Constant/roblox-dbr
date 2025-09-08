local React = require("@Packages/React")
local TweenService = game:GetService("TweenService")

local e = React.createElement

local function LoadingScreen(props)
	local visible = props.visible or false
	local loadingText = props.loadingText or "Loading..."
	
	-- Ref for the loading circle
	local circleRef = React.useRef()
	
	-- Animation effect for the spinning circle
	React.useEffect(function()
		if not visible or not circleRef.current then
			return
		end
		
		-- Create spinning animation
		local tweenInfo = TweenInfo.new(
			2, -- Duration
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.InOut,
			-1, -- Repeat count (-1 = infinite)
			false, -- Reverse
			0 -- Delay
		)
		
		local tween = TweenService:Create(
			circleRef.current,
			tweenInfo,
			{ Rotation = 360 }
		)
		
		tween:Play()
		
		-- Cleanup function
		return function()
			tween:Cancel()
		end
	end, { visible })
	
	if not visible then
		return nil
	end
	
	return e("Frame", {
		Name = "LoadingScreen",
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.fromScale(0, 0),
		BackgroundColor3 = Color3.fromRGB(20, 20, 25),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ZIndex = 1000, -- Ensure it's on top of everything
	}, {
		-- Loading container
		LoadingContainer = e("Frame", {
			Name = "LoadingContainer",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(200, 200),
			BackgroundTransparency = 1,
		}, {
			-- Loading circle (spinning ring)
			LoadingCircle = e("Frame", {
				Name = "LoadingCircle",
				ref = circleRef,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.4),
				Size = UDim2.fromOffset(80, 80),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, {
				-- Outer ring
				OuterRing = e("Frame", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
				}, {
					UICorner = e("UICorner", {
						CornerRadius = UDim.new(0.5, 0),
					}),
					
					-- Create the spinning ring effect with UIStroke
					UIStroke = e("UIStroke", {
						Color = Color3.fromRGB(255, 255, 255),
						Thickness = 6,
						Transparency = 0.3,
					}),
					
					-- Active part of the ring (partial circle)
					ActiveRing = e("Frame", {
						Size = UDim2.fromScale(0.25, 1),
						Position = UDim2.fromScale(0.75, 0),
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderSizePixel = 0,
					}, {
						UICorner = e("UICorner", {
							CornerRadius = UDim.new(0.5, 0),
						}),
					}),
				}),
			}),
			
			-- Loading text
			LoadingText = e("TextLabel", {
				Name = "LoadingText",
				Position = UDim2.fromScale(0, 0.7),
				Size = UDim2.fromScale(1, 0.2),
				BackgroundTransparency = 1,
				Text = loadingText,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				Font = Enum.Font.GothamBold,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
			}),
		}),
	})
end

return LoadingScreen
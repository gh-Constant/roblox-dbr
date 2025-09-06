local React = require("@Packages/React")

local function MenuApp()
	return React.createElement("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
		Text = "Menu Working",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 32
	})
end

return MenuApp	
local Players = game:GetService("Players")
local React = require("@Packages/React")
local ReactRoblox = require("@Packages/react-roblox")
local MenuApp = require("../Components/MenuApp")

local MenuController = {}
local root = nil

function MenuController.Init()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	-- Create ScreenGui container
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MenuUI"
	screenGui.Parent = playerGui
	
	-- Create React root
	root = ReactRoblox.createRoot(screenGui)
	
	-- Mount the MenuApp component
	root:render(React.createElement(MenuApp))
	
	print("Menu UI initialized successfully!")
end

function MenuController.Cleanup()
	if root then
		root:unmount()
		root = nil
	end
end

return MenuController
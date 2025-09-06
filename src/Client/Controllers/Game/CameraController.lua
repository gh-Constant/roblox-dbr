--[[
	CameraController Module
	Handles camera management on the client side for lobby system
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Remotes = require("@Common/Game/Remotes")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local CameraController = {
	currentCameraType = "Custom",
	originalCFrame = nil
}

-- Handle camera change requests from server
function CameraController:OnSetCamera(data)
	if not data then
		warn("[CameraController] Invalid camera data received")
		return
	end
	
	if data.cameraType == "Scriptable" and data.cframe then
		-- Store original camera position if this is the first time setting scriptable camera
		if self.currentCameraType ~= "Scriptable" then
			self.originalCFrame = camera.CFrame
		end
		
		-- Set camera to scriptable mode
		camera.CameraType = Enum.CameraType.Scriptable
		
		-- Smoothly transition to new camera position
		local tweenInfo = TweenInfo.new(
			1.0, -- Duration
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)
		
		local tween = TweenService:Create(camera, tweenInfo, {
			CFrame = data.cframe
		})
		
		tween:Play()
		self.currentCameraType = "Scriptable"
		
		print("[CameraController] Camera set to scriptable mode")
		
	elseif data.cameraType == "Custom" then
		-- Reset camera to default
		camera.CameraType = Enum.CameraType.Custom
		self.currentCameraType = "Custom"
		
		print("[CameraController] Camera reset to custom mode")
	else
		warn("[CameraController] Unknown camera type: " .. tostring(data.cameraType))
	end
end

-- Reset camera to original position
function CameraController:ResetCamera()
	camera.CameraType = Enum.CameraType.Custom
	self.currentCameraType = "Custom"
	
	if self.originalCFrame then
		camera.CFrame = self.originalCFrame
		self.originalCFrame = nil
	end
end

-- Initialize camera controller
function CameraController:Initialize()
	-- Connect to ByteNet remote
	Remotes.SetCamera.listen(function(data)
		self:OnSetCamera(data)
	end)
	
	print("[CameraController] Initialized")
end

-- Initialize the controller
CameraController:Initialize()

return CameraController
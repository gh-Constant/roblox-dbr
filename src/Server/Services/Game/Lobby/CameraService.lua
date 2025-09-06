--[[
	CameraService Module
	Handles camera management for lobby system
]]

local LobbyConfig = require(script.Parent.LobbyConfig)
local Roles = require("@GameCommon/Enums/Roles")
local Remotes = require("@GameCommon/Remotes")

local CameraService = {}

-- Set player camera based on their role
function CameraService:SetPlayerCamera(player, role)
	local cameraTarget
	
	if role == Roles.Survivor then
		cameraTarget = LobbyConfig.survivorsCamera
	elseif role == Roles.Killer then
		cameraTarget = LobbyConfig.killerCamera
	else
		return
	end
	
	if not cameraTarget then
		return
	end
	
	-- Send camera change using ByteNet
	Remotes.SetCamera.sendTo({
		cameraType = "Scriptable",
		cframe = cameraTarget.CFrame
	}, player.RobloxPlayer)
end

return CameraService
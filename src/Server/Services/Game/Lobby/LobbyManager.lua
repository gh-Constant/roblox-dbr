--[[
	LobbyManager Module
	Handles player teleportation to lobby pods
]]

local LobbyConfig = require(script.Parent.LobbyConfig)
local CameraService = require(script.Parent.CameraService)
local Roles = require("@GameCommon/Enums/Roles")

local LobbyManager = {
	survivorsInPods = {},
	killersInPods = {}
}

-- Get next available pod number
function LobbyManager:_getNextAvailablePod(role)
	local podsInUse = role == Roles.Survivor and self.survivorsInPods or self.killersInPods
	local maxPods = role == Roles.Survivor and LobbyConfig.maxSurvivors or LobbyConfig.maxKillers
	
	for i = 1, maxPods do
		if not podsInUse[i] then
			return i
		end
	end
	return nil
end

-- Get pod part by role and number
function LobbyManager:_getPodPart(role, podNumber)
	local podFolder = role == Roles.Survivor and LobbyConfig.survivorsPod or LobbyConfig.killersPod
	local podPart = podFolder:FindFirstChild("Player" .. podNumber)
	return podPart
end

-- Teleport player to lobby pod
function LobbyManager:TeleportPlayerToPod(player)
	print("[LobbyManager] Teleporting player: " .. player.Name .. " to pod")
	local role = player:GetRole()
	print("[LobbyManager] Player role: " .. tostring(role))
	if role == Roles.None then 
		print("[LobbyManager] Player has no role, skipping teleport")
		return 
	end
	
	local podNumber = self:_getNextAvailablePod(role)
	print("[LobbyManager] Pod number: " .. tostring(podNumber))
	if not podNumber then 
		print("[LobbyManager] No available pod found")
		return 
	end
	
	local podPart = self:_getPodPart(role, podNumber)
	print("[LobbyManager] Pod part: " .. tostring(podPart))
	if not podPart then 
		print("[LobbyManager] Pod part not found")
		return 
	end
	
	local character = player.RobloxPlayer.Character
	print("[LobbyManager] Character: " .. tostring(character))
	if character and character:FindFirstChild("HumanoidRootPart") then
		local targetPosition = podPart.Position + Vector3.new(0, LobbyConfig.yOffset, 0)
		-- Rotate character 180 degrees to face the correct direction
		local rotatedCFrame = CFrame.new(targetPosition) * CFrame.Angles(0, math.rad(180), 0)
		character.HumanoidRootPart.CFrame = rotatedCFrame
		print("[LobbyManager] Successfully teleported " .. player.Name .. " to pod " .. podNumber)
		
		-- Freeze the player in the lobby
		player:Freeze()
		
		-- Assign pod
		local podsInUse = role == Roles.Survivor and self.survivorsInPods or self.killersInPods
		podsInUse[podNumber] = player
		
		-- Set camera
		CameraService:SetPlayerCamera(player, role)
	else
		print("[LobbyManager] Character or HumanoidRootPart not found")
	end
end

return LobbyManager
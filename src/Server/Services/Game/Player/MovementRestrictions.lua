--[[
	@fileoverview PlayerMovementService - Server-side service for managing player movement restrictions
	@author Generated
	@version 1.0.0
	@date 2024
]]

local MovementRestrictions = {}

local Players = game:GetService("Players")

-- Constants
local MOVEMENT_CONFIG = {
	JUMP_POWER = 0,
	JUMP_HEIGHT = 0,
	USE_JUMP_POWER = true,
	CLIMBING_ENABLED = false
}

-- Track frozen players
local frozenPlayers = {}

-- Freeze a player's character
function MovementRestrictions.FreezePlayer(player)
	if not player or not player.Character then
		return
	end
	
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	
	if humanoid and rootPart then
		-- Set PlatformStand to disable movement
		humanoid.PlatformStand = true
		-- Anchor the root part as backup
		rootPart.Anchored = true
		-- Track as frozen
		frozenPlayers[player] = true
		print("[MovementRestrictions] Frozen player: " .. player.Name)
	end
end

-- Unfreeze a player's character
function MovementRestrictions.UnfreezePlayer(player)
	if not player or not player.Character then
		return
	end
	
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	
	if humanoid and rootPart then
		-- Restore movement
		humanoid.PlatformStand = false
		-- Unanchor the root part
		rootPart.Anchored = false
		-- Remove from frozen list
		frozenPlayers[player] = nil
		print("[MovementRestrictions] Unfrozen player: " .. player.Name)
	end
end

-- Check if a player is frozen
function MovementRestrictions.IsPlayerFrozen(player)
	return frozenPlayers[player] == true
end

-- Handle all players (existing and new)
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		
		-- Disable jumping
		humanoid.JumpPower = MOVEMENT_CONFIG.JUMP_POWER
		humanoid.UseJumpPower = MOVEMENT_CONFIG.USE_JUMP_POWER
		humanoid.JumpHeight = MOVEMENT_CONFIG.JUMP_HEIGHT
		
		-- Disable climbing
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, MOVEMENT_CONFIG.CLIMBING_ENABLED)
	end)
end)

-- Handle players already in the game
for _, player in pairs(Players:GetPlayers()) do
	if player.Character then
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.JumpPower = MOVEMENT_CONFIG.JUMP_POWER
			humanoid.UseJumpPower = MOVEMENT_CONFIG.USE_JUMP_POWER
			humanoid.JumpHeight = MOVEMENT_CONFIG.JUMP_HEIGHT
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, MOVEMENT_CONFIG.CLIMBING_ENABLED)
		end
	end
	
	-- Connect to future character spawns for existing players
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		
		humanoid.JumpPower = MOVEMENT_CONFIG.JUMP_POWER
		humanoid.UseJumpPower = MOVEMENT_CONFIG.USE_JUMP_POWER
		humanoid.JumpHeight = MOVEMENT_CONFIG.JUMP_HEIGHT
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, MOVEMENT_CONFIG.CLIMBING_ENABLED)
	end)
end

return MovementRestrictions
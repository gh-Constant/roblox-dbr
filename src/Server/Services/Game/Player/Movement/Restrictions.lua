--[[
	MovementRestrictions Module
	Utility module for managing player movement restrictions
	To be called by the Player module, not runtime events
]]

local MovementRestrictions = {}

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

-- Apply basic movement restrictions to a character
function MovementRestrictions.ApplyBasicRestrictions(player)
	if not player or not player.Character then
		return
	end
	
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	
	if humanoid then
		-- Disable jumping
		humanoid.JumpPower = MOVEMENT_CONFIG.JUMP_POWER
		humanoid.UseJumpPower = MOVEMENT_CONFIG.USE_JUMP_POWER
		humanoid.JumpHeight = MOVEMENT_CONFIG.JUMP_HEIGHT
		
		-- Disable climbing
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, MOVEMENT_CONFIG.CLIMBING_ENABLED)
		
		print("[MovementRestrictions] Applied basic restrictions to: " .. player.Name)
	end
end

-- Remove basic movement restrictions from a character
function MovementRestrictions.RemoveBasicRestrictions(player)
	if not player or not player.Character then
		return
	end
	
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	
	if humanoid then
		-- Restore jumping (default Roblox values)
		humanoid.JumpPower = 50
		humanoid.UseJumpPower = true
		humanoid.JumpHeight = 7.2
		
		-- Enable climbing
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
		
		print("[MovementRestrictions] Removed basic restrictions from: " .. player.Name)
	end
end

return MovementRestrictions
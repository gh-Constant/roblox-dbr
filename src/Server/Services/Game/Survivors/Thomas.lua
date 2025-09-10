--[[
	Thomas Survivor Class
	A specific survivor type with unique characteristics
]]

-- No additional services needed for basic Thomas

local Thomas = {}
Thomas.__index = Thomas

-- Thomas specific configuration
local THOMAS_CONFIG = {
	movementSpeed = 16, -- Standard survivor speed
	health = 100,
	stamina = 100,
	-- Thomas's teachable perks (unlockable by playing as Thomas)
	teachablePerks = {
		"SprintBurst", -- His signature perk
		"None", -- Placeholder for future perk
		"None", -- Placeholder for future perk
	},
}

-- Constructor
function Thomas.new(player)
	local self = setmetatable({}, Thomas)
	
	self.player = player
	self.robloxPlayer = player.RobloxPlayer or player
	self.isActive = false
	
	-- No abilities for now
	
	print("[Thomas] Created new Thomas instance for player: " .. self.robloxPlayer.Name)
	
	return self
end

-- Activation/Deactivation
function Thomas:OnActivate()
	self.isActive = true
	self:_setupSurvivorAppearance()
	self:_setupMovementSpeed()
	print("[Thomas] Thomas activated for: " .. self.robloxPlayer.Name)
end

function Thomas:OnDeactivate()
	self.isActive = false
	self:_resetAppearance()
	print("[Thomas] Thomas deactivated for: " .. self.robloxPlayer.Name)
end

-- Ability system
function Thomas:GetAbilities()
	return {} -- No abilities for now
end

function Thomas:UseAbility(abilityName, ...)
	return false -- No abilities implemented yet
end

-- Helper methods
function Thomas:_setupSurvivorAppearance()
	-- TODO: Customize player appearance for Thomas
	-- This could include special clothing, accessories, etc.
end

function Thomas:_setupMovementSpeed()
	local character = self.robloxPlayer.Character
	if character and character:FindFirstChild("Humanoid") then
		character.Humanoid.WalkSpeed = THOMAS_CONFIG.movementSpeed
	end
end

function Thomas:_resetAppearance()
	-- TODO: Reset player appearance to default
end

-- Getters
function Thomas:GetMovementSpeed()
	return THOMAS_CONFIG.movementSpeed
end

function Thomas:GetHealth()
	return THOMAS_CONFIG.health
end

function Thomas:GetStamina()
	return THOMAS_CONFIG.stamina
end

function Thomas:GetTeachablePerks()
	return THOMAS_CONFIG.teachablePerks
end

return Thomas
--[[
	Hairstyler Killer Class
	A specific killer type with unique abilities and characteristics
]]

-- No additional services needed for basic Hairstyler

local Hairstyler = {}
Hairstyler.__index = Hairstyler

-- Hairstyler specific configuration
local HAIRSTYLER_CONFIG = {
	movementSpeed = 18, -- Slightly faster than survivors
}

-- Constructor
function Hairstyler.new(player)
	local self = setmetatable({}, Hairstyler)
	
	self.player = player
	self.robloxPlayer = player.RobloxPlayer or player
	self.isActive = false
	
	-- No abilities for now
	
	print("[Hairstyler] Created new Hairstyler instance for player: " .. self.robloxPlayer.Name)
	
	return self
end

-- Activation/Deactivation
function Hairstyler:OnActivate()
	self.isActive = true
	self:_setupKillerAppearance()
	self:_setupMovementSpeed()
	print("[Hairstyler] Hairstyler activated for: " .. self.robloxPlayer.Name)
end

function Hairstyler:OnDeactivate()
	self.isActive = false
	self:_resetAppearance()
	print("[Hairstyler] Hairstyler deactivated for: " .. self.robloxPlayer.Name)
end

-- Ability system
function Hairstyler:GetAbilities()
	return {} -- No abilities for now
end

function Hairstyler:UseAbility(abilityName, ...)
	return false -- No abilities implemented yet
end

-- Helper methods
function Hairstyler:_setupKillerAppearance()
	-- TODO: Customize player appearance for Hairstyler
	-- This could include special clothing, accessories, etc.
end

function Hairstyler:_setupMovementSpeed()
	local character = self.robloxPlayer.Character
	if character and character:FindFirstChild("Humanoid") then
		character.Humanoid.WalkSpeed = HAIRSTYLER_CONFIG.movementSpeed
	end
end

function Hairstyler:_resetAppearance()
	-- TODO: Reset player appearance to default
end

-- Getters
function Hairstyler:GetMovementSpeed()
	return HAIRSTYLER_CONFIG.movementSpeed
end

return Hairstyler
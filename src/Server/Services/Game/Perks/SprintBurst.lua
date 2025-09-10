--[[
	Sprint Burst Perk Class
	A survivor perk that provides a speed boost when starting to run
]]

local Effects = require(script.Parent.Parent.Effects)

local SprintBurst = {}
SprintBurst.__index = SprintBurst

-- Sprint Burst specific configuration
local SPRINT_BURST_CONFIG = {
	speedMultiplier = 1.5, -- 150% speed
	duration = 3, -- seconds
	cooldown = 40, -- seconds
	exhaustionTime = 60, -- seconds of exhaustion
}

-- Constructor
function SprintBurst.new(owner)
	local self = setmetatable({}, SprintBurst)
	
	self.owner = owner
	self.isActive = false
	self.exhaustedEffect = nil
	self.originalSpeed = 16 -- Default survivor speed
	
	print("[SprintBurst] Created Sprint Burst perk for player: " .. (owner and owner.Name or "Unknown"))
	
	return self
end

-- Perk lifecycle methods
function SprintBurst:OnEquip()
	print("[SprintBurst] Sprint Burst equipped")
end

function SprintBurst:OnUnequip()
	self:_resetSpeed()
	print("[SprintBurst] Sprint Burst unequipped")
end

function SprintBurst:OnActivate()
	if self:_isExhausted() then
		return false
	end
	
	self:_applySpeedBoost()
	self:_applyExhaustion()
	
	print("[SprintBurst] Sprint Burst activated for: " .. self.owner.Name)
	return true
end

function SprintBurst:OnDeactivate()
	self:_resetSpeed()
	print("[SprintBurst] Sprint Burst deactivated")
end

-- Event handling
function SprintBurst:OnTrigger(eventType, ...)
	if eventType == "StartRunning" and not self:_isExhausted() then
		return self:OnActivate()
	end
	return false
end

-- Perk information
function SprintBurst:GetPerkInfo()
	return {
		name = "Sprint Burst",
		description = "When starting to run, break into a sprint at " .. (SPRINT_BURST_CONFIG.speedMultiplier * 100) .. "% of your normal running speed for " .. SPRINT_BURST_CONFIG.duration .. " seconds. Causes Exhaustion for " .. SPRINT_BURST_CONFIG.exhaustionTime .. " seconds.",
		category = "Survivor",
		cooldown = SPRINT_BURST_CONFIG.cooldown,
		rarity = "Teachable",
		character = "Meg Thomas"
	}
end

-- Private methods
function SprintBurst:_applySpeedBoost()
	if not self.owner or not self.owner.Character then
		return
	end
	
	local humanoid = self.owner.Character:FindFirstChild("Humanoid")
	if humanoid then
		self.originalSpeed = humanoid.WalkSpeed
		humanoid.WalkSpeed = self.originalSpeed * SPRINT_BURST_CONFIG.speedMultiplier
		
		-- Reset speed after duration
		spawn(function()
			wait(SPRINT_BURST_CONFIG.duration)
			self:_resetSpeed()
		end)
	end
end

function SprintBurst:_resetSpeed()
	if not self.owner or not self.owner.Character then
		return
	end
	
	local humanoid = self.owner.Character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = self.originalSpeed
	end
end

function SprintBurst:_applyExhaustion()
	-- Check if player already has an exhausted effect
	local existingEffect = self:_getPlayerExhaustedEffect()
	if existingEffect then
		-- Extend existing exhaustion
		existingEffect:ExtendDuration(SPRINT_BURST_CONFIG.exhaustionTime)
	else
		-- Create new exhausted effect
		self.exhaustedEffect = Effects.CreateEffect("Exhausted", self.owner, SPRINT_BURST_CONFIG.exhaustionTime)
		if self.exhaustedEffect then
			self.exhaustedEffect:Apply()
			print("[SprintBurst] Applied Exhausted effect for " .. SPRINT_BURST_CONFIG.exhaustionTime .. " seconds")
		end
	end
end

function SprintBurst:_isExhausted()
	-- Check for any exhausted effect on the player
	local exhaustedEffect = self:_getPlayerExhaustedEffect()
	return exhaustedEffect and exhaustedEffect:IsActive()
end

function SprintBurst:_getPlayerExhaustedEffect()
	-- This would typically check a player's effect manager
	-- For now, return our tracked effect or check if it's still active
	if self.exhaustedEffect and self.exhaustedEffect:IsActive() then
		return self.exhaustedEffect
	end
	return nil
end

-- Getters
function SprintBurst:IsExhausted()
	return self:_isExhausted()
end

function SprintBurst:GetExhaustedEffect()
	return self.exhaustedEffect
end

function SprintBurst:GetSpeedMultiplier()
	return SPRINT_BURST_CONFIG.speedMultiplier
end

function SprintBurst:GetDuration()
	return SPRINT_BURST_CONFIG.duration
end

return SprintBurst
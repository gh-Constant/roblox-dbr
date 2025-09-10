--[[
	Effects Base Class
	Manages status effects that can be applied to players
]]

local Effects = {}
Effects.__index = Effects

-- Registry of all effect subclasses
local EFFECT_REGISTRY = {
	Exhausted = require(script.Exhausted),
}

-- Effect categories
local EFFECT_CATEGORIES = {
	DEBUFF = "Debuff",
	BUFF = "Buff",
	STATUS = "Status",
}

-- Constructor
function Effects.new(owner, effectType, duration)
	local self = setmetatable({}, Effects)
	
	self.owner = owner
	self.effectType = effectType or "Unknown"
	self.duration = duration or 0
	self.startTime = tick()
	self.isActive = false
	
	print("[Effects] Created effect: " .. self.effectType .. " for player: " .. (owner and owner.Name or "Unknown"))
	
	return self
end

-- Effect lifecycle methods
function Effects:Apply()
	self.isActive = true
	self.startTime = tick()
	print("[Effects] Applied effect: " .. self.effectType)
end

function Effects:Remove()
	self.isActive = false
	print("[Effects] Removed effect: " .. self.effectType)
end

function Effects:Update()
	if self.isActive and self.duration > 0 then
		local elapsed = tick() - self.startTime
		if elapsed >= self.duration then
			self:Remove()
			return false -- Effect expired
		end
	end
	return true -- Effect still active
end

-- Effect information
function Effects:GetEffectInfo()
	return {
		name = self.effectType,
		description = "Base effect - no specific behavior",
		category = EFFECT_CATEGORIES.STATUS,
		duration = self.duration,
		remaining = self:GetRemainingTime()
	}
end

-- Static methods
function Effects.CreateEffect(effectType, owner, duration, ...)
	local effectClass = EFFECT_REGISTRY[effectType]
	if not effectClass then
		warn("[Effects] Unknown effect type: " .. tostring(effectType))
		return nil
	end
	
	return effectClass.new(owner, duration, ...)
end

function Effects.GetAvailableEffects()
	local effects = {}
	for effectType, _ in pairs(EFFECT_REGISTRY) do
		table.insert(effects, effectType)
	end
	return effects
end

function Effects.GetEffectCategories()
	return EFFECT_CATEGORIES
end

-- Getters
function Effects:IsActive()
	return self.isActive
end

function Effects:GetRemainingTime()
	if not self.isActive or self.duration <= 0 then
		return 0
	end
	
	local elapsed = tick() - self.startTime
	return math.max(0, self.duration - elapsed)
end

function Effects:GetOwner()
	return self.owner
end

function Effects:GetEffectType()
	return self.effectType
end

return Effects
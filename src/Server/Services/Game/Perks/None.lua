--[[
	None Perk Class
	A placeholder perk that does nothing - used for empty perk slots
]]

local None = {}
None.__index = None

-- Constructor
function None.new(owner)
	local self = setmetatable({}, None)
	
	self.owner = owner
	self.isActive = false
	
	return self
end

-- Perk lifecycle methods
function None:OnEquip()
	-- Do nothing
end

function None:OnUnequip()
	-- Do nothing
end

function None:OnActivate()
	return false -- No effect
end

function None:OnDeactivate()
	-- Do nothing
end

-- Event handling
function None:OnTrigger(eventType, ...)
	return false -- No triggers
end

-- Perk information
function None:GetPerkInfo()
	return {
		name = "None",
		description = "Empty perk slot - no effect.",
		category = "Universal",
		cooldown = 0,
		rarity = "Common",
		character = "Universal"
	}
end

-- Getters
function None:IsActive()
	return false
end

function None:GetCooldown()
	return 0
end

return None
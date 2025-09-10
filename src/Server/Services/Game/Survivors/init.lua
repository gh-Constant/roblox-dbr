--[[
	Survivors Module
	Base class for all survivor types in Dead by Roblox
]]

local Survivors = {}
Survivors.__index = Survivors

-- Import survivor subclasses
local Thomas = require(script.Thomas)

-- Registry of survivor types and their corresponding classes
local survivorTypes = {
	Thomas = Thomas,
}

-- Constructor
function Survivors.new(survivorType, player)
	local SurvivorClass = survivorTypes[survivorType]
	if not SurvivorClass then
		warn("[Survivors] Unknown survivor type: " .. tostring(survivorType))
		return nil
	end
	
	local self = setmetatable({}, Survivors)
	self.survivorType = survivorType
	self.player = player
	self.isActive = false
	self.abilities = {}
	
	-- Create the specific survivor instance
	self.survivorInstance = SurvivorClass.new(player)
	
	return self
end

-- Base survivor methods
function Survivors:GetSurvivorType()
	return self.survivorType
end

-- Get teachable perks (to be overridden by subclasses)
function Survivors:GetTeachablePerks()
	return {"None", "None", "None"} -- Default empty perks
end

function Survivors:GetPlayer()
	return self.player
end

function Survivors:IsActive()
	return self.isActive
end

function Survivors:Activate()
	self.isActive = true
	if self.survivorInstance and self.survivorInstance.OnActivate then
		self.survivorInstance:OnActivate()
	end
	print("[Survivors] Activated " .. self.survivorType .. " for player: " .. self.player.Name)
end

function Survivors:Deactivate()
	self.isActive = false
	if self.survivorInstance and self.survivorInstance.OnDeactivate then
		self.survivorInstance:OnDeactivate()
	end
	print("[Survivors] Deactivated " .. self.survivorType .. " for player: " .. self.player.Name)
end

-- Delegate method calls to the specific survivor instance
function Survivors:UseAbility(abilityName, ...)
	if not self.isActive then
		warn("[Survivors] Cannot use ability - survivor is not active")
		return false
	end
	
	if self.survivorInstance and self.survivorInstance.UseAbility then
		return self.survivorInstance:UseAbility(abilityName, ...)
	end
	
	return false
end

function Survivors:GetAbilities()
	if self.survivorInstance and self.survivorInstance.GetAbilities then
		return self.survivorInstance:GetAbilities()
	end
	return {}
end

-- Static method to get available survivor types
function Survivors.GetAvailableSurvivors()
	local available = {}
	for survivorType, _ in pairs(survivorTypes) do
		table.insert(available, survivorType)
	end
	return available
end

-- Static method to check if a survivor type exists
function Survivors.IsValidSurvivorType(survivorType)
	return survivorTypes[survivorType] ~= nil
end

return Survivors
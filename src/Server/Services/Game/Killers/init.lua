--[[
	Killers Module
	Base class for all killer types in Dead by Roblox
]]

local Killers = {}
Killers.__index = Killers

-- Import killer subclasses
local Hairstyler = require(script.Hairstyler)

-- Registry of killer types and their corresponding classes
local killerTypes = {
	Hairstyler = Hairstyler,
}

-- Constructor
function Killers.new(killerType, player)
	local KillerClass = killerTypes[killerType]
	if not KillerClass then
		warn("[Killers] Unknown killer type: " .. tostring(killerType))
		return nil
	end
	
	local self = setmetatable({}, Killers)
	self.killerType = killerType
	self.player = player
	self.isActive = false
	self.abilities = {}
	
	-- Create the specific killer instance
	self.killerInstance = KillerClass.new(player)
	
	return self
end

-- Base killer methods
function Killers:GetKillerType()
	return self.killerType
end

function Killers:GetPlayer()
	return self.player
end

function Killers:IsActive()
	return self.isActive
end

function Killers:Activate()
	self.isActive = true
	if self.killerInstance and self.killerInstance.OnActivate then
		self.killerInstance:OnActivate()
	end
	print("[Killers] Activated " .. self.killerType .. " for player: " .. self.player.Name)
end

function Killers:Deactivate()
	self.isActive = false
	if self.killerInstance and self.killerInstance.OnDeactivate then
		self.killerInstance:OnDeactivate()
	end
	print("[Killers] Deactivated " .. self.killerType .. " for player: " .. self.player.Name)
end

-- Delegate method calls to the specific killer instance
function Killers:UseAbility(abilityName, ...)
	if not self.isActive then
		warn("[Killers] Cannot use ability - killer is not active")
		return false
	end
	
	if self.killerInstance and self.killerInstance.UseAbility then
		return self.killerInstance:UseAbility(abilityName, ...)
	end
	
	return false
end

function Killers:GetAbilities()
	if self.killerInstance and self.killerInstance.GetAbilities then
		return self.killerInstance:GetAbilities()
	end
	return {}
end

-- Static method to get available killer types
function Killers.GetAvailableKillers()
	local available = {}
	for killerType, _ in pairs(killerTypes) do
		table.insert(available, killerType)
	end
	return available
end

-- Static method to check if a killer type exists
function Killers.IsValidKillerType(killerType)
	return killerTypes[killerType] ~= nil
end

return Killers
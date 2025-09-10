--[[
	Perks Module
	Base class for all perk types in Dead by Roblox
]]

local Perks = {}
Perks.__index = Perks

-- Import perk subclasses
local SprintBurst = require(script.SprintBurst)
local SelfCare = require(script.SelfCare)
local BarbecueAndChili = require(script.BarbecueAndChili)
local HexRuin = require(script.HexRuin)
local DeadHard = require(script.DeadHard)
local Adrenaline = require(script.Adrenaline)

-- Registry of perk types and their corresponding classes
local perkTypes = {
	SprintBurst = SprintBurst,
	None = require(script.None),
	SelfCare = SelfCare,
	BarbecueAndChili = BarbecueAndChili,
	HexRuin = HexRuin,
	DeadHard = DeadHard,
	Adrenaline = Adrenaline,
}

-- Perk categories
local PERK_CATEGORIES = {
	SURVIVOR = "Survivor",
	KILLER = "Killer",
	UNIVERSAL = "Universal"
}

-- Constructor
function Perks.new(perkType, owner)
	local PerkClass = perkTypes[perkType]
	if not PerkClass then
		warn("[Perks] Unknown perk type: " .. tostring(perkType))
		return nil
	end
	
	local self = setmetatable({}, Perks)
	self.perkType = perkType
	self.owner = owner -- Player who owns this perk
	self.isActive = false
	self.isEquipped = false
	self.cooldownActive = false
	
	-- Create the specific perk instance
	self.perkInstance = PerkClass.new(owner)
	
	return self
end

-- Base perk methods
function Perks:GetPerkType()
	return self.perkType
end

function Perks:GetOwner()
	return self.owner
end

function Perks:IsActive()
	return self.isActive
end

function Perks:IsEquipped()
	return self.isEquipped
end

function Perks:Equip()
	self.isEquipped = true
	if self.perkInstance and self.perkInstance.OnEquip then
		self.perkInstance:OnEquip()
	end
	print("[Perks] Equipped " .. self.perkType .. " for player: " .. self.owner.Name)
end

function Perks:Unequip()
	self.isEquipped = false
	self.isActive = false
	if self.perkInstance and self.perkInstance.OnUnequip then
		self.perkInstance:OnUnequip()
	end
	print("[Perks] Unequipped " .. self.perkType .. " for player: " .. self.owner.Name)
end

function Perks:Activate()
	if not self.isEquipped then
		warn("[Perks] Cannot activate - perk is not equipped")
		return false
	end
	
	if self.cooldownActive then
		warn("[Perks] Cannot activate - perk is on cooldown")
		return false
	end
	
	self.isActive = true
	if self.perkInstance and self.perkInstance.OnActivate then
		return self.perkInstance:OnActivate()
	end
	
	return true
end

function Perks:Deactivate()
	self.isActive = false
	if self.perkInstance and self.perkInstance.OnDeactivate then
		self.perkInstance:OnDeactivate()
	end
end

-- Trigger perk effect
function Perks:Trigger(eventType, ...)
	if not self.isEquipped then
		return false
	end
	
	if self.perkInstance and self.perkInstance.OnTrigger then
		return self.perkInstance:OnTrigger(eventType, ...)
	end
	
	return false
end

-- Get perk information
function Perks:GetPerkInfo()
	if self.perkInstance and self.perkInstance.GetPerkInfo then
		return self.perkInstance:GetPerkInfo()
	end
	return {
		name = self.perkType,
		description = "No description available",
		category = PERK_CATEGORIES.UNIVERSAL,
		cooldown = 0
	}
end

-- Cooldown management
function Perks:StartCooldown(duration)
	self.cooldownActive = true
	spawn(function()
		wait(duration)
		self.cooldownActive = false
	end)
end

function Perks:IsOnCooldown()
	return self.cooldownActive
end

-- Static methods
function Perks.GetAvailablePerks()
	local available = {}
	for perkType, _ in pairs(perkTypes) do
		table.insert(available, perkType)
	end
	return available
end

function Perks.GetPerksByCategory(category)
	local perksInCategory = {}
	for perkType, PerkClass in pairs(perkTypes) do
		local tempInstance = PerkClass.new(nil)
		if tempInstance.GetPerkInfo then
			local info = tempInstance:GetPerkInfo()
			if info.category == category then
				table.insert(perksInCategory, perkType)
			end
		end
	end
	return perksInCategory
end

function Perks.IsValidPerkType(perkType)
	return perkTypes[perkType] ~= nil
end

function Perks.GetPerkCategories()
	return PERK_CATEGORIES
end

return Perks
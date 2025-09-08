--[[
	Player OOP Module
	Handles player data and role management for Dead by Roblox
]]

local Role = require("@GameCommon/Enums/Roles")
local MovementRestrictions = require(script.Parent.Movement.Restrictions)

local Player = {}
Player.__index = Player

-- Constructor
function Player.new(robloxPlayer)
	local self = setmetatable({}, Player)
	
	self.RobloxPlayer = robloxPlayer
	self.UserId = robloxPlayer.UserId
	self.Name = robloxPlayer.Name
	self.Role = Role.None
	self.IsAlive = true
	self.IsReady = false
	self.JoinTime = tick()
	self.IsFrozen = false
	
	-- Handle character spawning for movement restrictions
	self:_connectCharacterEvents()
	
	return self
end

-- Role management methods
function Player:SetRole(role)
	if Role[role] then
		self.Role = role
		return true
	else
		warn("Invalid role: " .. tostring(role))
		return false
	end
end

function Player:GetRole()
	return self.Role
end

function Player:IsKiller()
	return self.Role == Role.Killer
end

function Player:IsSurvivor()
	return self.Role == Role.Survivor
end

function Player:HasRole()
	return self.Role ~= Role.None
end

-- Player state methods
function Player:SetAlive(alive)
	self.IsAlive = alive
end

function Player:GetAlive()
	return self.IsAlive
end

function Player:Kill()
	self.IsAlive = false
end

function Player:Revive()
	self.IsAlive = true
end

-- Ready state methods
function Player:SetReady(ready)
	self.IsReady = ready
	print("[Player] " .. self.Name .. " ready state: " .. tostring(ready))
end

function Player:GetReady()
	return self.IsReady
end

-- Toggle ready state
function Player:ToggleReady()
	self:SetReady(not self.IsReady)
	return self.IsReady
end

-- Utility methods
function Player:GetPlayTime()
	return tick() - self.JoinTime
end

function Player:GetDisplayName()
	return self.Name .. " (" .. self.Role .. ")"
end

function Player:Reset()
	self.Role = Role.None
	self.IsAlive = true
	self.IsFrozen = false
end

-- Private method to connect character events
function Player:_connectCharacterEvents()
	-- Handle current character if it exists
	if self.RobloxPlayer.Character then
		self:_onCharacterAdded(self.RobloxPlayer.Character)
	end
	
	-- Connect to future character spawns
	self.RobloxPlayer.CharacterAdded:Connect(function(character)
		self:_onCharacterAdded(character)
	end)
end

-- Private method called when character is added
function Player:_onCharacterAdded(character)
	-- Wait for humanoid to be available
	character:WaitForChild("Humanoid")
	
	-- Apply basic movement restrictions
	MovementRestrictions.ApplyBasicRestrictions(self.RobloxPlayer)
	
	-- Restore frozen state if player was frozen
	if self.IsFrozen then
		MovementRestrictions.FreezePlayer(self.RobloxPlayer)
	end
end

-- Movement restriction methods
function Player:Freeze()
	self.IsFrozen = true
	MovementRestrictions.FreezePlayer(self.RobloxPlayer)
end

function Player:Unfreeze()
	self.IsFrozen = false
	MovementRestrictions.UnfreezePlayer(self.RobloxPlayer)
end

function Player:IsFrozen()
	return self.IsFrozen
end

function Player:ApplyMovementRestrictions()
	MovementRestrictions.ApplyBasicRestrictions(self.RobloxPlayer)
end

function Player:RemoveMovementRestrictions()
	MovementRestrictions.RemoveBasicRestrictions(self.RobloxPlayer)
end

-- Static methods
function Player.GetRoles()
	return Role
end

function Player.IsValidRole(role)
	return Role[role] ~= nil
end

-- Export the module
return Player
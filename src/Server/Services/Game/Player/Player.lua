--[[
	Player OOP Module
	Handles player data and role management for Dead by Roblox
]]

local Role = require("@GameCommon/Enums/Roles")

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
end

function Player:GetReady()
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
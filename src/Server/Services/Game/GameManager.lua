--[[
	GameManager Module
	Handles player management and game state for Dead by Roblox
]]

local Players = game:GetService("Players")
local Player = require(script.Parent.Player.Player)
local Roles = require(script.Parent.Parent.Common.Enums.Roles)
local GameState = require(script.Parent.Parent.Common.Enums.GameState)

local GameManager = {}
GameManager.__index = GameManager

-- Constructor
function GameManager.new()
	local self = setmetatable({}, GameManager)
	
	self.Players = {} -- Dictionary of UserId -> Player instances
	self.GameState = GameState.Waiting
	
	-- Connect player events
	self:_connectPlayerEvents()
	
	return self
end

-- Handle player joining
function GameManager:_onPlayerJoined(robloxPlayer)
	local playerInstance = Player.new(robloxPlayer)
	
	-- Store the player instance
	self.Players[robloxPlayer.UserId] = playerInstance
	
	print("Player joined: " .. robloxPlayer.Name .. " (Total: " .. self:GetPlayerCount() .. ")")
	
	-- You can add additional logic here like:
	-- - Assigning roles
	-- - Updating UI
	-- - Starting game if enough players
end





-- Private method to connect player events
function GameManager:_connectPlayerEvents()
	Players.PlayerAdded:Connect(function(robloxPlayer)
		self:_onPlayerJoined(robloxPlayer)
	end)
	
	Players.PlayerRemoving:Connect(function(robloxPlayer)
		self:_onPlayerLeft(robloxPlayer)
	end)
end
-- Handle player leaving
function GameManager:_onPlayerLeft(robloxPlayer)
	local playerInstance = self.Players[robloxPlayer.UserId]
	
	if playerInstance then
		self.Players[robloxPlayer.UserId] = nil
		
		print("Player left: " .. robloxPlayer.Name .. " (Total: " .. self:GetPlayerCount() .. ")")
		
		-- You can add additional logic here like:
		-- - Reassigning roles
		-- - Ending game if not enough players
	end
end

-- Public methods for player management
function GameManager:GetPlayer(userId)
	return self.Players[userId]
end

function GameManager:GetPlayerByName(playerName)
	for _, playerInstance in pairs(self.Players) do
		if playerInstance.Name == playerName then
			return playerInstance
		end
	end
	return nil
end

function GameManager:GetAllPlayers()
	return self.Players
end

function GameManager:GetPlayerCount()
	local count = 0
	for _ in pairs(self.Players) do
		count = count + 1
	end
	return count
end

function GameManager:GetPlayersWithRole(role)
	local playersWithRole = {}
	
	for _, playerInstance in pairs(self.Players) do
		if playerInstance:GetRole() == role then
			table.insert(playersWithRole, playerInstance)
		end
	end
	
	return playersWithRole
end

function GameManager:ClearAllRoles()
	for _, playerInstance in pairs(self.Players) do
		playerInstance:Reset()
	end
end

-- Game state management
function GameManager:SetGameState(state)
	self.GameState = state
	print("Game state changed to: " .. state)
end

function GameManager:GetGameState()
	return self.GameState
end

-- Utility methods
function GameManager:IsPlayerInGame(userId)
	return self.Players[userId] ~= nil
end

function GameManager:GetPlayerList()
	local playerList = {}
	
	for _, playerInstance in pairs(self.Players) do
		table.insert(playerList, {
			Name = playerInstance.Name,
			UserId = playerInstance.UserId,
			Role = playerInstance:GetRole(),
			IsAlive = playerInstance:GetAlive()
		})
	end
	
	return playerList
end

return GameManager
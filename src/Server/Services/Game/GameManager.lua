--[[
	GameManager Module
	Handles player management and game state for Dead by Roblox
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = require(script.Parent.Player.Player)
local Roles = require("@GameCommon/Enums/Roles")
local GameState = require("@GameCommon/Enums/GameState")
local CommonConfig = require("@Common/Config")
local LobbyManager = require(script.Parent.Lobby.LobbyManager)
local MapChooser = require(script.Parent.Lobby.MapChooser)
local Remotes = require(game.ReplicatedStorage.Common.Game.Remotes)

local GameManager = {
	Players = {}, -- Dictionary of UserId -> Player instances
	GameState = GameState.Waiting,
	ExpectedPlayers = RunService:IsStudio() and 1 or (CommonConfig.RequiredKillers + CommonConfig.RequiredSurvivors),
	TeleportData = nil -- Store teleport data for role assignment
}

print("[GameManager] Initialized - Expected players: " .. GameManager.ExpectedPlayers .. (RunService:IsStudio() and " (Studio)" or ""))


-- Handle player joining
function GameManager:_onPlayerJoined(robloxPlayer)
	print("[GameManager] _onPlayerJoined called for: " .. robloxPlayer.Name)
	local playerInstance = Player.new(robloxPlayer)
	self.Players[robloxPlayer.UserId] = playerInstance
	
	-- Assign role from teleport data if available
	local roleAssigned = false
	if self.TeleportData and self.TeleportData.players then
		for _, playerData in ipairs(self.TeleportData.players) do
			if playerData.userId == robloxPlayer.UserId then
				local role = playerData.role == "killer" and Roles.Killer or Roles.Survivor
				playerInstance:SetRole(role)
				print("[GameManager] " .. robloxPlayer.Name .. " assigned role: " .. playerData.role)
				roleAssigned = true
				break
			end
		end
		if not roleAssigned then
			print("[GameManager] WARN: " .. robloxPlayer.Name .. " not found in teleport data")
		end
	else
		-- In Studio or when no teleport data, assign default role for testing
		if RunService:IsStudio() then
			local role = self:GetPlayerCount() == 1 and Roles.Killer or Roles.Survivor
			playerInstance:SetRole(role)
			local roleStr = role == Roles.Killer and "killer" or "survivor"
			print("[GameManager] Studio: " .. robloxPlayer.Name .. " assigned " .. roleStr)
		end
	end
	
	print("[GameManager] Player joined: " .. robloxPlayer.Name .. " (" .. self:GetPlayerCount() .. "/" .. self.ExpectedPlayers .. ")")
	
	-- Teleport player to lobby if they have a role
	print("[GameManager] Checking if player has role: " .. tostring(playerInstance:HasRole()))
	if playerInstance:HasRole() then
		print("[GameManager] Player has role, setting up teleportation")
		-- Wait for character to spawn before teleporting
		robloxPlayer.CharacterAdded:Connect(function(character)
			print("[GameManager] Character spawned for " .. robloxPlayer.Name)
			character:WaitForChild("HumanoidRootPart")
			wait(0.1)
			print("[GameManager] Calling LobbyManager:TeleportPlayerToPod (CharacterAdded)")
			LobbyManager:TeleportPlayerToPod(playerInstance)
		end)
		
		-- If character already exists, teleport immediately
		if robloxPlayer.Character and robloxPlayer.Character:FindFirstChild("HumanoidRootPart") then
			print("[GameManager] Character already exists, teleporting immediately")
			LobbyManager:TeleportPlayerToPod(playerInstance)
		else
			print("[GameManager] Character not ready yet, waiting for spawn")
		end
	else
		print("[GameManager] Player has no role, skipping teleportation")
	end
	
	-- Check if all expected players have joined
	if self:GetPlayerCount() >= self.ExpectedPlayers then
		print("[GameManager] All players joined - ready to start")
	end
end

-- Private method to connect player events
function GameManager:_connectPlayerEvents()
	print("[GameManager] Connecting player events...")
	Players.PlayerAdded:Connect(function(robloxPlayer)
		print("[GameManager] PlayerAdded event fired for: " .. robloxPlayer.Name)
		
		-- Handle teleport data if available
		local joinData = robloxPlayer:GetJoinData()
		if joinData and joinData.TeleportData then
			local teleportData = joinData.TeleportData
			print("[GameManager] Teleport data received for: " .. robloxPlayer.Name)
			self:SetTeleportData(teleportData)
		end
		
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
		print("[GameManager] Player left: " .. robloxPlayer.Name .. " (" .. self:GetPlayerCount() .. "/" .. self.ExpectedPlayers .. ")")
		
		-- Check if game should end due to insufficient players
		if self:GetPlayerCount() < self.ExpectedPlayers and self.GameState ~= GameState.Waiting then
			print("[GameManager] WARN: Insufficient players remaining")
		end
	else
		print("[GameManager] ERROR: Player instance not found for " .. robloxPlayer.Name)
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
	print("[GameManager] Game state: " .. state)
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
			IsAlive = playerInstance:GetAlive(),
			IsReady = playerInstance:GetReady()
		})
	end
	
	return playerList
end
-- Set teleport data and expected players
function GameManager:SetTeleportData(teleportData)
	if teleportData then
		self.TeleportData = teleportData
		
		if teleportData.expectedPlayers then
			-- Don't override Studio exception
			if not RunService:IsStudio() then
				self.ExpectedPlayers = teleportData.expectedPlayers
				print("[GameManager] Expected players set to: " .. self.ExpectedPlayers)
			end
		else
			print("[GameManager] WARN: Missing expectedPlayers in teleport data")
		end
	else
		self.TeleportData = nil
		if not RunService:IsStudio() then
			self.ExpectedPlayers = CommonConfig.RequiredKillers + CommonConfig.RequiredSurvivors
		end
	end
end

-- Get expected players count
function GameManager:GetExpectedPlayers()
	return self.ExpectedPlayers
end

-- Teleport all players to lobby
function GameManager:TeleportAllToLobby()
	self:SetGameState(GameState.Lobby)
	for _, player in pairs(self.Players) do
		if player:HasRole() then
			LobbyManager:TeleportPlayerToPod(player)
		end
	end
end

-- Start the game when all players are ready
function GameManager:StartGame()
	print("[GameManager] Starting game with " .. self:GetPlayerCount() .. " players")
	
	-- Choose a random map for the game
	local chosenMap = MapChooser:ChooseRandomMap()
	if chosenMap then
		print("[GameManager] Selected map: " .. chosenMap.name .. " for the upcoming match!")
		-- Store the chosen map for later use
		self.CurrentMap = chosenMap
	else
		warn("[GameManager] Failed to select a map! Game cannot start.")
		return
	end
	
	-- Set game state and notify all clients
	self:SetGameState(GameState.Starting)
	
	-- Broadcast game state change to all clients for loading screen
	Remotes.GameStateChanged.sendToAll({
		gameState = "Starting",
		mapName = chosenMap.name
	})
	
	-- TODO: Implement actual game start logic here
	-- - Spawn players in appropriate locations based on chosen map
	-- - Start game timers and mechanics
	-- - After loading is complete, send "InProgress" state
end

-- Initialize player events
print("[GameManager] About to connect player events...")
GameManager:_connectPlayerEvents()
print("[GameManager] Player events connected successfully")

return GameManager
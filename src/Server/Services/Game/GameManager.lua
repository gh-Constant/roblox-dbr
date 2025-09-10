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
local MapInstance = require(script.Parent.MapInstance)
local Remotes = require(game.ReplicatedStorage.Common.Game.Remotes)
local Generator = require(script.Parent.Interactables.Generator)

local GameManager = {
	Players = {}, -- Dictionary of UserId -> Player instances
	GameState = GameState.Waiting,
	ExpectedPlayers = RunService:IsStudio() and 1 or (CommonConfig.RequiredKillers + CommonConfig.RequiredSurvivors),
	TeleportData = nil, -- Store teleport data for role assignment
	
	-- Generator Management
	CompletedGenerators = 0,
	RequiredGenerators = 5, -- Will be set from GameConfig when available
	CurrentMap = nil,
	
	-- Map Instance Manager
	MapInstanceManager = MapInstance.new()
}

print("[GameManager] Initialized - Expected players: " .. GameManager.ExpectedPlayers .. (RunService:IsStudio() and " (Studio)" or ""))

-- ========================================
-- MAIN FUNCTIONS (Call other functions)
-- ========================================

-- Private method to connect player events

-- Start the game when all players are ready
function GameManager:StartGame()
	print("[GameManager] Starting game with " .. self:GetPlayerCount() .. " players")
	
	-- Reset generators for new match
	self:ResetGenerators()
	
	-- Choose a random map for the game
	local chosenMap = MapChooser:ChooseRandomMap()
	if chosenMap then
		print("[GameManager] Selected map: " .. chosenMap.name .. " for the upcoming match!")
		-- Load the chosen map using MapInstance manager
		local success = self.MapInstanceManager:LoadMap(chosenMap.name)
		if success then
			self.CurrentMap = chosenMap
			print("[GameManager] Map loaded successfully:", chosenMap.name)
		else
			warn("[GameManager] Failed to load map:", chosenMap.name)
			return
		end
	else
		warn("[GameManager] Failed to select a map! Game cannot start.")
		return
	end
	
	-- Set game state
	self:SetGameState(GameState.Starting)
	
	-- Show loading screen
	self:ShowLoadingScreen("Loading map: " .. chosenMap.name .. "...")
	
	-- Hide lobby UI when game starts
	self:HideLobbyUI()
	
	-- Teleport players to spawn points based on their roles
	self:TeleportPlayersToSpawns()
	
	-- Start coroutine to handle loading completion with delay
	coroutine.wrap(function()
		-- Wait a bit for everything to load properly
		wait(2)
		-- Hide loading screen after delay
		self:HideLoadingScreen()
		
		-- Reset all players' cameras back to their characters
		self:ResetAllPlayerCameras()
		
		-- Unfreeze all players
		self:UnfreezeAllPlayers()
	end)()
	
	self:SetGameState(GameState.InProgress)

	-- TODO: Implement remaining game start logic here
	-- - Start game timers and mechanics
end


function GameManager:_connectPlayerEvents()
	print("[GameManager] Connecting player events...")
	Players.PlayerAdded:Connect(function(robloxPlayer)
		print("[GameManager] PlayerAdded event fired for: " .. robloxPlayer.Name)
		
		-- Handle teleport data if available
		self:_handleTeleportData(robloxPlayer)
		
		self:_onPlayerJoined(robloxPlayer)
	end)
	
	Players.PlayerRemoving:Connect(function(robloxPlayer)
		self:_onPlayerLeft(robloxPlayer)
	end)
end

-- Handle player joining
function GameManager:_onPlayerJoined(robloxPlayer)
	print("[GameManager] _onPlayerJoined called for: " .. robloxPlayer.Name)
	local playerInstance = Player.new(robloxPlayer)
	self.Players[robloxPlayer.UserId] = playerInstance
	
	-- Assign role to the player
	self:_assignPlayerRole(playerInstance, robloxPlayer)
	
	print("[GameManager] Player joined: " .. robloxPlayer.Name .. " (" .. self:GetPlayerCount() .. "/" .. self.ExpectedPlayers .. ")")
	
	-- Handle player teleportation to lobby
	self:_handlePlayerTeleportation(playerInstance, robloxPlayer)
	
	-- Check if all expected players have joined
	self:_checkGameReadyStatus()
end

-- Handle player leaving
function GameManager:_onPlayerLeft(robloxPlayer)
	local playerInstance = self.Players[robloxPlayer.UserId]
	
	if playerInstance then
		self.Players[robloxPlayer.UserId] = nil
		print("[GameManager] Player left: " .. robloxPlayer.Name .. " (" .. self:GetPlayerCount() .. "/" .. self.ExpectedPlayers .. ")")
		
		-- Check if game should end due to insufficient players
		self:_checkInsufficientPlayers()
	else
		print("[GameManager] ERROR: Player instance not found for " .. robloxPlayer.Name)
	end
end

-- ========================================
-- HELPER FUNCTIONS (Called by main functions)
-- ========================================

-- Handle teleport data from player join data
function GameManager:_handleTeleportData(robloxPlayer)
	local joinData = robloxPlayer:GetJoinData()
	if joinData and joinData.TeleportData then
		local teleportData = joinData.TeleportData
		print("[GameManager] Teleport data received for: " .. robloxPlayer.Name)
		self:SetTeleportData(teleportData)
	end
end

-- Assign role to player from teleport data or default studio role
function GameManager:_assignPlayerRole(playerInstance, robloxPlayer)
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
end

-- Handle player teleportation to lobby
function GameManager:_handlePlayerTeleportation(playerInstance, robloxPlayer)
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
end

-- Check if game is ready to start after player joins
function GameManager:_checkGameReadyStatus()
	if self:GetPlayerCount() >= self.ExpectedPlayers then
		print("[GameManager] All players joined - ready to start")
	end
end

-- Check if game should end due to insufficient players
function GameManager:_checkInsufficientPlayers()
	if self:GetPlayerCount() < self.ExpectedPlayers and self.GameState ~= GameState.Waiting then
		print("[GameManager] WARN: Insufficient players remaining")
	end
end

-- ========================================
-- GENERATOR MANAGEMENT
-- ========================================

-- Handle generator completion (called by Generator signal)
function GameManager:OnGeneratorCompleted(generator)
	self.CompletedGenerators = self.CompletedGenerators + 1
	local remaining = self:GetRemainingGenerators()
	
	print("[GameManager] Generator completed! (" .. self.CompletedGenerators .. "/" .. self.RequiredGenerators .. ")")
	print("[GameManager] Remaining generators: " .. remaining)
	
	-- Broadcast generator completion to all clients
	if Remotes.GeneratorCompleted then
		Remotes.GeneratorCompleted.sendToAll({
			completed = self.CompletedGenerators,
			remaining = remaining,
			required = self.RequiredGenerators
		})
	end
	
	-- Check win condition
	if self.CompletedGenerators >= self.RequiredGenerators then
		self:OnAllGeneratorsCompleted()
	end
end

-- Handle all generators completed (survivor win condition)
function GameManager:OnAllGeneratorsCompleted()
	print("[GameManager] All required generators completed! Exit gates can now be powered.")
	
	-- Set game state to end game
	self:SetGameState(GameState.EndGame)
	
	-- Broadcast to all clients
	Remotes.GameStateChanged.sendToAll({
		gameState = "EndGame",
		message = "All generators completed! Exit gates are now available!"
	})
	
	-- TODO: Enable exit gates, start end game collapse timer
end

-- Get remaining generators needed
function GameManager:GetRemainingGenerators()
	return math.max(0, self.RequiredGenerators - self.CompletedGenerators)
end

-- Get completed generators count
function GameManager:GetCompletedGenerators()
	return self.CompletedGenerators
end

-- Reset generators for new match
function GameManager:ResetGenerators()
	self.CompletedGenerators = 0
	print("[GameManager] Generator progress reset")
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

-- Get the current map instance
function GameManager:GetCurrentMapInstance()
	return self.MapInstanceManager:GetCurrentMap()
end

-- Get the interactables manager for the current map
function GameManager:GetInteractablesManager()
	return self.MapInstanceManager:GetInteractablesManager()
end

-- Check if a map is currently loaded
function GameManager:HasMapLoaded()
	return self.MapInstanceManager:HasMapLoaded()
end

-- Teleport all players to spawn points based on their roles
function GameManager:TeleportPlayersToSpawns()
	if not self:HasMapLoaded() then
		warn("[GameManager] Cannot teleport players - no map loaded")
		return false
	end
	
	local playerRoleMap = {}
	
	-- Build player-role mapping
	for userId, playerData in pairs(self.Players) do
		local robloxPlayer = game.Players:GetPlayerByUserId(userId)
		if robloxPlayer and robloxPlayer.Character then
			local role = playerData.Role
			if role then
				-- Convert role to spawn point naming convention
				local spawnRole
				if role == "Killer" then
					spawnRole = "killer"
				elseif role == "Survivor" then
					spawnRole = "survivor"
				else
					warn("[GameManager] Unknown role for player", robloxPlayer.Name, ":", role)
					continue
				end
				
				playerRoleMap[robloxPlayer] = spawnRole
			else
				warn("[GameManager] No role assigned to player:", robloxPlayer.Name)
			end
		else
			warn("[GameManager] Player not found or no character:", userId)
		end
	end
	
	-- Teleport players using MapInstance
	local success = self.MapInstanceManager:TeleportPlayers(playerRoleMap)
	if success then
		print("[GameManager] Successfully teleported all players to spawn points")
	else
		warn("[GameManager] Some players failed to teleport to spawn points")
	end
	
	return success
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

-- Check if all players are ready and start game if conditions are met
function GameManager:CheckAllPlayersReady()
	local allPlayers = self:GetAllPlayers()
	local totalPlayers = 0
	local readyPlayers = 0
	
	for _, playerInstance in pairs(allPlayers) do
		totalPlayers = totalPlayers + 1
		if playerInstance:GetReady() then
			readyPlayers = readyPlayers + 1
		end
	end
	
	-- Check if we have enough players and all are ready
	if totalPlayers >= self:GetExpectedPlayers() and readyPlayers == totalPlayers and totalPlayers > 0 then
		print("[GameManager] All players ready - starting game")
		self:StartGame()
		return true
	end
	
	return false
end

-- Handle player ready state change
function GameManager:SetPlayerReady(userId, isReady)
	-- Check if game state allows ready state changes
	if self.GameState == GameState.Starting or self.GameState == GameState.InProgress or self.GameState == GameState.Ended then
		print("[GameManager] Cannot ready up - game already " .. self.GameState:lower())
		return false
	end
	
	local playerInstance = self:GetPlayer(userId)
	if playerInstance then
		playerInstance:SetReady(isReady)
		self:CheckAllPlayersReady()
		return true
	else
		print("[GameManager] ERROR: Player instance not found for userId: " .. userId)
		return false
	end
end

-- Show loading screen to all players
function GameManager:ShowLoadingScreen(message)
	print("[GameManager] Showing loading screen: " .. (message or "Loading..."))
	Remotes.LoadingScreenShow.sendToAll({
		message = message or "Loading..."
	})
end

-- Hide loading screen from all players
function GameManager:HideLoadingScreen()
	print("[GameManager] Hiding loading screen")
	Remotes.LoadingScreenHide.sendToAll({})
end

-- Reset all players' cameras back to their characters
function GameManager:ResetAllPlayerCameras()
	print("[GameManager] Resetting all player cameras")
	for userId, playerInstance in pairs(self.Players) do
		local robloxPlayer = game.Players:GetPlayerByUserId(userId)
		if robloxPlayer then
			Remotes.SetCamera.sendTo({
				cameraType = "Custom"
			}, robloxPlayer)
		end
	end
end

-- Hide lobby UI from all players
function GameManager:HideLobbyUI()
	print("[GameManager] Hiding lobby UI")
	Remotes.LobbyUIHide.sendToAll({})
end

-- Unfreeze all players
function GameManager:UnfreezeAllPlayers()
	print("[GameManager] Unfreezing all players")
	for userId, playerInstance in pairs(self.Players) do
		playerInstance:Unfreeze()
	end
end

-- Handle PlayerReady remote
Remotes.PlayerReady.listen(function(data, player)
	GameManager:SetPlayerReady(player.UserId, data.isReady)
end)

-- Initialize player events
print("[GameManager] About to connect player events...")
GameManager:_connectPlayerEvents()
print("[GameManager] Player events connected successfully")

-- Connect to generator completion signal
Generator.GeneratorCompleted:Connect(function(generator)
	GameManager:OnGeneratorCompleted(generator)
end)
print("[GameManager] Connected to Generator completion signal")

return GameManager
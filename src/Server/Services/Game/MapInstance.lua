--[[
	MapInstance Module
	Handles cloning and instantiating maps from ReplicatedStorage into the game world
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Interactables = require(script.Parent.Interactables)

local MapInstance = {}
MapInstance.__index = MapInstance

-- Create a new MapInstance manager
function MapInstance.new()
	local self = setmetatable({}, MapInstance)
	self.currentMapInstance = nil
	self.interactablesManager = nil
	return self
end

-- Clone and instantiate a map from ReplicatedStorage
function MapInstance:LoadMap(mapName)
	if not mapName then
		warn("[MapInstance] No map name provided")
		return false
	end
	
	-- Clear existing map if any
	self:ClearCurrentMap()
	
	-- Find the map in ReplicatedStorage
	local mapsFolder = ReplicatedStorage:FindFirstChild("Maps")
	if not mapsFolder then
		warn("[MapInstance] Maps folder not found in ReplicatedStorage")
		return false
	end
	
	local mapModel = mapsFolder:FindFirstChild(mapName)
	if not mapModel then
		warn("[MapInstance] Map '" .. mapName .. "' not found in ReplicatedStorage.Maps")
		return false
	end
	
	print("[MapInstance] Loading map: " .. mapName)
	
	-- Clone the map
	local clonedMap = mapModel:Clone()
	clonedMap.Name = "CurrentMap"
	clonedMap.Parent = Workspace
	
	-- Store reference to current map
	self.currentMapInstance = clonedMap
	
	-- Initialize interactables for this map
	self:InitializeInteractables()
	
	print("[MapInstance] Successfully loaded map: " .. mapName)
	return true
end

-- Initialize interactables system for the current map
function MapInstance:InitializeInteractables()
	if not self.currentMapInstance then
		warn("[MapInstance] No current map instance to initialize interactables")
		return
	end
	
	-- Create and initialize interactables manager with the map instance
	self.interactablesManager = Interactables.new(self.currentMapInstance)
	self.interactablesManager:Initialize()
	
	print("[MapInstance] Interactables initialized for current map")
end

-- Clear the current map instance
function MapInstance:ClearCurrentMap()
	if self.currentMapInstance then
		print("[MapInstance] Clearing current map: " .. self.currentMapInstance.Name)
		self.currentMapInstance:Destroy()
		self.currentMapInstance = nil
	end
	
	-- Clean up interactables manager
	if self.interactablesManager then
		self.interactablesManager:Cleanup()
		self.interactablesManager = nil
	end
end

-- Get the current map instance
function MapInstance:GetCurrentMap()
	return self.currentMapInstance
end

-- Check if a map is currently loaded
function MapInstance:HasMapLoaded()
	return self.currentMapInstance ~= nil
end

-- Get available maps from ReplicatedStorage
function MapInstance:GetAvailableMaps()
	local availableMaps = {}
	local mapsFolder = ReplicatedStorage:FindFirstChild("Maps")
	
	if mapsFolder then
		for _, mapModel in ipairs(mapsFolder:GetChildren()) do
			if mapModel:IsA("Model") then
				table.insert(availableMaps, mapModel.Name)
			end
		end
	end
	
	return availableMaps
end

-- Get interactables manager for the current map
function MapInstance:GetInteractablesManager()
	return self.interactablesManager
end

-- Get spawn points for a specific role from the current map
function MapInstance:GetSpawnPoints(role)
	if not self.currentMapInstance then
		warn("[MapInstance] No current map instance to get spawn points from")
		return {}
	end
	
	local spawnPointsFolder = self.currentMapInstance:FindFirstChild("SpawnPoints")
	if not spawnPointsFolder then
		warn("[MapInstance] No SpawnPoints folder found in current map")
		return {}
	end
	
	local roleSpawnPoints = {}
	for _, spawnFolder in ipairs(spawnPointsFolder:GetChildren()) do
		if spawnFolder:IsA("Folder") then
			for _, spawnPoint in ipairs(spawnFolder:GetChildren()) do
				if spawnPoint.Name:lower():find(role:lower()) then
					table.insert(roleSpawnPoints, spawnPoint)
				end
			end
		end
	end
	
	return roleSpawnPoints
end

-- Teleport a player to a random spawn point based on their role
function MapInstance:TeleportPlayerToSpawn(player, role)
	if not player or not player.Character then
		warn("[MapInstance] Invalid player or no character to teleport")
		return false
	end
	
	local spawnPoints = self:GetSpawnPoints(role)
	if #spawnPoints == 0 then
		warn("[MapInstance] No spawn points found for role:", role)
		return false
	end
	
	-- Select a random spawn point
	local randomIndex = math.random(1, #spawnPoints)
	local selectedSpawn = spawnPoints[randomIndex]
	
	-- Get the spawn position
	local spawnPosition
	if selectedSpawn:IsA("Part") then
		spawnPosition = selectedSpawn.Position + Vector3.new(0, 5, 0) -- Offset to avoid clipping
	elseif selectedSpawn:IsA("Model") and selectedSpawn.PrimaryPart then
		spawnPosition = selectedSpawn.PrimaryPart.Position + Vector3.new(0, 5, 0)
	else
		warn("[MapInstance] Invalid spawn point type for:", selectedSpawn.Name)
		return false
	end
	
	-- Teleport the player
	local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
	if humanoidRootPart then
		humanoidRootPart.CFrame = CFrame.new(spawnPosition)
		print("[MapInstance] Teleported", player.Name, "to", role, "spawn point:", selectedSpawn.Name)
		return true
	else
		warn("[MapInstance] No HumanoidRootPart found for player:", player.Name)
		return false
	end
end

-- Teleport multiple players to spawn points based on their roles
function MapInstance:TeleportPlayers(playerRoleMap)
	if not self.currentMapInstance then
		warn("[MapInstance] No current map instance to teleport players")
		return false
	end
	
	local successCount = 0
	local totalPlayers = 0
	
	for player, role in pairs(playerRoleMap) do
		totalPlayers = totalPlayers + 1
		if self:TeleportPlayerToSpawn(player, role) then
			successCount = successCount + 1
		end
	end
	
	print("[MapInstance] Teleported", successCount, "out of", totalPlayers, "players")
	return successCount == totalPlayers
end

return MapInstance
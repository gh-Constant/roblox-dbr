--[[
	MapInstance Module
	Handles cloning and instantiating maps from ReplicatedStorage into the game world
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
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

return MapInstance
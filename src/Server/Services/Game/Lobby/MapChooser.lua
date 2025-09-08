--[[
	MapChooser Module
	Handles random map selection for games
]]

local Maps = require("@GameCommon/Maps")

local MapChooser = {}

-- Get all available maps from the Maps config
function MapChooser:_getAvailableMaps()
	local availableMaps = {}
	for mapName, mapFolder in pairs(Maps) do
		if mapFolder and mapFolder.Parent then -- Ensure the map exists in workspace
			table.insert(availableMaps, {
				name = mapName,
				folder = mapFolder
			})
		end
	end
	return availableMaps
end

-- Choose a random map from available maps
function MapChooser:ChooseRandomMap()
	local availableMaps = self:_getAvailableMaps()
	
	if #availableMaps == 0 then
		warn("[MapChooser] No available maps found!")
		return nil
	end
	
	-- Select random map
	local randomIndex = math.random(1, #availableMaps)
	local chosenMap = availableMaps[randomIndex]
	
	print("[MapChooser] Chosen map: " .. chosenMap.name)
	return chosenMap
end

-- Get a specific map by name
function MapChooser:GetMapByName(mapName)
	local mapFolder = Maps[mapName]
	if mapFolder and mapFolder.Parent then
		return {
			name = mapName,
			folder = mapFolder
		}
	end
	return nil
end

return MapChooser
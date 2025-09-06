local Remotes = require("@GameCommon/Remotes")
local GameManager = require(script.Parent.Parent.GameManager)

local ReadyService = {}

-- Check if all players are ready
local function checkAllPlayersReady()
	local allPlayers = GameManager:GetAllPlayers()
	local totalPlayers = 0
	local readyPlayers = 0
	
	for _, playerInstance in pairs(allPlayers) do
		totalPlayers = totalPlayers + 1
		if playerInstance:GetReady() then
			readyPlayers = readyPlayers + 1
		end
	end
	
	-- Check if we have enough players and all are ready
	if totalPlayers >= GameManager:GetExpectedPlayers() and readyPlayers == totalPlayers and totalPlayers > 0 then
		print("[ReadyService] All players ready - starting game")
		GameManager:StartGame()
		return true
	end
	
	return false
end

-- Handle PlayerReady remote
Remotes.PlayerReady.listen(function(data, player)
	-- Check if game state allows ready state changes
	local currentGameState = GameManager:GetGameState()
	if currentGameState == "Starting" or currentGameState == "InProgress" or currentGameState == "Ended" then
		print("[ReadyService] Cannot ready up - game already " .. currentGameState:lower())
		return
	end
	
	local playerInstance = GameManager:GetPlayer(player.UserId)
	if playerInstance then
		playerInstance:SetReady(data.isReady)
		checkAllPlayersReady()
	else
		print("[ReadyService] ERROR: Player instance not found for " .. player.Name)
	end
end)

return ReadyService
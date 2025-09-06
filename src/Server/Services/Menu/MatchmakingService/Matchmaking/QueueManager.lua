--!native
--!optimize 2
--!strict

local QueueManager = {}

local MemoryStoreService = game:GetService("MemoryStoreService")
local Players = game:GetService("Players")

local matchmakingMap = MemoryStoreService:GetSortedMap("MatchmakingMap")
local joinCooldowns = MemoryStoreService:GetSortedMap("JoinCooldowns")

local Config = require("@MenuCommon/Matchmaking/Config")



-- Get player's current role in queue
function QueueManager.getPlayerRole(player)
	-- Check if player is valid before accessing UserId
	if not player or typeof(player) ~= "Instance" or not player:IsA("Player") then
		return nil
	end
	
	local success, role = pcall(function()
		return matchmakingMap:GetAsync(tostring(player.UserId))
	end)
	
	if success and role then
		return role
	end
	
	return nil
end

function QueueManager.addPlayer(player, role)
	-- Check if player is valid before accessing UserId
	if not player or typeof(player) ~= "Instance" or not player:IsA("Player") then
		return
	end
	
	-- Check if player is already in queue
	local currentRole = QueueManager.getPlayerRole(player)
	if currentRole then
		-- If player is already in this queue, remove them (cancel queue)
		if currentRole == role then
			QueueManager.removePlayer(player)
			if Config.Debug.Matchmaking then
				print("[QueueManager] INFO: " .. player.Name .. " canceled their " .. role .. " queue")
			end
			return
		end
		
		-- If player is in a different queue, don't allow them to join this one
		if Config.Debug.Matchmaking then
			print("[QueueManager] INFO: " .. player.Name .. " is already in " .. currentRole .. " queue")
		end
		return
	end
	
	local lastJoinTime, err = joinCooldowns:GetAsync(tostring(player.UserId))
	if err then
		warn("[QueueManager] WARN: Failed to get last join time for " .. player.Name .. ":", err)
	end

	if lastJoinTime and os.time() - lastJoinTime < Config.Matchmaking.QueueCooldown then
		if Config.Debug.Matchmaking then
			print("[QueueManager] DEBUG: " .. player.Name .. " is on queue cooldown.")
		end
		return
	end

	local ok, err = pcall(function()
		matchmakingMap:SetAsync(tostring(player.UserId), role, 300)
		joinCooldowns:SetAsync(tostring(player.UserId), os.time(), 300)
	end)
	if Config.Debug.Matchmaking then
		if ok then
			print("[QueueManager] INFO: " .. player.Name .. " joined the " .. role .. " queue")
		else
			warn("[QueueManager] WARN: Failed to add to " .. role .. " queue:", err)
		end
	end
end

function QueueManager.removePlayer(player)
	-- Check if player is valid before accessing UserId
	if not player or typeof(player) ~= "Instance" or not player:IsA("Player") then
		return
	end
	
	pcall(function()
		matchmakingMap:RemoveAsync(tostring(player.UserId))
		if Config.Debug.Matchmaking then
			print("[QueueManager] INFO: " .. player.Name .. " removed from queue.")
		end
	end)
end

function QueueManager.getQueuedPlayers()
	local playersInQueue
	local success, result = pcall(function()
		playersInQueue = matchmakingMap:GetRangeAsync(Enum.SortDirection.Ascending, 200)
	end)

	if not success then
		warn("[QueueManager] WARN: Failed to get players from matchmaking map:", result)
		return {}, {}
	end

	local survivors = {}
	local killers = {}

	for _, item in ipairs(playersInQueue) do
		local userId = tonumber(item.key)
		if Players:GetPlayerByUserId(userId) then
			if item.value == "survivor" then
				table.insert(survivors, userId)
			elseif item.value == "killer" then
				table.insert(killers, userId)
			end
		else
			matchmakingMap:RemoveAsync(item.key)
			if Config.Debug.Matchmaking then
				print("[QueueManager] DEBUG: Removed offline player " .. item.key .. " from queue.")
			end
		end
	end

	return survivors, killers
end

return QueueManager

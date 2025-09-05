--!native
--!optimize 2
--!strict

local QueueManager = {}

local MemoryStoreService = game:GetService("MemoryStoreService")
local Players = game:GetService("Players")

local matchmakingMap = MemoryStoreService:GetSortedMap("MatchmakingMap")
local joinCooldowns = MemoryStoreService:GetSortedMap("JoinCooldowns")

local Config = require("@MenuCommon/Matchmaking/Config")

function QueueManager.addPlayer(player, role)
	local lastJoinTime, err = joinCooldowns:GetAsync(tostring(player.UserId))
	if err then
		warn("Failed to get last join time for " .. player.Name .. ":", err)
	end

	if lastJoinTime and os.time() - lastJoinTime < Config.Matchmaking.QueueCooldown then
		if Config.Debug.Matchmaking then
			print(player.Name .. " is on queue cooldown.")
		end
		return
	end

	local ok, err = pcall(function()
		matchmakingMap:SetAsync(tostring(player.UserId), role, 300)
		joinCooldowns:SetAsync(tostring(player.UserId), os.time(), 300)
	end)
	if Config.Debug.Matchmaking then
		if ok then
			print(player.Name .. " joined the " .. role .. " queue")
		else
			warn("Failed to add to " .. role .. " queue:", err)
		end
	end
end

function QueueManager.removePlayer(player)
	pcall(function()
		matchmakingMap:RemoveAsync(tostring(player.UserId))
		if Config.Debug.Matchmaking then
			print(player.Name .. " removed from queue due to disconnecting.")
		end
	end)
end

function QueueManager.getQueuedPlayers()
	local playersInQueue
	local success, result = pcall(function()
		playersInQueue = matchmakingMap:GetRangeAsync(Enum.SortDirection.Ascending, 200)
	end)

	if not success then
		warn("Failed to get players from matchmaking map:", result)
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
				print("Removed offline player " .. item.key .. " from queue.")
			end
		end
	end

	return survivors, killers
end

return QueueManager

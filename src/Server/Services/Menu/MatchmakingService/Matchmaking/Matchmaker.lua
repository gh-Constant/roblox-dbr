--!native
--!optimize 2
--!strict

local Matchmaker = {}

local MessagingService = game:GetService("MessagingService")
local TeleportService = game:GetService("TeleportService")

local matchmakingMap = game:GetService("MemoryStoreService"):GetSortedMap("MatchmakingMap")

local Config = require("@MenuCommon/Matchmaking/Config")



-- Constants moved to Config.lua

local function requeuePlayers(killers, survivors)
	for _, userId in ipairs(killers) do
		matchmakingMap:SetAsync(tostring(userId), "killer", 300)
	end
	for _, userId in ipairs(survivors) do
		matchmakingMap:SetAsync(tostring(userId), "survivor", 300)
	end
	if Config.Debug.Matchmaking then
		print("[Matchmaker] INFO: Re-queued players.")
	end
end

function Matchmaker.createMatch(killers, survivors, requiredKillers, requiredSurvivors)
	if Config.Debug.Matchmaking then
		print("[Matchmaker] INFO: Enough players available; creating a match...")
	end

	local matchKillers = {}
	for i = 1, requiredKillers do
		table.insert(matchKillers, table.remove(killers, 1))
	end

	local matchSurvivors = {}
	for i = 1, requiredSurvivors do
		table.insert(matchSurvivors, table.remove(survivors, 1))
	end

	local allPlayerIds = {}
	for _, userId in ipairs(matchKillers) do
		table.insert(allPlayerIds, userId)
		matchmakingMap:RemoveAsync(tostring(userId))
	end
	for _, userId in ipairs(matchSurvivors) do
		table.insert(allPlayerIds, userId)
		matchmakingMap:RemoveAsync(tostring(userId))
	end

	local success, privateServerCode = pcall(function()
		return TeleportService:ReserveServer(Config.Matchmaking.GamePlaceId)
	end)

	if not success then
		if game:GetService("RunService"):IsStudio() then
			warn("[Matchmaker] WARN: Impossible to use :ReserveServer in Studio")
		else
			warn("[Matchmaker] WARN: Failed to reserve server:", privateServerCode)
		end
		requeuePlayers(matchKillers, matchSurvivors)
		return
	end

	local message = {
		privateServerCode = privateServerCode,
		players = allPlayerIds,
	}

	local success, result = pcall(function()
		MessagingService:PublishAsync(Config.Matchmaking.TeleportTopic, message)
	end)

	if not success then
		warn("[Matchmaker] WARN: Failed to publish teleport message:", result)
		requeuePlayers(matchKillers, matchSurvivors)
	elseif Config.Debug.Matchmaking then
		print("[Matchmaker] INFO: Successfully published teleport message for players:", allPlayerIds)
	end
end

return Matchmaker

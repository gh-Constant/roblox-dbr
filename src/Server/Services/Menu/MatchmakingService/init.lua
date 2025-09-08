--!native
--!optimize 2
--!strict

local MatchmakingService = {}

local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local Remotes = require(ReplicatedStorage.Common.Menu.Matchmaking.Remotes)

local Matchmaker = require(script.Matchmaking.Matchmaker)
local QueueManager = require(script.Matchmaking.QueueManager)

local Config = require("@MenuCommon/Matchmaking/Config")
local CommonConfig = require("@Common/Config")

function MatchmakingService:Start()
	if Config.Debug.Matchmaking then
		print("[MatchmakingService] INFO: MatchmakingService started")
	end

	Remotes.JoinSurvivorQueue.listen(function(data, player)
		QueueManager.addPlayer(player, "survivor")
	end)

	Remotes.JoinKillerQueue.listen(function(data, player)
		QueueManager.addPlayer(player, "killer")
	end)

	Players.PlayerRemoving:Connect(function(player)
		QueueManager.removePlayer(player)
	end)

	task.spawn(function()
		while task.wait(Config.Matchmaking.MatchmakingCheckInterval) do
			if Config.Debug.Matchmaking then
				print("[MatchmakingService] DEBUG: Checking for matches...")
			end

			local survivors, killers = QueueManager.getQueuedPlayers()

			if Config.Debug.Matchmaking then
				print("[MatchmakingService] INFO: Survivor Queue Size: " .. #survivors)
				print("[MatchmakingService] INFO: Killer Queue Size: " .. #killers)
				print("[MatchmakingService] INFO: Server ID: " .. game.JobId)
			end
			if
				#killers >= CommonConfig.RequiredKillers
				and #survivors >= CommonConfig.RequiredSurvivors
			then
				Matchmaker.createMatch(
					killers,
					survivors,
					CommonConfig.RequiredKillers,
					CommonConfig.RequiredSurvivors
				)
			end
		end
	end)

	MessagingService:SubscribeAsync(Config.Matchmaking.TeleportTopic, function(message)
		local data = message.Data
		local privateServerCode = data.privateServerCode
		local playersToTeleport = data.players

		local playerObjects = {}
		for _, playerInfo in ipairs(playersToTeleport) do
			local player = Players:GetPlayerByUserId(playerInfo.userId)
			if player then
				table.insert(playerObjects, player)
			end
		end

		if #playerObjects > 0 then
			local success, result = pcall(function()
				return TeleportService:TeleportToPrivateServer(
					Config.Matchmaking.GamePlaceId,
					privateServerCode,
					playerObjects,
					nil,
					data
				)
			end)

			if not success then
				warn("[MatchmakingService] WARN: Failed to teleport players: " .. result)
			else
				if Config.Debug.Matchmaking then
					print("[MatchmakingService] INFO: Teleported players to private server.")
				end
			end
		end
	end)
end

return MatchmakingService

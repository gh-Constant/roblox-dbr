--!native
--!optimize 2
--!strict

local MatchmakingService = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Common.Menu.Matchmaking.Remotes)

local Matchmaker = require(script.Matchmaking.Matchmaker)
local QueueManager = require(script.Matchmaking.QueueManager)

local Config = require("@MenuCommon/Matchmaking/Config")



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
			end

			if
				#killers >= Config.Matchmaking.RequiredKillers
				and #survivors >= Config.Matchmaking.RequiredSurvivors
			then
				Matchmaker.createMatch(
					killers,
					survivors,
					Config.Matchmaking.RequiredKillers,
					Config.Matchmaking.RequiredSurvivors
				)
			end
		end
	end)
end

return MatchmakingService

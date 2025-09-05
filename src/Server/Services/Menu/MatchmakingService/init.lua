--!native
--!optimize 2
--!strict

local MatchmakingService = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Common.Menu.Matchmaking.Remotes)

local QueueManager = require(script.Matchmaking.QueueManager)
local Matchmaker = require(script.Matchmaking.Matchmaker)


local Config = require("@MenuCommon/Matchmaking/Config")

function MatchmakingService:Start()
	if Config.Debug.Matchmaking then
		print("MatchmakingService started")
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
				print("Checking for matches...")
			end

			local survivors, killers = QueueManager.getQueuedPlayers()

			if Config.Debug.Matchmaking then
				print("Survivor Queue Size: " .. #survivors)
				print("Killer Queue Size: " .. #killers)
			end

			if #killers >= Config.Matchmaking.RequiredKillers and #survivors >= Config.Matchmaking.RequiredSurvivors then
				Matchmaker.createMatch(killers, survivors, Config.Matchmaking.RequiredKillers, Config.Matchmaking.RequiredSurvivors)
			end
		end
	end)
end

return MatchmakingService

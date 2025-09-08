--!native
--!optimize 2
--!strict

local RemoteHandler = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Common.Menu.Matchmaking.Remotes)
local QueueManager = require(script.Parent.QueueManager)

local Config = require("@MenuCommon/Matchmaking/Config")

-- Initialize all remote event connections
function RemoteHandler.initialize()
	if Config.Debug.Matchmaking then
		print("[RemoteHandler] INFO: Initializing remote connections")
	end

	-- Handle survivor queue join requests
	Remotes.JoinSurvivorQueue.listen(function(data, player)
		QueueManager.addPlayer(player, "survivor")
	end)

	-- Handle killer queue join requests
	Remotes.JoinKillerQueue.listen(function(data, player)
		QueueManager.addPlayer(player, "killer")
	end)

	-- Handle player leaving to remove them from queues
	Players.PlayerRemoving:Connect(function(player)
		QueueManager.removePlayer(player)
	end)

	if Config.Debug.Matchmaking then
		print("[RemoteHandler] INFO: Remote connections established")
	end
end

return RemoteHandler
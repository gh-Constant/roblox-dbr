--!native
--!optimize 2
--!strict

local MatchmakingLoop = {}

local QueueManager = require(script.Parent.QueueManager)
local Matchmaker = require(script.Parent.Matchmaker)

local Config = require("@MenuCommon/Matchmaking/Config")
local CommonConfig = require("@Common/Config")

local isRunning = false
local loopThread = nil

-- Start the matchmaking loop
function MatchmakingLoop.start()
	if isRunning then
		if Config.Debug.Matchmaking then
			print("[MatchmakingLoop] WARN: Loop is already running")
		end
		return
	end

	isRunning = true

	if Config.Debug.Matchmaking then
		print("[MatchmakingLoop] INFO: Starting matchmaking loop")
	end

	loopThread = task.spawn(function()
		while isRunning do
			task.wait(Config.Matchmaking.MatchmakingCheckInterval)
			
			if not isRunning then
				break
			end

			if Config.Debug.Matchmaking then
				print("[MatchmakingLoop] DEBUG: Checking for matches...")
			end

			local survivors, killers = QueueManager.getQueuedPlayers()

			if Config.Debug.Matchmaking then
				print("[MatchmakingLoop] INFO: Survivor Queue Size: " .. #survivors)
				print("[MatchmakingLoop] INFO: Killer Queue Size: " .. #killers)
				print("[MatchmakingLoop] INFO: Server ID: " .. game.JobId)
			end

			-- Check if we have enough players for a match
			if #killers >= CommonConfig.RequiredKillers and #survivors >= CommonConfig.RequiredSurvivors then
				Matchmaker.createMatch(
					killers,
					survivors,
					CommonConfig.RequiredKillers,
					CommonConfig.RequiredSurvivors
				)
			end
		end
	end)
end

-- Stop the matchmaking loop
function MatchmakingLoop.stop()
	if not isRunning then
		if Config.Debug.Matchmaking then
			print("[MatchmakingLoop] WARN: Loop is not running")
		end
		return
	end

	isRunning = false

	if loopThread then
		task.cancel(loopThread)
		loopThread = nil
	end

	if Config.Debug.Matchmaking then
		print("[MatchmakingLoop] INFO: Matchmaking loop stopped")
	end
end

-- Check if the loop is currently running
function MatchmakingLoop.isRunning()
	return isRunning
end

return MatchmakingLoop
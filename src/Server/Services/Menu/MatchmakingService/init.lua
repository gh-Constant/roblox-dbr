--!native
--!optimize 2
--!strict

local MatchmakingService = {}

-- Import modules
local Network = require(script.Matchmaking.Network)
local MainLoop = require(script.Matchmaking.MainLoop)
local Teleport = require(script.Matchmaking.Teleport)

local Config = require("@MenuCommon/Matchmaking/Config")

-- Start the matchmaking service by initializing all modules
function MatchmakingService:Start()
	if Config.Debug.Matchmaking then
		print("[MatchmakingService] INFO: Starting MatchmakingService")
	end

	-- Initialize remote event handlers
	Network.initialize()

	-- Initialize teleport message handling
	Teleport.initialize()

	-- Start the matchmaking loop
	MainLoop.start()

	if Config.Debug.Matchmaking then
		print("[MatchmakingService] INFO: MatchmakingService started successfully")
	end
end

-- Stop the matchmaking service (optional cleanup method)
function MatchmakingService:Stop()
	if Config.Debug.Matchmaking then
		print("[MatchmakingService] INFO: Stopping MatchmakingService")
	end

	-- Stop the matchmaking loop
	MatchmakingLoop.stop()

	-- Cleanup teleport handler
	TeleportHandler.cleanup()

	if Config.Debug.Matchmaking then
		print("[MatchmakingService] INFO: MatchmakingService stopped")
	end
end

return MatchmakingService

--!native
--!optimize 2
--!strict

local TeleportHandler = {}

local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local Config = require("@MenuCommon/Matchmaking/Config")

local connection = nil

-- Initialize the teleport messaging service subscription
function TeleportHandler.initialize()
	if Config.Debug.Matchmaking then
		print("[TeleportHandler] INFO: Initializing teleport handler")
	end

	connection = MessagingService:SubscribeAsync(Config.Matchmaking.TeleportTopic, function(message)
		TeleportHandler.handleTeleportMessage(message)
	end)

	if Config.Debug.Matchmaking then
		print("[TeleportHandler] INFO: Subscribed to teleport topic: " .. Config.Matchmaking.TeleportTopic)
	end
end

-- Handle incoming teleport messages
function TeleportHandler.handleTeleportMessage(message)
	local data = message.Data
	local privateServerCode = data.privateServerCode
	local playersToTeleport = data.players

	if Config.Debug.Matchmaking then
		print("[TeleportHandler] INFO: Received teleport message for " .. #playersToTeleport .. " players")
	end

	-- Convert player info to actual player objects
	local playerObjects = {}
	for _, playerInfo in ipairs(playersToTeleport) do
		local player = Players:GetPlayerByUserId(playerInfo.userId)
		if player then
			table.insert(playerObjects, player)
			if Config.Debug.Matchmaking then
				print("[TeleportHandler] INFO: Found player " .. player.Name .. " for teleportation")
			end
		else
			if Config.Debug.Matchmaking then
				print("[TeleportHandler] WARN: Player with UserId " .. playerInfo.userId .. " not found")
			end
		end
	end

	-- Only teleport if we have players to teleport
	if #playerObjects > 0 then
		TeleportHandler.teleportPlayers(playerObjects, privateServerCode, data)
	else
		if Config.Debug.Matchmaking then
			print("[TeleportHandler] WARN: No valid players found for teleportation")
		end
	end
end

-- Teleport players to the private server
function TeleportHandler.teleportPlayers(playerObjects, privateServerCode, teleportData)
	local success, result = pcall(function()
		return TeleportService:TeleportToPrivateServer(
			Config.Matchmaking.GamePlaceId,
			privateServerCode,
			playerObjects,
			nil,
			teleportData
		)
	end)

	if not success then
		warn("[TeleportHandler] WARN: Failed to teleport players: " .. tostring(result))
	else
		if Config.Debug.Matchmaking then
			local playerNames = {}
			for _, player in ipairs(playerObjects) do
				table.insert(playerNames, player.Name)
			end
			print("[TeleportHandler] INFO: Successfully teleported players: " .. table.concat(playerNames, ", "))
		end
	end
end

-- Cleanup the teleport handler
function TeleportHandler.cleanup()
	if connection then
		connection:Disconnect()
		connection = nil
		if Config.Debug.Matchmaking then
			print("[TeleportHandler] INFO: Teleport handler cleaned up")
		end
	end
end

return TeleportHandler
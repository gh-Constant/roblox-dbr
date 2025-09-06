-- Game Runtime
local Config = require("@Common/Config")

if not game.PlaceId == Config.PlaceIds.Game then
	script.Disabled = true
	script.Name = "GameRuntime (DISABLED - NOT GAME PLACE)"
	return
end

local Players = game:GetService("Players")

local function printTable(t, indent, done)
	indent = indent or ""
	done = done or {}
	for k, v in pairs(t) do
		if type(v) == "table" and not done[v] then
			done[v] = true
			print(indent .. tostring(k) .. ":")
			printTable(v, indent .. "  ", done)
		else
			print(indent .. tostring(k) .. ": " .. tostring(v))
		end
	end
end

-- Initialize game services
require("@GameServices/GameManager")
require("@GameServices/Lobby/ReadyService")
require("@GameServices/Player/Interactables")
require("@GameServices/Libs/Cmdr")
require("@GameServices/Player/MovementRestrictions")
print("[GameRuntime] All services initialized successfully")

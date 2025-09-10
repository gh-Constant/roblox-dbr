--!strict

local ByteNet = require("@Packages/bytenet")

-- Define game packets using ByteNet
local Remotes = ByteNet.defineNamespace("Game", function()
	return {
		-- Player Ready System
		PlayerReady = ByteNet.definePacket({
			value = ByteNet.struct({
				isReady = ByteNet.bool
			})
		}),
		
		-- Camera System
		SetCamera = ByteNet.definePacket({
			value = ByteNet.struct({
				cameraType = ByteNet.string,
				cframe = ByteNet.optional(ByteNet.cframe)
			})
		}),
		
		-- Game State System
		GameStateChanged = ByteNet.definePacket({
			value = ByteNet.struct({
				gameState = ByteNet.string,
				mapName = ByteNet.optional(ByteNet.string),
				requiredGenerators = ByteNet.optional(ByteNet.uint8),
				completedGenerators = ByteNet.optional(ByteNet.uint8)
			})
		}),
		
		-- Generator System
		GeneratorCompleted = ByteNet.definePacket({
			value = ByteNet.struct({
				completed = ByteNet.uint8,
				remaining = ByteNet.uint8,
				required = ByteNet.uint8
			})
		}),
		
		-- Loading Screen System
		LoadingScreenShow = ByteNet.definePacket({
			value = ByteNet.struct({
				message = ByteNet.string
			})
		}),
		
		LoadingScreenHide = ByteNet.definePacket({
			value = ByteNet.struct({})
		}),
		
		-- Lobby UI System
		LobbyUIHide = ByteNet.definePacket({
			value = ByteNet.struct({})
		})
	}
end)

return Remotes
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
				mapName = ByteNet.optional(ByteNet.string)
			})
		})
	}
end)

return Remotes
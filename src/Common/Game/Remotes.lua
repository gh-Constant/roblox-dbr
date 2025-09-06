--!strict

local ByteNet = require(script.Parent.Parent.Parent.Packages.bytenet)

-- Define game packets using ByteNet
local Remotes = ByteNet.defineNamespace("Game", function()
	return {
		-- Player Ready System
		PlayerReady = ByteNet.definePacket({
			isReady = ByteNet.bool
		})
	}
end)

return Remotes
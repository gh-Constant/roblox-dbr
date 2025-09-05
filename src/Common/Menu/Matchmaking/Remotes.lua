--!strict

local ByteNet = require(script.Parent.Parent.Parent.Parent.Packages.bytenet)

-- Define matchmaking packets using ByteNet
local Remotes = ByteNet.defineNamespace("Matchmaking", function()
	return {
		JoinKillerQueue = ByteNet.definePacket({
			value = ByteNet.nothing -- Empty packet for simple queue join request
		}),
		
		JoinSurvivorQueue = ByteNet.definePacket({
			value = ByteNet.nothing -- Empty packet for simple queue join request
		})
	}
end)

return Remotes
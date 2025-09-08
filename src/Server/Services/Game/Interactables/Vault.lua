-- Vault interactable class
local Vault = {}
Vault.__index = Vault

-- Create a new Vault instance
function Vault.new(obj)
	local self = setmetatable({}, Vault)
	self.object = obj
	return self
end

-- Get the action text for the proximity prompt
function Vault:GetActionText()
	return "Vault"
end

-- Get the object text for the proximity prompt
function Vault:GetObjectText()
	return "Window"
end

-- Get the maximum interaction distance
function Vault:GetMaxDistance()
	return 7
end

-- Handle interaction with the vault
function Vault:OnInteract(player)
	print(player.Name .. " interacted with vault:", self.object.Name)
	-- TODO: Vault animation / teleport
end

-- Clean up the vault instance
function Vault:Destroy()
	-- Clean up any connections or resources if needed
	self.object = nil
end

return Vault
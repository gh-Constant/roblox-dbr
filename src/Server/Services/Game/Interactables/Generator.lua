-- Generator interactable class
local Generator = {}
Generator.__index = Generator

-- Create a new Generator instance
function Generator.new(obj)
	local self = setmetatable({}, Generator)
	self.object = obj
	self.progress = 0
	self.isBeingRepaired = false
	return self
end

-- Get the action text for the proximity prompt
function Generator:GetActionText()
	if self.progress >= 100 then
		return "Powered"
	else
		return "Repair"
	end
end

-- Get the object text for the proximity prompt
function Generator:GetObjectText()
	return "Generator"
end

-- Get the maximum interaction distance
function Generator:GetMaxDistance()
	return 8
end

-- Handle interaction with the generator
function Generator:OnInteract(player)
	if self.progress >= 100 then
		print("Generator is already powered!")
		return
	end
	
	if self.isBeingRepaired then
		print("Generator is already being repaired!")
		return
	end
	
	print(player.Name .. " started repairing generator:", self.object.Name)
	self.isBeingRepaired = true
	
	-- TODO: Implement generator repair minigame
	-- For now, just simulate progress
	self.progress = math.min(100, self.progress + 25)
	print("Generator progress:", self.progress .. "%")
	
	self.isBeingRepaired = false
end

-- Get the current repair progress
function Generator:GetProgress()
	return self.progress
end

-- Check if the generator is fully powered
function Generator:IsPowered()
	return self.progress >= 100
end

-- Clean up the generator instance
function Generator:Destroy()
	-- Clean up any connections or resources if needed
	self.object = nil
end

return Generator
-- Generator interactable class
local Signal = require(game.ReplicatedStorage.Packages.Signal)

local Generator = {}
Generator.__index = Generator

-- Static signal for generator completion (shared across all generators)
Generator.GeneratorCompleted = Signal.new()

-- Create a new Generator instance
function Generator.new(obj)
	local self = setmetatable({}, Generator)
	self.object = obj
	self.progress = 0
	self.isBeingRepaired = false
	self.isCompleted = false
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
	local oldProgress = self.progress
	self.progress = math.min(100, self.progress + 25)
	print("Generator progress:", self.progress .. "%")
	
	-- Check if generator was just completed
	if oldProgress < 100 and self.progress >= 100 and not self.isCompleted then
		self.isCompleted = true
		print("Generator completed! Firing signal...")
		-- Fire the static signal to notify GameManager
		Generator.GeneratorCompleted:Fire(self)
	end
	
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
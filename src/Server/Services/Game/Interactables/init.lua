local CollectionService = game:GetService("CollectionService")

-- Import interactable subclasses
local Pallet = require(script.Pallet)
local Vault = require(script.Vault)
local Generator = require(script.Generator)

-- Main Interactables class
local Interactables = {}
Interactables.__index = Interactables

-- Registry of interactable types and their corresponding classes
local interactableTypes = {
	Pallet = Pallet,
	Vault = Vault,
	Generator = Generator,
}

-- Create a new Interactables manager instance
function Interactables.new()
	local self = setmetatable({}, Interactables)
	self.activeInteractables = {}
	return self
end

-- Setup an interactable object with its corresponding class
function Interactables:setupInteractable(obj, tagName)
	local interactableClass = interactableTypes[tagName]
	if not interactableClass then
		warn("No interactable class defined for tag:", tagName)
		return
	end
	
	if obj:FindFirstChild("InteractPrompt") then return end
	
	-- Create the interactable instance
	local interactableInstance = interactableClass.new(obj)
	self.activeInteractables[obj] = interactableInstance
	
	-- Setup the proximity prompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "InteractPrompt"
	prompt.ActionText = interactableInstance:GetActionText()
	prompt.ObjectText = interactableInstance:GetObjectText()
	prompt.MaxActivationDistance = interactableInstance:GetMaxDistance()
	prompt.Parent = obj
	prompt.KeyboardKeyCode = Enum.KeyCode.Space
	
	prompt.Triggered:Connect(function(player)
		interactableInstance:OnInteract(player)
	end)
end

-- Initialize all interactables in the game
function Interactables:Initialize()
	for tagName, _ in pairs(interactableTypes) do
		-- Setup existing objects
		for _, obj in ipairs(CollectionService:GetTagged(tagName)) do
			self:setupInteractable(obj, tagName)
		end
		
		-- Listen for new objects
		CollectionService:GetInstanceAddedSignal(tagName):Connect(function(obj)
			self:setupInteractable(obj, tagName)
		end)
		
		-- Clean up removed objects
		CollectionService:GetInstanceRemovedSignal(tagName):Connect(function(obj)
			if self.activeInteractables[obj] then
				self.activeInteractables[obj]:Destroy()
				self.activeInteractables[obj] = nil
			end
		end)
	end
end

-- Export the Interactables class for external initialization
return Interactables

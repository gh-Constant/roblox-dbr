local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Pallet interactable class
local Pallet = {}
Pallet.__index = Pallet

-- Create a new Pallet instance
function Pallet.new(obj)
	local self = setmetatable({}, Pallet)
	self.object = obj
	return self
end

-- Get the action text for the proximity prompt
function Pallet:GetActionText()
	if self.object:GetAttribute("Downed") then
		return "Vault"
	else
		return "Drop"
	end
end

-- Get the object text for the proximity prompt
function Pallet:GetObjectText()
	return "Pallet"
end

-- Get the maximum interaction distance
function Pallet:GetMaxDistance()
	return 7
end

-- Handle interaction with the pallet
function Pallet:OnInteract(player)
	if self.object:GetAttribute("Downed") then
		print("Vaulting pallet")
		-- TODO: Implement vault logic
		return
	end

	self.object:SetAttribute("Downed", true)

	-- Make DownedCollision collidable
	local downedCollision = self.object.Parent:FindFirstChild("DownedCollision")
	if downedCollision and downedCollision:IsA("BasePart") then
		downedCollision.CanCollide = true
	end

	-- New example start and end CFrames
	local exampleStartCFrame = CFrame.new(17.791, 4.51, 92.22) *
		CFrame.Angles(math.rad(0), math.rad(90), math.rad(78))
	local exampleEndCFrame = CFrame.new(17.791, 2.808, 95.113) *
		CFrame.Angles(math.rad(0), math.rad(90), math.rad(147))

	-- Compute the relative delta CFrame
	local deltaCFrame = exampleStartCFrame:Inverse() * exampleEndCFrame

	-- Apply the same delta to the current pallet
	local goalCFrame = self.object.CFrame * deltaCFrame

	-- Tween to the goal CFrame
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(self.object, tweenInfo, {CFrame = goalCFrame})
	tween:Play()

	-- Play drop sound
	local sound = ReplicatedStorage:WaitForChild("Sounds"):WaitForChild("Pallet"):WaitForChild("Drop"):Clone()
	sound.Parent = self.object
	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)

	print(player.Name .. " dropped pallet:", self.object.Name)
end

-- Clean up the pallet instance
function Pallet:Destroy()
	-- Clean up any connections or resources if needed
	self.object = nil
end

return Pallet
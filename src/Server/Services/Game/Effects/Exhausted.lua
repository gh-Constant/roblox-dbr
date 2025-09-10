--[[
	Exhausted Effect Class
	Prevents the use of exhaustion perks for a specified duration
]]

local Exhausted = {}
Exhausted.__index = Exhausted

-- Exhausted specific configuration
local EXHAUSTED_CONFIG = {
	defaultDuration = 60, -- seconds
	preventExhaustionPerks = true,
	regressOnlyWhenNotRunning = true,
}

-- Constructor
function Exhausted.new(owner, duration)
	local self = setmetatable({}, Exhausted)
	
	self.owner = owner
	self.effectType = "Exhausted"
	self.duration = duration or EXHAUSTED_CONFIG.defaultDuration
	self.remainingTime = self.duration
	self.lastUpdateTime = tick()
	self.isActive = false
	self.isPlayerRunning = false
	
	print("[Exhausted] Created Exhausted effect for player: " .. (owner and owner.Name or "Unknown") .. " Duration: " .. self.duration .. "s")
	
	return self
end

-- Effect lifecycle methods
function Exhausted:Apply()
	self.isActive = true
	self.lastUpdateTime = tick()
	self.remainingTime = self.duration
	
	-- Start monitoring player running state
	self:_startRunningMonitor()
	
	print("[Exhausted] Applied Exhausted effect to: " .. self.owner.Name)
end

function Exhausted:Remove()
	self.isActive = false
	self.remainingTime = 0
	
	print("[Exhausted] Removed Exhausted effect from: " .. self.owner.Name)
end

function Exhausted:Update()
	if not self.isActive then
		return false
	end
	
	local currentTime = tick()
	local deltaTime = currentTime - self.lastUpdateTime
	self.lastUpdateTime = currentTime
	
	-- Only reduce exhaustion time when not running
	if not self.isPlayerRunning then
		self.remainingTime = self.remainingTime - deltaTime
		if self.remainingTime <= 0 then
			self:Remove()
			return false -- Effect expired
		end
	end
	
	return true -- Effect still active
end

-- Exhausted specific methods
function Exhausted:CanUseExhaustionPerk()
	return not (self.isActive and EXHAUSTED_CONFIG.preventExhaustionPerks)
end

function Exhausted:SetPlayerRunning(isRunning)
	self.isPlayerRunning = isRunning
end

function Exhausted:_startRunningMonitor()
	-- This would typically connect to player movement events
	-- For now, it's a placeholder that can be extended
	spawn(function()
		while self.isActive do
			wait(0.1) -- Check every 0.1 seconds
			self:Update()
		end
	end)
end

function Exhausted:ExtendDuration(additionalTime)
	if self.isActive then
		self.duration = self.duration + additionalTime
		print("[Exhausted] Extended Exhausted duration by " .. additionalTime .. "s")
	end
end

function Exhausted:ReduceDuration(reductionTime)
	if self.isActive then
		self.duration = math.max(0, self.duration - reductionTime)
		print("[Exhausted] Reduced Exhausted duration by " .. reductionTime .. "s")
		
		-- Check if effect should end immediately
		local elapsed = tick() - self.startTime
		if elapsed >= self.duration then
			self:Remove()
		end
	end
end

-- Effect information
function Exhausted:GetEffectInfo()
	return {
		name = "Exhausted",
		description = "Cannot use exhaustion perks. Exhaustion only recovers when not running.",
		category = "Debuff",
		duration = self.duration,
		remaining = self:GetRemainingTime(),
		preventExhaustionPerks = EXHAUSTED_CONFIG.preventExhaustionPerks,
		regressOnlyWhenNotRunning = EXHAUSTED_CONFIG.regressOnlyWhenNotRunning
	}
end

-- Getters
function Exhausted:IsActive()
	return self.isActive
end

function Exhausted:GetRemainingTime()
	if not self.isActive then
		return 0
	end
	
	return math.max(0, self.remainingTime)
end

function Exhausted:GetOwner()
	return self.owner
end

function Exhausted:IsPlayerRunning()
	return self.isPlayerRunning
end

return Exhausted
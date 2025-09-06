--[[
	QueueService
	Handles queue logic for survivor and killer roles
]]

local QueueService = {}

-- Queue states
local QueueState = {
	Idle = "Idle",
	Queuing = "Queuing",
	InGame = "InGame"
}

-- Current queue information
local currentQueue = {
	state = QueueState.Idle,
	role = nil,
	startTime = nil
}

-- Queue for survivor role
function QueueService.QueueAsSurvivor()
	if currentQueue.state ~= QueueState.Idle then
		warn("Already in queue or in game!")
		return false
	end
	
	currentQueue.state = QueueState.Queuing
	currentQueue.role = "Survivor"
	currentQueue.startTime = tick()
	
	print("🏃 Queuing as Survivor...")
	
	-- TODO: Send queue request to server
	-- This is where you would implement actual matchmaking logic
	
	return true
end

-- Queue for killer role
function QueueService.QueueAsKiller()
	if currentQueue.state ~= QueueState.Idle then
		warn("Already in queue or in game!")
		return false
	end
	
	currentQueue.state = QueueState.Queuing
	currentQueue.role = "Killer"
	currentQueue.startTime = tick()
	
	print("🔪 Queuing as Killer...")
	
	-- TODO: Send queue request to server
	-- This is where you would implement actual matchmaking logic
	
	return true
end

-- Cancel current queue
function QueueService.CancelQueue()
	if currentQueue.state ~= QueueState.Queuing then
		warn("Not currently in queue!")
		return false
	end
	
	print("❌ Queue cancelled")
	
	currentQueue.state = QueueState.Idle
	currentQueue.role = nil
	currentQueue.startTime = nil
	
	return true
end

-- Get current queue status
function QueueService.GetQueueStatus()
	return {
		state = currentQueue.state,
		role = currentQueue.role,
		queueTime = currentQueue.startTime and (tick() - currentQueue.startTime) or 0
	}
end

-- Check if currently queuing
function QueueService.IsQueuing()
	return currentQueue.state == QueueState.Queuing
end

return QueueService
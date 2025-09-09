local GameConfig = {
	-- Generator Settings
	Generators = {
		TotalGenerators = 7, -- Total generators on the map
		RequiredGenerators = 5, -- Generators needed to power exit gates
		RepairTime = 80, -- Base time in seconds to repair a generator
		SkillCheckChance = 0.08, -- Chance per second for skill check to appear
		SkillCheckWindow = 1.5, -- Time window for skill check success
	},
	
	-- Hook Settings
	Hooks = {
		MaxHookStages = 3, -- 0 = never hooked, 1 = first hook, 2 = second hook, 3 = death
		HookStageTime = 60, -- Time in seconds per hook stage
		StruggleTime = 60, -- Time to struggle out of killer's grasp
	},
	
	-- Game Balance
	Balance = {
		SurvivorSpeed = 4, -- Base survivor movement speed
		KillerSpeed = 4.6, -- Base killer movement speed
		HeartbeatRadius = 32, -- Distance at which survivors hear heartbeat
		TerrorRadius = 32, -- Killer's terror radius
	},
	
	-- Match Settings
	Match = {
		MaxMatchTime = 1200, -- 20 minutes maximum match time
		EndGameCollapseTime = 120, -- 2 minutes for end game collapse
		ExitGateOpenTime = 20, -- Time to open exit gate
	}
}

return GameConfig
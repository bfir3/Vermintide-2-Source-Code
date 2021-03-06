BTConditions.can_activate = BTConditions.can_activate or {}
local unit_alive = Unit.alive
local ScriptUnit = ScriptUnit
BTConditions.can_activate.dr_ironbreaker = function (blackboard)
	local self_unit = blackboard.unit
	local self_position = POSITION_LOOKUP[self_unit]
	local proximite_enemies = blackboard.proximite_enemies
	local num_proximite_enemies = #proximite_enemies
	local max_distance_sq = 64
	local threat_threshold = 15
	local total_threat_value = 0

	for i = 1, num_proximite_enemies, 1 do
		local enemy_unit = proximite_enemies[i]
		local enemy_position = POSITION_LOOKUP[enemy_unit]

		if unit_alive(enemy_unit) and Vector3.distance_squared(self_position, enemy_position) <= max_distance_sq then
			local enemy_blackboard = BLACKBOARDS[enemy_unit]
			local enemy_breed = enemy_blackboard.breed
			local is_targeting_bot = enemy_blackboard.target_unit == self_unit
			local threat_value = enemy_breed.threat_value * ((is_targeting_bot and 1.25) or 1)
			total_threat_value = total_threat_value + threat_value

			if threat_threshold <= total_threat_value then
				return true
			end
		end
	end

	return false
end
BTConditions.can_activate.dr_slayer = function (blackboard)
	local locomotion_extension = blackboard.locomotion_extension
	local is_on_ground = locomotion_extension.is_on_ground(locomotion_extension)

	if not is_on_ground then
		return false
	end

	local self_unit = blackboard.unit
	local self_position = POSITION_LOOKUP[self_unit]
	local target_unit = blackboard.target_unit
	local target_blackboard = BLACKBOARDS[target_unit]
	local target_breed = target_blackboard and target_blackboard.breed
	local target_threat_value = (target_breed and target_breed.threat_value) or 0
	local target_ally_unit = blackboard.target_ally_unit
	local target_ally_need_type = blackboard.target_ally_need_type
	local ai_bot_group_system = Managers.state.entity:system("ai_bot_group_system")
	local is_prioritized = ai_bot_group_system.is_prioritized_ally(ai_bot_group_system, self_unit, target_ally_unit)
	local leap_target, leap_target_distance_sq = nil

	if is_prioritized and (target_ally_need_type == "knocked_down" or target_ally_need_type == "hook") then
		leap_target = target_ally_unit
		leap_target_distance_sq = blackboard.ally_distance^2
	elseif target_unit and 8 <= target_threat_value then
		local target_position = POSITION_LOOKUP[target_unit]
		leap_target = target_unit
		leap_target_distance_sq = Vector3.distance_squared(self_position, target_position)
	end

	local min_leap_distance_sq = 49
	local max_leap_distance_sq = 100

	if leap_target and min_leap_distance_sq < leap_target_distance_sq and leap_target_distance_sq < max_leap_distance_sq then
		local leap_target_position = POSITION_LOOKUP[leap_target]
		local leap_target_direction = Vector3.normalize(leap_target_position - self_position)
		local check_position = leap_target_position + leap_target_direction * 0.5
		local nav_world = blackboard.nav_world
		local success = LocomotionUtils.ray_can_go_on_mesh(nav_world, self_position, check_position, nil, 1, 1)

		if success then
			blackboard.activate_ability_data.aim_position:store(leap_target_position)

			return true
		end
	end

	return false
end
BTConditions.can_activate.dr_ranger = function (blackboard)
	local self_unit = blackboard.unit
	local target_ally_unit = blackboard.target_ally_unit
	local ai_bot_group_system = Managers.state.entity:system("ai_bot_group_system")
	local is_prioritized = ai_bot_group_system.is_prioritized_ally(ai_bot_group_system, self_unit, target_ally_unit)
	local ally_distance = blackboard.ally_distance
	local self_position = POSITION_LOOKUP[self_unit]
	local proximite_enemies = blackboard.proximite_enemies
	local num_proximite_enemies = #proximite_enemies
	local max_distance_sq = 25
	local total_threat_value = 0
	local threat_threshold = (is_prioritized and ally_distance < 5 and 5) or 12
	local current_health_percent = blackboard.health_extension:current_health_percent()
	local is_wounded = blackboard.status_extension:is_wounded()
	local health_multiplier = 2 - ((is_wounded and 0) or current_health_percent)

	for i = 1, num_proximite_enemies, 1 do
		local enemy_unit = proximite_enemies[i]
		local enemy_position = POSITION_LOOKUP[enemy_unit]

		if unit_alive(enemy_unit) and Vector3.distance_squared(self_position, enemy_position) <= max_distance_sq then
			local enemy_blackboard = BLACKBOARDS[enemy_unit]
			local enemy_breed = enemy_blackboard.breed
			local is_targeting_bot = enemy_blackboard.target_unit == self_unit
			local threat_value = enemy_breed.threat_value * (health_multiplier + ((is_targeting_bot and 0.25) or 0))
			total_threat_value = total_threat_value + threat_value

			if threat_threshold <= total_threat_value then
				return true
			end
		end
	end

	return false
end
BTConditions.can_activate.es_mercenary = function (blackboard)
	local self_unit = blackboard.unit
	local self_position = POSITION_LOOKUP[self_unit]
	local max_ally_distance_sq = 225
	local num_players_within_range = 0
	local PLAYER_AND_BOT_UNITS = PLAYER_AND_BOT_UNITS
	local num_players = #PLAYER_AND_BOT_UNITS

	for i = 1, num_players, 1 do
		local player_unit = PLAYER_AND_BOT_UNITS[i]
		local player_position = POSITION_LOOKUP[player_unit]
		local distance_squared = Vector3.distance_squared(self_position, player_position)

		if player_unit ~= self_unit and distance_squared < max_ally_distance_sq then
			num_players_within_range = num_players_within_range + 1
		end
	end

	local near_players_percentage = nil
	local num_players_except_self = num_players - 1

	if num_players_except_self == 0 then
		near_players_percentage = 0.5
	else
		near_players_percentage = num_players_within_range / num_players_except_self
	end

	local proximite_enemies = blackboard.proximite_enemies
	local num_proximite_enemies = #proximite_enemies
	local max_threat_distance_sq = 49
	local total_threat_value = 0
	local threat_threshold = math.max(20 * (1 - near_players_percentage), 8)
	local current_health_percent = blackboard.health_extension:current_health_percent()
	local is_wounded = blackboard.status_extension:is_wounded()
	local health_multiplier = 2 - ((is_wounded and 0) or current_health_percent)

	for i = 1, num_proximite_enemies, 1 do
		local enemy_unit = proximite_enemies[i]
		local enemy_position = POSITION_LOOKUP[enemy_unit]

		if unit_alive(enemy_unit) and Vector3.distance_squared(self_position, enemy_position) <= max_threat_distance_sq then
			local enemy_blackboard = BLACKBOARDS[enemy_unit]
			local enemy_breed = enemy_blackboard.breed
			local is_targeting_bot = enemy_blackboard.target_unit == self_unit
			local threat_value = enemy_breed.threat_value * (health_multiplier + ((is_targeting_bot and 0.25) or 0))
			total_threat_value = total_threat_value + threat_value

			if threat_threshold <= total_threat_value then
				return true
			end
		end
	end

	return false
end
BTConditions.can_activate.es_huntsman = function (blackboard)
	local proximite_enemies = blackboard.proximite_enemies
	local num_proximite_enemies = #proximite_enemies
	local target_unit = blackboard.target_unit

	if num_proximite_enemies == 0 and target_unit == nil then
		return false
	end

	local self_unit = blackboard.unit
	local self_position = POSITION_LOOKUP[self_unit]
	local target_blackboard = BLACKBOARDS[target_unit]
	local target_breed = target_blackboard and target_blackboard.breed
	local target_threat_value = (target_breed and target_breed.threat_value) or 0
	local target_ally_unit = blackboard.target_ally_unit
	local target_ally_need_type = blackboard.target_ally_need_type
	local ai_bot_group_system = Managers.state.entity:system("ai_bot_group_system")
	local is_prioritized = ai_bot_group_system.is_prioritized_ally(ai_bot_group_system, self_unit, target_ally_unit)
	local health_extension = blackboard.health_extension
	local current_health_percent = health_extension.current_health_percent(health_extension)
	local is_wounded = blackboard.status_extension:is_wounded()

	if is_prioritized and (target_ally_need_type == "knocked_down" or target_ally_need_type == "hook" or target_ally_need_type == "ledge") then
		return true
	elseif current_health_percent < 0.4 or is_wounded then
		return true
	elseif target_unit and 8 <= target_threat_value then
		return true
	end

	return false
end
BTConditions.can_activate.es_knight = function (blackboard)
	local self_unit = blackboard.unit
	local self_position = POSITION_LOOKUP[self_unit]
	local target_unit = blackboard.target_unit
	local target_blackboard = BLACKBOARDS[target_unit]
	local target_breed = target_blackboard and target_blackboard.breed
	local target_threat_value = (target_breed and target_breed.threat_value) or 0
	local target_ally_unit = blackboard.target_ally_unit
	local target_ally_need_type = blackboard.target_ally_need_type
	local ai_bot_group_system = Managers.state.entity:system("ai_bot_group_system")
	local is_prioritized = ai_bot_group_system.is_prioritized_ally(ai_bot_group_system, self_unit, target_ally_unit)
	local charge_target, charge_target_distance_sq = nil

	if is_prioritized and (target_ally_need_type == "knocked_down" or target_ally_need_type == "hook") then
		charge_target = target_ally_unit
		charge_target_distance_sq = blackboard.ally_distance^2
	elseif target_unit and 5 <= target_threat_value then
		local target_position = POSITION_LOOKUP[target_unit]
		charge_target = target_unit
		charge_target_distance_sq = Vector3.distance_squared(self_position, target_position)
	end

	local min_distance_sq = 81
	local max_distance = 12
	local max_distance_sq = 144

	if charge_target and min_distance_sq < charge_target_distance_sq and charge_target_distance_sq < max_distance_sq then
		local charge_target_position = POSITION_LOOKUP[charge_target]
		local charge_target_direction = Vector3.normalize(charge_target_position - self_position)
		local check_position = self_position + charge_target_direction * (max_distance + 2)
		local nav_world = blackboard.nav_world
		local success = LocomotionUtils.ray_can_go_on_mesh(nav_world, self_position, check_position, nil, 1, 1)

		if success then
			blackboard.activate_ability_data.aim_position:store(charge_target_position)

			return true
		end
	end

	return false
end
BTConditions.can_activate.we_waywatcher = function (blackboard, can_use_ranged_shot_ability)
	if not can_use_ranged_shot_ability then
		return false
	end

	local target = blackboard.target_unit

	if not unit_alive(target) then
		return false
	end

	local max_distance = 30
	local is_range_ok = (target == blackboard.priority_target_enemy and blackboard.priority_target_distance <= max_distance) or (target == blackboard.urgent_target_enemy and blackboard.urgent_target_distance <= max_distance) or (target == blackboard.opportunity_target_enemy and blackboard.opportunity_target_distance <= max_distance)

	if is_range_ok then
		local obstruction = blackboard.ranged_obstruction_by_static
		local t = Managers.time:time("game")
		local obstructed = obstruction and obstruction.unit == target and obstruction.timer + 3 < t

		return not obstructed
	else
		return false
	end

	return 
end
BTConditions.can_activate.we_maidenguard = function (blackboard)
	local self_unit = blackboard.unit
	local self_position = POSITION_LOOKUP[self_unit]
	local target_unit = blackboard.target_unit
	local target_blackboard = BLACKBOARDS[target_unit]
	local target_breed = target_blackboard and target_blackboard.breed
	local target_threat_value = (target_breed and target_breed.threat_value) or 0
	local target_ally_unit = blackboard.target_ally_unit
	local target_ally_need_type = blackboard.target_ally_need_type
	local ai_bot_group_system = Managers.state.entity:system("ai_bot_group_system")
	local is_prioritized = ai_bot_group_system.is_prioritized_ally(ai_bot_group_system, self_unit, target_ally_unit)
	local dash_target, dash_target_distance_sq = nil

	if is_prioritized and (target_ally_need_type == "knocked_down" or target_ally_need_type == "hook") then
		dash_target = target_ally_unit
		dash_target_distance_sq = blackboard.ally_distance^2
	elseif target_unit and 5 <= target_threat_value then
		local target_position = POSITION_LOOKUP[target_unit]
		dash_target = target_unit
		dash_target_distance_sq = Vector3.distance_squared(self_position, target_position)
	end

	local min_distance_sq = 81
	local max_distance = 12
	local max_distance_sq = 144

	if dash_target and min_distance_sq < dash_target_distance_sq and dash_target_distance_sq < max_distance_sq then
		local dash_target_position = POSITION_LOOKUP[dash_target]
		local dash_target_direction = Vector3.normalize(dash_target_position - self_position)
		local check_position = self_position + dash_target_direction * (max_distance + 2)
		local nav_world = blackboard.nav_world
		local success = LocomotionUtils.ray_can_go_on_mesh(nav_world, self_position, check_position, nil, 1, 1)

		if success then
			blackboard.activate_ability_data.aim_position:store(dash_target_position)

			return true
		end
	end

	return false
end
BTConditions.can_activate.we_shade = function (blackboard)
	local proximite_enemies = blackboard.proximite_enemies
	local num_proximite_enemies = #proximite_enemies
	local target_unit = blackboard.target_unit

	if num_proximite_enemies == 0 and target_unit == nil then
		return false
	end

	local self_unit = blackboard.unit
	local self_position = POSITION_LOOKUP[self_unit]
	local target_blackboard = BLACKBOARDS[target_unit]
	local target_breed = target_blackboard and target_blackboard.breed
	local target_threat_value = (target_breed and target_breed.threat_value) or 0
	local target_ally_unit = blackboard.target_ally_unit
	local target_ally_need_type = blackboard.target_ally_need_type
	local ai_bot_group_system = Managers.state.entity:system("ai_bot_group_system")
	local is_prioritized = ai_bot_group_system.is_prioritized_ally(ai_bot_group_system, self_unit, target_ally_unit)
	local health_extension = blackboard.health_extension
	local current_health_percent = health_extension.current_health_percent(health_extension)
	local is_wounded = blackboard.status_extension:is_wounded()

	if is_prioritized and (target_ally_need_type == "knocked_down" or target_ally_need_type == "hook" or target_ally_need_type == "ledge") then
		return true
	elseif current_health_percent < 0.4 or is_wounded then
		return true
	elseif target_unit and 8 <= target_threat_value then
		return true
	end

	return false
end
BTConditions.can_activate.wh_captain = function (blackboard)
	local self_unit = blackboard.unit
	local self_position = POSITION_LOOKUP[self_unit]
	local max_ally_distance_sq = 100
	local num_players_within_range = 0
	local PLAYER_AND_BOT_UNITS = PLAYER_AND_BOT_UNITS
	local num_players = #PLAYER_AND_BOT_UNITS

	for i = 1, num_players, 1 do
		local player_unit = PLAYER_AND_BOT_UNITS[i]
		local player_status_extension = ScriptUnit.extension(player_unit, "status_system")
		local player_position = POSITION_LOOKUP[player_unit]
		local distance_squared = Vector3.distance_squared(self_position, player_position)

		if player_unit ~= self_unit and not player_status_extension.is_disabled(player_status_extension) and distance_squared < max_ally_distance_sq then
			num_players_within_range = num_players_within_range + 1
		end
	end

	local near_players_percentage = nil
	local num_players_except_self = num_players - 1

	if num_players_except_self == 0 then
		near_players_percentage = 0.5
	else
		near_players_percentage = num_players_within_range / num_players_except_self
	end

	local proximite_enemies = blackboard.proximite_enemies
	local num_proximite_enemies = #proximite_enemies
	local max_threat_distance_sq = 49
	local total_threat_value = 0
	local threat_threshold = math.max(20 * (1 - near_players_percentage), 8)
	local current_health_percent = blackboard.health_extension:current_health_percent()
	local is_wounded = blackboard.status_extension:is_wounded()
	local health_multiplier = 2 - ((is_wounded and 0) or current_health_percent)

	for i = 1, num_proximite_enemies, 1 do
		local enemy_unit = proximite_enemies[i]
		local enemy_position = POSITION_LOOKUP[enemy_unit]

		if unit_alive(enemy_unit) and Vector3.distance_squared(self_position, enemy_position) <= max_threat_distance_sq then
			local enemy_blackboard = BLACKBOARDS[enemy_unit]
			local enemy_breed = enemy_blackboard.breed
			local is_targeting_bot = enemy_blackboard.target_unit == self_unit
			local threat_value = enemy_breed.threat_value * (health_multiplier + ((is_targeting_bot and 0.25) or 0))
			total_threat_value = total_threat_value + threat_value

			if threat_threshold <= total_threat_value then
				return true
			end
		end
	end

	return false
end
BTConditions.can_activate.wh_bountyhunter = function (blackboard, can_use_ranged_shot_ability)
	if not can_use_ranged_shot_ability then
		return false
	end

	local target = blackboard.target_unit

	if not unit_alive(target) then
		return false
	end

	local max_distance = 15
	local is_range_ok = (target == blackboard.priority_target_enemy and blackboard.priority_target_distance <= max_distance) or (target == blackboard.urgent_target_enemy and blackboard.urgent_target_distance <= max_distance) or (target == blackboard.opportunity_target_enemy and blackboard.opportunity_target_distance <= max_distance)

	if is_range_ok then
		local obstruction = blackboard.ranged_obstruction_by_static
		local t = Managers.time:time("game")
		local obstructed = obstruction and obstruction.unit == target and obstruction.timer + 3 < t

		return not obstructed
	else
		return false
	end

	return 
end
BTConditions.can_activate.wh_zealot = function (blackboard)
	local self_unit = blackboard.unit
	local self_position = POSITION_LOOKUP[self_unit]
	local target_unit = blackboard.target_unit
	local target_blackboard = BLACKBOARDS[target_unit]
	local target_breed = target_blackboard and target_blackboard.breed
	local target_threat_value = (target_breed and target_breed.threat_value) or 0
	local target_ally_unit = blackboard.target_ally_unit
	local target_ally_need_type = blackboard.target_ally_need_type
	local ai_bot_group_system = Managers.state.entity:system("ai_bot_group_system")
	local is_prioritized = ai_bot_group_system.is_prioritized_ally(ai_bot_group_system, self_unit, target_ally_unit)
	local run_target, run_target_distance_sq = nil

	if is_prioritized and (target_ally_need_type == "knocked_down" or target_ally_need_type == "hook") then
		run_target = target_ally_unit
		run_target_distance_sq = blackboard.ally_distance^2
	elseif target_unit and 8 <= target_threat_value then
		local target_position = POSITION_LOOKUP[target_unit]
		run_target = target_unit
		run_target_distance_sq = Vector3.distance_squared(self_position, target_position)
	end

	local min_distance_sq = 81
	local max_distance_sq = 144

	if run_target and min_distance_sq < run_target_distance_sq and run_target_distance_sq < max_distance_sq then
		local run_target_position = POSITION_LOOKUP[run_target]
		local run_target_direction = Vector3.normalize(run_target_position - self_position)
		local check_position = run_target_position + run_target_direction * 0.5
		local nav_world = blackboard.nav_world
		local success = LocomotionUtils.ray_can_go_on_mesh(nav_world, self_position, check_position, nil, 1, 1)

		if success then
			blackboard.activate_ability_data.aim_position:store(run_target_position)

			return true
		end
	end

	return false
end
BTConditions.can_activate.bw_adept = function (blackboard)
	local self_unit = blackboard.unit
	local self_position = POSITION_LOOKUP[self_unit]
	local target_unit = blackboard.target_unit
	local target_blackboard = BLACKBOARDS[target_unit]
	local target_breed = target_blackboard and target_blackboard.breed
	local target_threat_value = (target_breed and target_breed.threat_value) or 0
	local target_ally_unit = blackboard.target_ally_unit
	local target_ally_need_type = blackboard.target_ally_need_type
	local ai_bot_group_system = Managers.state.entity:system("ai_bot_group_system")
	local is_prioritized = ai_bot_group_system.is_prioritized_ally(ai_bot_group_system, self_unit, target_ally_unit)
	local fire_walk_target, fire_walk_target_distance_sq = nil

	if is_prioritized and (target_ally_need_type == "knocked_down" or target_ally_need_type == "hook") then
		fire_walk_target = target_ally_unit
		fire_walk_target_distance_sq = blackboard.ally_distance^2
	elseif target_unit and 8 <= target_threat_value then
		local target_position = POSITION_LOOKUP[target_unit]
		fire_walk_target = target_unit
		fire_walk_target_distance_sq = Vector3.distance_squared(self_position, target_position)
	end

	local min_distance_sq = 25
	local max_distance_sq = 100

	if fire_walk_target and min_distance_sq < fire_walk_target_distance_sq and fire_walk_target_distance_sq < max_distance_sq then
		local fire_walk_target_position = POSITION_LOOKUP[fire_walk_target]
		local fire_walk_target_direction = Vector3.normalize(fire_walk_target_position - self_position)
		local check_position = fire_walk_target_position + fire_walk_target_direction * 0.5
		local nav_world = blackboard.nav_world
		local success = LocomotionUtils.ray_can_go_on_mesh(nav_world, self_position, check_position, nil, 1, 1)

		if success then
			blackboard.activate_ability_data.aim_position:store(fire_walk_target_position)

			return true
		end
	end

	return false
end
BTConditions.can_activate.bw_scholar = function (blackboard, can_use_ranged_shot_ability)
	if not can_use_ranged_shot_ability then
		return false
	end

	local target = blackboard.target_unit

	if not unit_alive(target) then
		return false
	end

	local max_distance = 20
	local is_range_ok = (target == blackboard.priority_target_enemy and blackboard.priority_target_distance <= max_distance) or (target == blackboard.urgent_target_enemy and blackboard.urgent_target_distance <= max_distance) or (target == blackboard.opportunity_target_enemy and blackboard.opportunity_target_distance <= max_distance)

	if is_range_ok then
		local obstruction = blackboard.ranged_obstruction_by_static
		local t = Managers.time:time("game")
		local obstructed = obstruction and obstruction.unit == target and obstruction.timer + 3 < t

		return not obstructed
	else
		return false
	end

	return 
end
BTConditions.can_activate.bw_unchained = function (blackboard)
	local overcharge_extension = blackboard.overcharge_extension
	local is_above_critical_limit = overcharge_extension.is_above_critical_limit(overcharge_extension)

	if is_above_critical_limit then
		return true
	end

	local self_unit = blackboard.unit
	local self_position = POSITION_LOOKUP[self_unit]
	local proximite_enemies = blackboard.proximite_enemies
	local num_proximite_enemies = #proximite_enemies
	local max_distance_sq = 16
	local total_threat_value = 0
	local threat_threshold = 10

	for i = 1, num_proximite_enemies, 1 do
		local enemy_unit = proximite_enemies[i]
		local enemy_position = POSITION_LOOKUP[enemy_unit]

		if unit_alive(enemy_unit) and Vector3.distance_squared(self_position, enemy_position) <= max_distance_sq then
			local enemy_blackboard = BLACKBOARDS[enemy_unit]
			local enemy_breed = enemy_blackboard.breed
			local is_targeting_bot = enemy_blackboard.target_unit == self_unit
			local threat_value = enemy_breed.threat_value * ((is_targeting_bot and 1.25) or 1)
			total_threat_value = total_threat_value + threat_value

			if threat_threshold <= total_threat_value then
				return true
			end
		end
	end

	return false
end
BTConditions.can_activate_ability = function (blackboard, args)
	local career_extension = blackboard.career_extension
	local is_using_ability = blackboard.activate_ability_data.is_using_ability
	local career_name = career_extension.career_name(career_extension)
	local can_use_ranged_shot_ability = args[1]

	if can_use_ranged_shot_ability and (not unit_alive(blackboard.target_unit) or not Unit.has_data(blackboard.target_unit, "breed")) then
		return false
	end

	local condition_function = BTConditions.can_activate[career_name]

	return is_using_ability or (career_extension.can_use_activated_ability(career_extension) and condition_function and condition_function(blackboard, can_use_ranged_shot_ability))
end
BTConditions.is_disabled = function (blackboard)
	return blackboard.is_knocked_down or blackboard.is_grabbed_by_pack_master or blackboard.is_pounced_down or blackboard.is_hanging_from_hook or blackboard.is_ledge_hanging or blackboard.is_grabbed_by_chaos_spawn
end
BTConditions.is_transported = function (blackboard)
	return blackboard.is_transported
end
local PUSHED_COOLDOWN = 2
local BLOCK_BROKEN_COOLDOWN = 4

local function is_safe_to_block_interact(status_extension, interaction_extension, wanted_interaction_type)
	local t = Managers.time:time("game")
	local pushed_t = status_extension.pushed_at_t
	local block_broken_t = status_extension.block_broken_at_t
	local enough_fatigue = true
	local is_interacting, interaction_type = interaction_extension.is_interacting(interaction_extension)

	if not is_interacting or interaction_type ~= wanted_interaction_type then
		local current_fatigue, max_fatigue = status_extension.current_fatigue_points(status_extension)
		local stamina_left = max_fatigue - current_fatigue
		local blocked_attack_cost = PlayerUnitStatusSettings.fatigue_point_costs.blocked_attack
		enough_fatigue = current_fatigue == 0 or blocked_attack_cost < stamina_left
	end

	if enough_fatigue and pushed_t + PUSHED_COOLDOWN < t and block_broken_t + BLOCK_BROKEN_COOLDOWN < t then
		return true
	else
		return false
	end

	return 
end

local function is_there_threat_to_aid(self_unit, proximite_enemies, force_aid)
	local num_proximite_enemies = #proximite_enemies

	for i = 1, num_proximite_enemies, 1 do
		local enemy_unit = proximite_enemies[i]

		if unit_alive(enemy_unit) then
			local enemy_blackboard = BLACKBOARDS[enemy_unit]
			local enemy_breed = enemy_blackboard.breed

			if enemy_blackboard.target_unit == self_unit and (not force_aid or enemy_breed.is_bot_aid_threat) then
				return true
			end
		end
	end

	return false
end

local function can_interact_with_ally(self_unit, target_ally_unit)
	local interactable_extension = ScriptUnit.extension(target_ally_unit, "interactable_system")
	local interactor_unit = interactable_extension.is_being_interacted_with(interactable_extension)
	local can_interact_with_ally = interactor_unit == nil or interactor_unit == self_unit

	return can_interact_with_ally
end

local FLAT_MOVE_TO_EPSILON_SQ = BotConstants.default.FLAT_MOVE_TO_EPSILON^2
local Z_MOVE_TO_EPSILON = BotConstants.default.Z_MOVE_TO_EPSILON

local function has_reached_ally_aid_destination(self_position, blackboard)
	local navigation_extension = blackboard.navigation_extension
	local destination = navigation_extension.destination(navigation_extension)
	local target_ally_aid_destination = blackboard.target_ally_aid_destination:unbox()
	local has_target_ally_aid_destination = Vector3.equal(destination, target_ally_aid_destination)

	if has_target_ally_aid_destination then
		return navigation_extension.destination_reached(navigation_extension)
	else
		local offset = target_ally_aid_destination - self_position

		return math.abs(offset.z) <= Z_MOVE_TO_EPSILON and Vector3.length_squared(Vector3.flat(offset)) <= FLAT_MOVE_TO_EPSILON_SQ
	end

	return 
end

BTConditions.can_revive = function (blackboard)
	local target_ally_unit = blackboard.target_ally_unit

	if blackboard.interaction_unit == target_ally_unit and blackboard.target_ally_need_type == "knocked_down" then
		local interaction_extension = blackboard.interaction_extension

		if not is_safe_to_block_interact(blackboard.status_extension, interaction_extension, "revive") then
			return false
		end

		local self_unit = blackboard.unit
		local health = ScriptUnit.extension(target_ally_unit, "health_system"):current_health_percent()

		if 0.3 < health and is_there_threat_to_aid(self_unit, blackboard.proximite_enemies, blackboard.force_aid) then
			return false
		end

		local ally_distance = blackboard.ally_distance
		local is_interacting, interaction_type = interaction_extension.is_interacting(interaction_extension)

		if is_interacting and interaction_type == "revive" and ally_distance < 1 then
			return true
		end

		local self_position = POSITION_LOOKUP[self_unit]
		local ally_destination_reached = has_reached_ally_aid_destination(self_position, blackboard)
		local can_interact_with_ally = can_interact_with_ally(self_unit, target_ally_unit)

		if can_interact_with_ally and ally_destination_reached then
			return true
		end
	end

	return 
end
BTConditions.can_heal_player = function (blackboard)
	local target_ally_unit = blackboard.target_ally_unit

	if blackboard.interaction_unit == target_ally_unit and blackboard.target_ally_need_type == "in_need_of_heal" then
		local interaction_extension = blackboard.interaction_extension
		local is_interacting, interaction_type = interaction_extension.is_interacting(interaction_extension)

		if is_interacting and interaction_type == "heal" then
			return true
		end

		if 0 < #blackboard.proximite_enemies then
			return false
		end

		local self_unit = blackboard.unit
		local self_position = POSITION_LOOKUP[self_unit]
		local ally_destination_reached = has_reached_ally_aid_destination(self_position, blackboard)
		local can_interact_with_ally = can_interact_with_ally(self_unit, target_ally_unit)
		local ally_locomotion_extension = ScriptUnit.extension(target_ally_unit, "locomotion_system")
		local ally_velocity = ally_locomotion_extension.current_velocity(ally_locomotion_extension)
		local ally_speed_sq = Vector3.length_squared(ally_velocity)
		local ally_distance = blackboard.ally_distance

		if can_interact_with_ally and (ally_destination_reached or (0.04000000000000001 < ally_speed_sq and ally_distance < 2)) then
			return true
		end
	end

	return 
end
BTConditions.can_help_in_need_player = function (blackboard, args)
	local need_type = args[1]
	local target_ally_unit = blackboard.target_ally_unit

	if blackboard.interaction_unit == target_ally_unit and blackboard.target_ally_need_type == need_type then
		local self_unit = blackboard.unit
		local self_position = POSITION_LOOKUP[self_unit]
		local ally_destination_reached = has_reached_ally_aid_destination(self_position, blackboard)
		local can_interact_with_ally = can_interact_with_ally(self_unit, target_ally_unit)
		local ally_locomotion_extension = ScriptUnit.extension(target_ally_unit, "locomotion_system")
		local ally_velocity = ally_locomotion_extension.current_velocity(ally_locomotion_extension)
		local ally_speed_sq = Vector3.length_squared(ally_velocity)
		local ally_distance = blackboard.ally_distance

		if can_interact_with_ally and (ally_destination_reached or (0.04000000000000001 < ally_speed_sq and ally_distance < 2)) then
			return true
		end
	end

	return 
end
BTConditions.can_rescue_hanging_from_hook = function (blackboard)
	local target_ally_unit = blackboard.target_ally_unit

	if blackboard.interaction_unit == target_ally_unit and blackboard.target_ally_need_type == "hook" then
		if not is_safe_to_block_interact(blackboard.status_extension, blackboard.interaction_extension, "release_from_hook") then
			return false
		end

		local self_unit = blackboard.unit

		if is_there_threat_to_aid(self_unit, blackboard.proximite_enemies, blackboard.force_aid) then
			return false
		end

		local self_position = POSITION_LOOKUP[self_unit]
		local can_interact_with_ally = can_interact_with_ally(self_unit, target_ally_unit)
		local ally_destination_reached = has_reached_ally_aid_destination(self_position, blackboard)

		if can_interact_with_ally and ally_destination_reached then
			return true
		end
	end

	return 
end
BTConditions.can_rescue_ledge_hanging = function (blackboard)
	local target_ally_unit = blackboard.target_ally_unit

	if blackboard.interaction_unit == target_ally_unit and blackboard.target_ally_need_type == "ledge" then
		if not is_safe_to_block_interact(blackboard.status_extension, blackboard.interaction_extension, "pull_up") then
			return false
		end

		local self_unit = blackboard.unit

		if is_there_threat_to_aid(self_unit, blackboard.proximite_enemies, blackboard.force_aid) then
			return false
		end

		local self_position = POSITION_LOOKUP[self_unit]
		local can_interact_with_ally = can_interact_with_ally(self_unit, target_ally_unit)
		local ally_destination_reached = has_reached_ally_aid_destination(self_position, blackboard)

		if can_interact_with_ally and ally_destination_reached then
			return true
		end
	end

	return 
end
BTConditions.can_loot = function (blackboard)
	local play_go_system = Managers.state.entity:system("play_go_tutorial_system")

	if play_go_system and not play_go_system.bot_loot_enabled(play_go_system) then
		return false
	end

	local max_dist = 3.2

	return (blackboard.health_pickup and blackboard.allowed_to_take_health_pickup and blackboard.health_dist < max_dist and blackboard.health_pickup == blackboard.interaction_unit) or (blackboard.ammo_pickup and blackboard.needs_ammo and blackboard.ammo_dist < max_dist and blackboard.ammo_pickup == blackboard.interaction_unit) or (blackboard.mule_pickup and blackboard.mule_pickup == blackboard.interaction_unit and blackboard.mule_pickup_dist_squared < max_dist * max_dist)
end
BTConditions.bot_should_heal = function (blackboard)
	local self_unit = blackboard.unit
	local inventory_ext = blackboard.inventory_extension
	local health_slot_data = inventory_ext.get_slot_data(inventory_ext, "slot_healthkit")
	local template = health_slot_data and inventory_ext.get_item_template(inventory_ext, health_slot_data)
	local can_heal_self = template and template.can_heal_self

	if not can_heal_self then
		return false
	end

	local current_health_percent = blackboard.health_extension:current_health_percent()
	local hurt = current_health_percent <= template.bot_heal_threshold
	local target_unit = blackboard.target_unit
	local is_safe = not target_unit or ((template.fast_heal or blackboard.is_healing_self) and #blackboard.proximite_enemies == 0) or (target_unit ~= blackboard.priority_target_enemy and target_unit ~= blackboard.urgent_target_enemy and target_unit ~= blackboard.proximity_target_enemy and target_unit ~= blackboard.slot_target_enemy)
	local wounded = blackboard.status_extension:is_wounded()

	return is_safe and (hurt or blackboard.force_use_health_pickup or wounded)
end
BTConditions.is_slot_not_wielded = function (blackboard, args)
	local wielded_slot = blackboard.inventory_extension:equipment().wielded_slot
	local wanted_slot = args[1]
	local exception_slot = args[2]

	if exception_slot and exception_slot == wielded_slot then
		return false
	else
		return wielded_slot ~= wanted_slot
	end

	return 
end
BTConditions.has_priority_or_opportunity_target = function (blackboard)
	local target = blackboard.target_unit

	if not unit_alive(target) then
		return false
	end

	local dist = 25
	local result = (target == blackboard.priority_target_enemy and blackboard.priority_target_distance < dist) or (target == blackboard.urgent_target_enemy and blackboard.urgent_target_distance < dist)

	return result
end
BTConditions.ally_within_range_or_solo = function (blackboard)
	return not unit_alive(blackboard.target_ally_unit) or blackboard.ally_distance < 40
end
BTConditions.bot_in_melee_range = function (blackboard)
	local target_unit = blackboard.target_unit

	if not unit_alive(target_unit) then
		return false
	end

	local self_unit = blackboard.unit
	local wielded_slot = blackboard.inventory_extension:equipment().wielded_slot
	local melee_range = nil
	local breed = Unit.get_data(target_unit, "breed")

	if blackboard.urgent_target_enemy == target_unit or blackboard.opportunity_target_enemy == target_unit or Vector3.is_valid(blackboard.taking_cover.cover_position:unbox()) then
		melee_range = (breed and breed.bot_opportunity_target_melee_range) or 3

		if wielded_slot == "slot_ranged" then
			melee_range = (breed and breed.bot_opportunity_target_melee_range_while_ranged) or 2
		end
	else
		melee_range = 12

		if wielded_slot == "slot_ranged" then
			melee_range = 10
		end
	end

	local target_aim_position = nil
	local override_aim_node_name = breed and breed.bot_melee_aim_node

	if override_aim_node_name then
		local override_aim_node = Unit.node(target_unit, override_aim_node_name)
		target_aim_position = Unit.world_position(target_unit, override_aim_node)
	else
		target_aim_position = POSITION_LOOKUP[target_unit]
	end

	local offset = target_aim_position - POSITION_LOOKUP[self_unit]
	local dist = Vector3.length(offset)
	local in_range = dist < melee_range
	local z_offset = offset.z

	return in_range and -1.5 < z_offset and z_offset < 2
end
BTConditions.has_target_and_ammo_greater_than = function (blackboard, args)
	local target_unit = blackboard.target_unit

	if not unit_alive(target_unit) or Unit.get_data(target_unit, "breed") == nil then
		return false
	end

	local inventory_extension = blackboard.inventory_extension
	local ranged_slot_data = inventory_extension.get_slot_data(inventory_extension, "slot_ranged")
	local ranged_slot_template = inventory_extension.get_item_template(inventory_extension, ranged_slot_data)
	local ranged_slot_buff_type = ranged_slot_template and ranged_slot_template.buff_type
	local is_ranged = RangedBuffTypes[ranged_slot_buff_type]

	if not is_ranged then
		return false
	end

	local current, max = inventory_extension.current_ammo_status(inventory_extension, "slot_ranged")
	local ammo_ok = not current or args.ammo_percentage < current / max
	local overcharge_extension = blackboard.overcharge_extension
	local overcharge_limit_type = args.overcharge_limit_type
	local current_oc, threshold_oc, max_oc = overcharge_extension.current_overcharge_status(overcharge_extension)
	local overcharge_ok = current_oc == 0 or (overcharge_limit_type == "threshold" and current_oc / threshold_oc < args.overcharge_limit) or (overcharge_limit_type == "maximum" and current_oc / max_oc < args.overcharge_limit)
	local obstruction = blackboard.ranged_obstruction_by_static
	local t = Managers.time:time("game")
	local obstructed = obstruction and obstruction.unit == blackboard.target_unit and obstruction.timer + 3 < t

	return ammo_ok and overcharge_ok and not obstructed
end
BTConditions.can_open_door = function (blackboard)
	local can_interact = false

	if blackboard.interaction_type == "door" then
		local interaction_unit = blackboard.interaction_unit
		local door_extension = unit_alive(interaction_unit) and ScriptUnit.has_extension(interaction_unit, "door_system")

		if door_extension then
			can_interact = door_extension.get_current_state(door_extension) == "closed"
		end
	end

	return can_interact
end
BTConditions.bot_at_breakable = function (blackboard)
	local navigation_extension = blackboard.navigation_extension

	return navigation_extension.is_in_transition(navigation_extension) and navigation_extension.transition_type(navigation_extension) == "planks"
end
BTConditions.cant_reach_ally = function (blackboard)
	local follow_unit = blackboard.ai_bot_group_extension.data.follow_unit

	if not follow_unit then
		return false
	end

	local level_settings = LevelHelper:current_level_settings()
	local disable_bot_main_path_teleport_check = level_settings.disable_bot_main_path_teleport_check
	local is_forwards = nil

	if not disable_bot_main_path_teleport_check then
		local self_unit = blackboard.unit
		local conflict_director = Managers.state.conflict
		local self_segment = conflict_director.get_player_unit_segment(conflict_director, self_unit)
		local target_segment = conflict_director.get_player_unit_segment(conflict_director, follow_unit)

		if not self_segment or not target_segment then
			return false
		end

		local is_backwards = target_segment < self_segment

		if is_backwards then
			return false
		end

		is_forwards = self_segment < target_segment
	end

	local t = Managers.time:time("game")
	local navigation_extension = blackboard.navigation_extension
	local fails, last_success = navigation_extension.successive_failed_paths(navigation_extension)

	return blackboard.moving_toward_follow_position and (((disable_bot_main_path_teleport_check or is_forwards) and 1) or 5) < fails and 5 < t - last_success and not blackboard.has_teleported
end
BTConditions.can_teleport = function (blackboard)
	local follow_unit = blackboard.ai_bot_group_extension.data.follow_unit

	if not follow_unit then
		return false
	end

	local level_settings = LevelHelper:current_level_settings()
	local disable_bot_main_path_teleport_check = level_settings.disable_bot_main_path_teleport_check

	if not disable_bot_main_path_teleport_check then
		local self_unit = blackboard.unit
		local conflict_director = Managers.state.conflict
		local self_segment = conflict_director.get_player_unit_segment(conflict_director, self_unit) or 1
		local target_segment = conflict_director.get_player_unit_segment(conflict_director, follow_unit)

		if not target_segment or target_segment < self_segment then
			return false
		end
	end

	return true
end

return 

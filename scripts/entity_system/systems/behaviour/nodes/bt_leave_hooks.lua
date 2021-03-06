BTLeaveHooks = BTHooksLeave or {}
local BTLeaveHooks = BTLeaveHooks
local unit_alive = Unit.alive
local ScriptUnit = ScriptUnit
BTLeaveHooks.reset_fling_skaven = function (unit, blackboard, t)
	blackboard.fling_skaven = false

	return 
end
BTLeaveHooks.check_if_victim_was_grabbed = function (unit, blackboard, t)
	if blackboard.victim_grabbed then
		blackboard.has_grabbed_victim = true

		PerceptionUtils.clear_target_unit(blackboard)

		if blackboard.stagger then
			StatusUtils.set_grabbed_by_chaos_spawn_network(blackboard.victim_grabbed, false, unit)

			blackboard.has_grabbed_victim = nil
			blackboard.victim_grabbed = nil
		end
	end

	return 
end
BTLeaveHooks.summoning_ends = function (unit, blackboard, t)
	blackboard.is_summoning = false

	return 
end
BTLeaveHooks.sorcerer_next_phase = function (unit, blackboard, t)
	local phase = blackboard.phase

	if phase == "defensive_starts" then
		blackboard.phase = "defensive_combat"
	elseif phase == "defensive_combat" then
		blackboard.phase = "defensive_ends"
	else
		blackboard.phase = "defensive_completed"
	end

	return 
end
BTLeaveHooks.sorcerer_setup_done = function (unit, blackboard, t)
	blackboard.mode = "offensive"
	blackboard.setup_done = true
	blackboard.phase_timer = t + 30

	return 
end
BTLeaveHooks.sorcerer_evade = function (unit, blackboard, t)
	blackboard.escape_teleport = false

	return 
end
BTLeaveHooks.reset_stormfiend_charge = function (unit, blackboard, t)
	blackboard.weakspot_hits = nil
	blackboard.weakspot_rage = nil

	return 
end
BTLeaveHooks.stormfiend_boss_mount_leave = function (unit, blackboard, t)
	return 
end
BTLeaveHooks.stormfiend_boss_rage_leave = function (unit, blackboard, t)
	local network_manager = Managers.state.network
	local game = network_manager.game(network_manager)
	local go_id = Managers.state.unit_storage:go_id(unit)
	blackboard.intro_rage = nil
	local health_extension = ScriptUnit.extension(unit, "health_system")
	health_extension.is_invincible = false

	GameSession.set_game_object_field(game, go_id, "show_health_bar", true)
	Managers.state.event:trigger("show_boss_health_bar", unit)

	local conflict_director = Managers.state.conflict
	local level_analysis = conflict_director.level_analysis
	local node_units = level_analysis.generic_ai_node_units.grey_seer_intro_jump_down_to

	if node_units then
		local node_unit = node_units[1]
		local pos = Unit.local_position(node_unit, 0)
		local projected_wanted_pos = LocomotionUtils.pos_on_mesh(blackboard.nav_world, pos, 1, 1)
		blackboard.goal_destination = Vector3Box(projected_wanted_pos)
		blackboard.jump_down_intro = true
	end

	return 
end
BTLeaveHooks.stormfiend_boss_jump_down_leave = function (unit, blackboard, t)
	blackboard.jump_down_intro = nil
	blackboard.goal_destination = nil

	return 
end
BTLeaveHooks.on_grey_seer_intro_leave = function (unit, blackboard, t)
	if not blackboard.exit_last_action then
		local conflict_director = Managers.state.conflict
		local level_analysis = conflict_director.level_analysis
		local node_units = level_analysis.generic_ai_node_units.grey_seer_intro_stormfiend_spawn

		if node_units then
			local node_unit = node_units[1]
			local pos = Unit.local_position(node_unit, 0)
			local stormfiend_boss_breed = Breeds.skaven_stormfiend_boss
			local spawn_category = "misc"
			local stormfiend_unit = conflict_director.spawn_unit(conflict_director, stormfiend_boss_breed, pos, Unit.local_rotation(unit, 0), spawn_category, nil)
			local mounted_data = blackboard.mounted_data
			mounted_data.mount_unit = stormfiend_unit
			mounted_data.knocked_off_mounted_timer = t
			blackboard.knocked_off_mount = true
			local mount_blackboard = BLACKBOARDS[stormfiend_unit]
			mount_blackboard.goal_destination = Vector3Box(POSITION_LOOKUP[unit])
			mount_blackboard.anim_cb_move = true
			mount_blackboard.intro_rage = true
			local dialogue_input = ScriptUnit.extension_input(unit, "dialogue_system")
			local event_data = FrameTable.alloc_table()

			dialogue_input.trigger_networked_dialogue_event(dialogue_input, "egs_calls_mount_battle", event_data)
		else
			print("Found no generic AI node (grey_seer_intro_stormfiend_spawn) for grey_seer_intro_leave")
		end

		blackboard.intro_timer = nil

		conflict_director.add_angry_boss(conflict_director, 1, blackboard)

		blackboard.is_angry = true
	end

	return 
end
BTLeaveHooks.on_grey_seer_death_sequence_leave = function (unit, blackboard, t)
	blackboard.current_phase = 6
	local health_extension = ScriptUnit.extension(blackboard.unit, "health_system")
	health_extension.is_invincible = false

	blackboard.navigation_extension:set_enabled(false)
	blackboard.locomotion_extension:set_wanted_velocity(Vector3.zero())

	return 
end
BTLeaveHooks.leave_attack_grabbed_smash = function (unit, blackboard, t)
	if blackboard.stagger and Unit.alive(blackboard.victim_grabbed) then
		StatusUtils.set_grabbed_by_chaos_spawn_network(blackboard.victim_grabbed, false, unit)

		blackboard.has_grabbed_victim = nil
		blackboard.victim_grabbed = nil
	else
		blackboard.wants_to_throw = true
	end

	return 
end
BTLeaveHooks.on_lord_intro_leave = function (unit, blackboard, t)
	if AiUtils.unit_alive(unit) and not blackboard.exit_last_action then
		local health_extension = ScriptUnit.extension(unit, "health_system")
		health_extension.is_invincible = false
		local game = Managers.state.network:game()
		local go_id = Managers.state.unit_storage:go_id(unit)

		GameSession.set_game_object_field(game, go_id, "show_health_bar", true)
		Managers.state.event:trigger("show_boss_health_bar", unit)
		Managers.state.conflict:add_angry_boss(1, blackboard)

		blackboard.is_angry = true
		blackboard.intro_timer = nil
		local network_manager = Managers.state.network

		network_manager.anim_event(network_manager, unit, "to_combat")
	end

	return 
end
BTLeaveHooks.on_lord_warlord_intro_leave = function (unit, blackboard, t)
	if AiUtils.unit_alive(unit) and not blackboard.exit_last_action then
		local health_extension = ScriptUnit.extension(unit, "health_system")
		health_extension.is_invincible = false
		local game = Managers.state.network:game()
		local go_id = Managers.state.unit_storage:go_id(unit)

		GameSession.set_game_object_field(game, go_id, "show_health_bar", true)
		Managers.state.event:trigger("show_boss_health_bar", unit)
		Managers.state.conflict:add_angry_boss(1, blackboard)

		blackboard.is_angry = true
		blackboard.jump_down_timer = t + 5
		local network_manager = Managers.state.network

		network_manager.anim_event(network_manager, unit, "to_dual_wield")

		local level_analysis = Managers.state.conflict.level_analysis
		local node_units = level_analysis.generic_ai_node_units.skaven_warlord_intro_jump_to

		if node_units then
			local center_unit = node_units[1]
			local exit_pos = Unit.local_position(center_unit, 0)
			blackboard.jump_from_pos = Vector3Box(POSITION_LOOKUP[unit])
			blackboard.exit_pos = Vector3Box(exit_pos)
		end
	end

	return 
end
BTLeaveHooks.reset_keep_target = function (unit, blackboard, t)
	blackboard.keep_target = nil

	return 
end

return 

require("scripts/unit_extensions/weapons/projectiles/true_flight_templates")

ActionTrueFlightBowAim = class(ActionTrueFlightBowAim)
ActionTrueFlightBowAim.init = function (self, world, item_name, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)
	self.owner_unit = owner_unit
	self.weapon_unit = weapon_unit
	self.is_server = is_server
	self.world = world
	self.wwise_world = Managers.world:wwise_world(world)
	self.overcharge_extension = ScriptUnit.extension(owner_unit, "overcharge_system")

	if ScriptUnit.has_extension(self.weapon_unit, "spread_system") then
		self.spread_extension = ScriptUnit.extension(self.weapon_unit, "spread_system")
	end

	self.first_person_extension = ScriptUnit.extension(owner_unit, "first_person_system")

	return 
end
ActionTrueFlightBowAim.client_owner_start_action = function (self, new_action, t, chain_action_data)
	self.current_action = new_action
	self.aim_timer = 0
	self.target = (chain_action_data and chain_action_data.target) or nil
	self.targets = (chain_action_data and chain_action_data.targets) or {}
	self.aimed_target = (chain_action_data and chain_action_data.target) or nil
	self.time_to_shoot = t
	local owner_unit = self.owner_unit
	local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
	self.charge_time = buff_extension.apply_buffs_to_value(buff_extension, new_action.charge_time or 0, StatBuffIndex.REDUCED_RANGED_CHARGE_TIME)
	self.overcharge_timer = 0
	self.zoom_condition_function = new_action.zoom_condition_function
	self.played_aim_sound = false
	self.aim_sound_time = t + (new_action.aim_sound_delay or 0)
	self.aim_zoom_time = t + (new_action.aim_zoom_delay or 0)
	local loaded_projectile_settings = new_action.loaded_projectile_settings

	if loaded_projectile_settings then
		local inventory_extension = ScriptUnit.extension(self.owner_unit, "inventory_system")

		inventory_extension.set_loaded_projectile_override(inventory_extension, loaded_projectile_settings)
	end

	self.charge_ready_sound_event = self.current_action.charge_ready_sound_event
	local owner_unit = self.owner_unit
	local owner_player = Managers.player:owner(owner_unit)
	local is_bot = owner_player and owner_player.bot_player

	if not is_bot then
		local charge_sound_name = new_action.charge_sound_name

		if charge_sound_name then
			local wwise_playing_id, wwise_source_id = ActionUtils.start_charge_sound(self.wwise_world, self.weapon_unit, owner_unit, new_action)
			self.charging_sound_id = wwise_playing_id
			self.wwise_source_id = wwise_source_id
		end

		local aim_sound_event = self.current_action.aim_sound_event

		if aim_sound_event then
			local position = POSITION_LOOKUP[owner_unit]

			WwiseUtils.trigger_position_event(self.world, aim_sound_event, position)
		end
	end

	local charge_sound_husk_name = self.current_action.charge_sound_husk_name

	if charge_sound_husk_name then
		ActionUtils.play_husk_sound_event(charge_sound_husk_name, owner_unit)
	end

	local spread_template_override = new_action.spread_template_override

	if spread_template_override then
		self.spread_extension:override_spread_template(spread_template_override)
	end

	return 
end
ActionTrueFlightBowAim.client_owner_post_update = function (self, dt, t, world, can_damage)
	local current_action = self.current_action
	local owner_unit = self.owner_unit
	local time_to_shoot = self.time_to_shoot
	local owner_unit = self.owner_unit
	local owner_player = Managers.player:owner(owner_unit)
	local is_bot = owner_player and owner_player.bot_player
	local overcharge_extension = self.overcharge_extension

	if current_action.overcharge_interval then
		self.overcharge_timer = self.overcharge_timer + dt

		if current_action.overcharge_interval <= self.overcharge_timer then
			if self.overcharge_extension then
				local overcharge_amount = PlayerUnitStatusSettings.overcharge_values[current_action.overcharge_type]

				self.overcharge_extension:add_charge(overcharge_amount)
			end

			self.overcharge_timer = 0
		end
	end

	if not self.zoom_condition_function or self.zoom_condition_function() then
		local status_extension = ScriptUnit.extension(owner_unit, "status_system")
		local input_extension = ScriptUnit.extension(owner_unit, "input_system")
		local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")

		if not status_extension.is_zooming(status_extension) and self.aim_zoom_time <= t then
			status_extension.set_zooming(status_extension, true, current_action.default_zoom)
		end

		if buff_extension.has_buff_type(buff_extension, "increased_zoom") and status_extension.is_zooming(status_extension) and input_extension.get(input_extension, "action_three") then
			status_extension.switch_variable_zoom(status_extension, current_action.buffed_zoom_thresholds)
		elseif current_action.zoom_thresholds and status_extension.is_zooming(status_extension) and input_extension.get(input_extension, "action_three") then
			status_extension.switch_variable_zoom(status_extension, current_action.zoom_thresholds)
		end
	end

	if not self.played_aim_sound and self.aim_sound_time <= t and not is_bot then
		local sound_event = current_action.aim_sound_event

		if sound_event then
			local wwise_world = self.wwise_world

			WwiseWorld.trigger_event(wwise_world, sound_event)
		end

		self.played_aim_sound = true
	end

	required_aim_time = current_action.aim_time or 0.1

	if required_aim_time <= self.aim_timer then
		local physics_world = World.get_data(world, "physics_world")
		local owner_unit = self.owner_unit
		local first_person_extension = self.first_person_extension
		local player_rotation = first_person_extension.current_rotation(first_person_extension)
		local player_position = first_person_extension.current_position(first_person_extension)
		local direction = Vector3.normalize(Quaternion.forward(player_rotation))
		local results = PhysicsWorld.immediate_raycast_actors(physics_world, player_position, direction, "dynamic_collision_filter", "filter_ray_true_flight_ai_only", "dynamic_collision_filter", "filter_ray_true_flight_hitbox_only")
		local hit_unit = nil

		if results then
			local num_results = #results

			for i = 1, num_results, 1 do
				local result = results[i]
				local hit_actor = result[4]

				if hit_actor then
					local aim_at_unit = Actor.unit(hit_actor)

					if hit_actor ~= Unit.actor(aim_at_unit, "c_afro") then
						local unit = Actor.unit(hit_actor)

						if ScriptUnit.has_extension(unit, "health_system") then
							local health_extension = ScriptUnit.extension(unit, "health_system")

							if health_extension.is_alive(health_extension) then
								local breed = Unit.get_data(unit, "breed")

								if breed and not breed.no_autoaim then
									hit_unit = unit

									break
								end
							end
						end
					end
				end
			end
		end

		local current_target = self.target

		if hit_unit and self.aimed_target ~= hit_unit then
			self.aimed_target = hit_unit
			self.aim_timer = 0

			if Unit.alive(hit_unit) and current_target ~= hit_unit then
				if ScriptUnit.has_extension(hit_unit, "outline_system") and not is_bot then
					local outline_extension = ScriptUnit.extension(hit_unit, "outline_system")

					outline_extension.set_method("ai_alive")
				end

				if Unit.alive(current_target) and not is_bot and ScriptUnit.has_extension(current_target, "outline_system") then
					local outline_extension = ScriptUnit.extension(current_target, "outline_system")

					outline_extension.set_method("never")
				end

				self.target = hit_unit
			end
		end
	end

	self.charge_value = math.min(math.max(t - time_to_shoot, 0) / self.charge_time, 1)

	if not is_bot then
		local charge_sound_parameter_name = current_action.charge_sound_parameter_name

		if charge_sound_parameter_name then
			local wwise_world = self.wwise_world
			local wwise_source_id = self.wwise_source_id

			WwiseWorld.set_source_parameter(wwise_world, wwise_source_id, charge_sound_parameter_name, charge_level)
		end

		if self.charge_ready_sound_event and 1 <= self.charge_value then
			self.first_person_extension:play_hud_sound_event(self.charge_ready_sound_event)

			self.charge_ready_sound_event = nil
		end
	end

	self.aim_timer = self.aim_timer + dt

	return 
end
ActionTrueFlightBowAim._get_visible_targets = function (self, aimed_target, num_targets, is_bot)
	local first_person_extension = self.first_person_extension
	local own_position = first_person_extension.current_position(first_person_extension)
	local look_rotation = first_person_extension.current_rotation(first_person_extension)
	local look_direction = Quaternion.forward(look_rotation)
	local ai_system = Managers.state.entity:system("ai_system")
	local ai_broadphase = ai_system.broadphase
	local targets = {}
	local nearby_ai_units = {}
	local nearby_ai_positions = {}
	local nearby_ai_distances = {}
	local num_nearby_ai_units = EngineOptimized.smart_targeting_query(ai_broadphase, own_position, look_direction, 0, 50, 0.1, 0.2, 0.8, num_targets, nearby_ai_units, nearby_ai_positions, nearby_ai_distances)
	local aimed_target_nearby = false

	if num_nearby_ai_units then
		for i = 1, num_nearby_ai_units, 1 do
			local unit = nearby_ai_units[i]

			if AiUtils.unit_alive(unit) then
				local breed = Unit.get_data(unit, "breed")

				if breed and not breed.no_autoaim then
					targets[#targets + 1] = unit

					if unit == aimed_target then
						aimed_target_nearby = true
					end
				end
			end
		end
	else
		targets = self.targets
	end

	if aimed_target and not aimed_target_nearby then
		targets[1] = aimed_target
	end

	return targets
end
ActionTrueFlightBowAim.finish = function (self, reason, data)
	local current_action = self.current_action
	local owner_unit = self.owner_unit
	local unzoom_condition_function = current_action.unzoom_condition_function

	if self.spread_extension then
		self.spread_extension:reset_spread_template()
	end

	if not unzoom_condition_function or unzoom_condition_function(reason) then
		local status_extension = ScriptUnit.extension(owner_unit, "status_system")

		status_extension.set_zooming(status_extension, false)
	end

	local sound_event = current_action.unaim_sound_event

	if sound_event then
		local wwise_world = self.wwise_world

		WwiseWorld.trigger_event(wwise_world, sound_event)
	end

	local chain_action_data = {}

	if current_action.num_projectiles and 1 < current_action.num_projectiles then
		local owner_player = Managers.player:owner(owner_unit)
		local is_bot = owner_player and owner_player.bot_player
		chain_action_data.targets = self._get_visible_targets(self, self.target, current_action.num_projectiles, is_bot)
		chain_action_data.target = self.target
	else
		chain_action_data.target = self.target
	end

	local charging_sound_id = self.charging_sound_id

	if charging_sound_id then
		ActionUtils.stop_charge_sound(self.wwise_world, charging_sound_id, self.wwise_source_id, self.current_action)

		self.wwise_source_id = nil
		self.charging_sound_id = nil
	end

	local charge_sound_husk_stop_event = current_action.charge_sound_husk_stop_event

	if charge_sound_husk_stop_event then
		ActionUtils.play_husk_sound_event(charge_sound_husk_stop_event, owner_unit)
	end

	if data and data.new_action == "action_two" and (not data or (data.new_action ~= "action_career_release" and data.new_action ~= "action_career_hold") or data.new_sub_action ~= "default") then
		local outline_extension = ScriptUnit.has_extension(self.target, "outline_system")

		if outline_extension then
			outline_extension.set_method("never")
		end
	end

	self.targets = nil
	self.target = nil
	local inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")

	inventory_extension.set_loaded_projectile_override(inventory_extension, nil)

	return chain_action_data
end

return 

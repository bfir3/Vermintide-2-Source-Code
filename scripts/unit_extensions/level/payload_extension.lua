require("scripts/settings/payload_speed_settings")
require("scripts/utils/spline_curve")

local FRAMES = 100
local WHEEL_DIAMETER = 0.095
local WHEEL_CIRCUMFERENCE = WHEEL_DIAMETER * math.pi
local ANIM_SPEED = 30 / FRAMES / WHEEL_CIRCUMFERENCE
local ERROR_RECOUP_TIME = 0.5
local MOVING_THRESHOLD = 0.1
PayloadExtension = class(PayloadExtension)
PayloadExtension.init = function (self, extension_init_context, unit, extension_init_data)
	local world = extension_init_context.world
	local network_manager = Managers.state.network
	self._unit = unit
	self._world = world
	self._is_server = Managers.player.is_server
	self._game = network_manager.game(network_manager)
	self._network_manager = network_manager
	self._extra_joint = nil
	local level = LevelHelper:current_level(world)
	self._level_unit_index = Level.unit_index(level, unit)
	self._last_synched_spline_values = {
		last_synch_time = 0,
		error_compensation_speed = 0,
		spline_index = 1,
		subdivision_index = 1,
		spline_t = 0
	}
	self._stop_command_given = false
	self._activated = true

	return 
end
PayloadExtension.activate = function (self)
	self._activated = true

	return 
end
PayloadExtension.deactivate = function (self, stop)
	self._activated = false
	self._stop_command_given = stop

	return 
end
PayloadExtension.destroy = function (self)
	return 
end
PayloadExtension.extensions_ready = function (self)
	return 
end
PayloadExtension.hot_join_sync = function (self, sender)
	return 
end
PayloadExtension.init_payload = function (self, payload_gizmos)
	local unit = self._unit
	self._spline_curve = self._init_movement_spline(self, self._world, unit, payload_gizmos)
	local extra_joint = Unit.get_data(unit, "extra_spline_joint")

	if extra_joint then
		local spline_curve = self._init_movement_spline(self, self._world, unit, payload_gizmos)
		local node = Unit.node(unit, extra_joint)
		local distance = Vector3.distance(Vector3.flat(Unit.world_position(unit, node)), Vector3.flat(Unit.local_position(unit, 0)))
		local distance_fwd = Quaternion.forward(Unit.local_rotation(unit, 0)) * distance
		local movement = spline_curve.movement(spline_curve)
		local speed = 1
		local total_dt = distance / speed

		movement.set_speed(movement, 1)

		while 0 < total_dt do
			local subdivision = movement._current_spline_subdivision(movement)
			local sub_length = subdivision.length

			if sub_length <= total_dt then
				movement.update(movement, sub_length)

				total_dt = total_dt - sub_length
			else
				movement.update(movement, total_dt)

				total_dt = 0
			end
		end

		self._extra_joint = {
			spline = spline_curve,
			node = node
		}
	end

	if self._is_server then
		self._create_game_object(self)
	end

	return 
end
PayloadExtension._push_player = function (self, player_unit, abs_speed)
	local unit = self._unit
	local self_pos = POSITION_LOOKUP[unit]
	local pose, half_extents = Unit.box(unit, true)
	local player_pos = POSITION_LOOKUP[player_unit]
	half_extents = half_extents * 1.2

	if math.point_is_inside_oobb(player_pos, pose, half_extents) then
		local unit_pos_flat = Vector3.flat(self_pos)
		local player_pos_flat = Vector3.flat(player_pos)
		local pushed_velocity = Vector3.normalize(player_pos_flat - unit_pos_flat) * abs_speed
		local locomotion_extension = ScriptUnit.extension(player_unit, "locomotion_system")

		locomotion_extension.add_external_velocity(locomotion_extension, pushed_velocity)
	end

	return 
end
local RESULT_TABLE = {}
local STAGGERED = {}
PayloadExtension._hit_enemies = function (self, abs_speed, t)
	local payload_unit = self._unit
	local payload_pos = POSITION_LOOKUP[payload_unit]
	local payload_pose, half_extents = Unit.box(payload_unit, true)
	local largest_extent = (half_extents.y < half_extents.x and half_extents.x) or half_extents.y
	largest_extent = (half_extents.z < largest_extent and largest_extent) or half_extents.z
	local radius = largest_extent * 2
	local num_hits = AiUtils.broadphase_query(payload_pos, radius, RESULT_TABLE)

	for i = 1, num_hits, 1 do
		local hit_unit = RESULT_TABLE[i]
		local enemy_pos = POSITION_LOOKUP[hit_unit]
		local inside_small_box = math.point_is_inside_oobb(enemy_pos, payload_pose, half_extents * 1.2)
		local inside_large_box = math.point_is_inside_oobb(enemy_pos, payload_pose, half_extents * 2)

		if inside_small_box and not STAGGERED[hit_unit] then
			STAGGERED[hit_unit] = true
			local payload_forward = Vector3.normalize(Matrix4x4.forward(payload_pose))
			local dot = Vector3.dot(payload_forward, enemy_pos - payload_pos)
			local enemy_in_front = 0 < dot
			local stagger_multiplier = (enemy_in_front and 1 < abs_speed and 2) or 1
			local payload_unit_pos_flat = Vector3.flat(payload_pos)
			local enemy_pos_flat = Vector3.flat(enemy_pos)
			local push_direction = Vector3.normalize(enemy_pos_flat - payload_unit_pos_flat)
			local hazard_type = "payload"
			local hazard_settings = EnvironmentalHazards[hazard_type]
			local hit_ragdoll_actor = nil
			local damage_source = hazard_type
			local power_level = hazard_settings.enemy.power_level or DefaultPowerLevel
			local damage_profile_name = hazard_settings.enemy.damage_profile or "default"
			local damage_profile = DamageProfileTemplates[damage_profile_name]
			local target_index = nil
			local boost_curve_multiplier = 0
			local is_critical_strike = false
			local can_damage = false
			local can_stagger = false
			local blocking = false
			local shield_breaking_hit = false
			local hit_zone_name = "torso"
			local hit_unit = RESULT_TABLE[i]

			DamageUtils.server_apply_hit(t, payload_unit, hit_unit, hit_zone_name, push_direction, hit_ragdoll_actor, damage_source, power_level, damage_profile, target_index, boost_curve_multiplier, is_critical_strike, can_damage, can_stagger, blocking, shield_breaking_hit)
		elseif not inside_small_box and inside_large_box and STAGGERED[hit_unit] then
			STAGGERED[hit_unit] = false
		end
	end

	return 
end
PayloadExtension.update = function (self, unit, input, dt, context, t)
	local num_players_in_proximity, players_in_proximity = self._players_in_proximity(self)
	local has_players_in_proximity = 0 < num_players_in_proximity
	local unit = self._unit
	local game = Managers.state.network:game()
	local id = self._id
	local new_speed = 0
	local spline_curve = self._spline_curve
	local movement = self._spline_curve:movement()
	local current_spline = movement._current_spline(movement)
	local metadata = current_spline.metadata
	local current_spline_index = movement.current_spline_index(movement)

	if id and game then
		if self._is_server then
			local speed_settings = metadata.speed_settings
			local used_speed_settings = (has_players_in_proximity and speed_settings.pushed) or speed_settings.not_pushed
			local bonus_speed = (used_speed_settings.bonus_speed_per_player or 0) * num_players_in_proximity
			local target_speed = used_speed_settings.speed + bonus_speed
			local acceleration = used_speed_settings.acceleration

			if (0 < target_speed and self._previous_status == "end") or (target_speed < 0 and self._previous_status == "start") or not self._activated then
				target_speed = 0
			end

			local force_speed = false
			local old_speed = movement.speed(movement)
			local wanted_speed_change = target_speed - old_speed

			if self._stop_command_given then
				self._stop_command_given = false
				new_speed = 0
			elseif 0 < wanted_speed_change then
				new_speed = math.min(old_speed + acceleration * dt, target_speed)
			elseif wanted_speed_change < 0 then
				new_speed = math.max(old_speed - acceleration * dt, target_speed)
			else
				new_speed = target_speed
			end

			if 0 < old_speed and new_speed < 0 then
				Unit.flow_event(unit, "lua_start_moving_backwards")
			end

			GameSession.set_game_object_field(game, id, "speed", new_speed)

			local current_subdivision_index = movement.current_subdivision_index(movement)
			local current_t = movement.current_t(movement)

			GameSession.set_game_object_field(game, id, "spline_index", current_spline_index)
			GameSession.set_game_object_field(game, id, "subdivision_index", current_subdivision_index)
			GameSession.set_game_object_field(game, id, "spline_t", current_t)

			local flow_event_data = metadata.flow_event_data
			local flow_event = flow_event_data.flow_event
			local event_thrown = flow_event_data.event_thrown
			local push_speed = math.abs(new_speed)

			if has_players_in_proximity and 0.1 < push_speed then
				for i = 1, num_players_in_proximity, 1 do
					self._push_player(self, players_in_proximity[i], push_speed)
				end
			end

			self._hit_enemies(self, push_speed, t)

			if current_spline_index ~= self._previous_spline_index and flow_event and not event_thrown then
				LevelHelper:flow_event(self._world, flow_event)

				flow_event_data.event_thrown = true
				local network_manager = self._network_manager
				local network_transmit = network_manager.network_transmit
				local payload_unit_id = network_manager.game_object_or_level_id(network_manager, unit)

				network_transmit.send_rpc_clients(network_transmit, "rpc_payload_flow_event", payload_unit_id, current_spline_index)
			end
		else
			local error_compensation_speed = self._error_speed_calculation(self, dt, t, game, id, movement)
			new_speed = GameSession.game_object_field(game, id, "speed") + error_compensation_speed
		end
	end

	movement.set_speed(movement, new_speed)

	local status = movement.update(movement, dt, t)

	if self._state ~= "stopped" and math.abs(new_speed) == 0 then
		self._state = "stopped"

		Unit.flow_event(unit, "lua_stopped")
	elseif self._state ~= "moving" and 0 < math.abs(new_speed) then
		if self._previous_status == "start" then
			Unit.flow_event(unit, "lua_start")
		end

		self._state = "moving"

		Unit.flow_event(unit, "lua_moving")
	elseif status == "end" and self._previous_status ~= "end" then
		Unit.flow_event(unit, "lua_end")
	end

	self._previous_status = status
	self._previous_spline_index = current_spline_index

	Unit.set_simple_animation_speed(self._unit, new_speed / ANIM_SPEED, "wheels")
	fassert(movement._t == movement._t, "Nan in spline: %s", self._spline_curve._name)
	Unit.set_local_position(unit, 0, movement.current_position(movement))

	local dir = movement.current_tangent_direction(movement)
	local rot = Quaternion.look(dir, Vector3.up())

	Unit.set_local_rotation(unit, 0, rot)

	if self._extra_joint then
		local inverse_rot = Quaternion.inverse(rot)
		local movement = self._extra_joint.spline:movement()

		movement.set_speed(movement, new_speed)
		movement.update(movement, dt, t)

		local node = self._extra_joint.node
		local tangent_dir = movement.current_tangent_direction(movement)
		local local_tangent_dir = Quaternion.rotate(inverse_rot, tangent_dir)
		local node_rot = Quaternion.look(local_tangent_dir, Vector3.up())

		Unit.set_local_rotation(unit, node, node_rot)
	end

	return 
end
PayloadExtension.payload_flow_event = function (self, spline_index)
	local spline_curve = self._spline_curve
	local splines = spline_curve.splines(spline_curve)
	local spline = splines[spline_index]
	local metadata = spline.metadata
	local flow_event_data = metadata.flow_event_data
	local flow_event = flow_event_data.flow_event

	LevelHelper:flow_event(self._world, flow_event)

	return 
end
local PLAYERS_IN_PROXIMITY = {}
PayloadExtension._players_in_proximity = function (self)
	local player_units = PLAYER_UNITS
	local num_player_units = #player_units
	local positions = POSITION_LOOKUP
	local payload_position = Unit.world_position(self._unit, 0)
	local num_players_in_proximity = 0

	for i = 1, num_player_units, 1 do
		local unit = player_units[i]
		local position = positions[unit]
		local distance = Vector3.distance(position, payload_position)
		local status_extension = ScriptUnit.extension(unit, "status_system")

		if distance < 5 and not status_extension.is_disabled(status_extension) then
			num_players_in_proximity = num_players_in_proximity + 1
			PLAYERS_IN_PROXIMITY[num_players_in_proximity] = unit
		end
	end

	return num_players_in_proximity, PLAYERS_IN_PROXIMITY
end
PayloadExtension._error_speed_calculation = function (self, dt, t, game, id, movement)
	local spline_index = GameSession.game_object_field(game, id, "spline_index")
	local subdiv = GameSession.game_object_field(game, id, "subdivision_index")
	local spline_t = GameSession.game_object_field(game, id, "spline_t")
	local old_vals = self._last_synched_spline_values

	if old_vals.spline_index ~= spline_index or old_vals.subdivision_index ~= subdiv or old_vals.spline_t ~= spline_t then
		local curr_spline_index = movement.current_spline_index(movement)
		local curr_subdivision_index = movement.current_subdivision_index(movement)
		local curr_spline_t = movement.current_t(movement)
		local error_distance = movement.distance(movement, curr_spline_index, curr_subdivision_index, curr_spline_t, spline_index, subdiv, spline_t)
		old_vals.spline_index = spline_index
		old_vals.subdivision_index = subdiv
		old_vals.spline_t = spline_t
		old_vals.error_compensation_speed = error_distance / ERROR_RECOUP_TIME
		old_vals.last_synch_time = t
	elseif ERROR_RECOUP_TIME <= t - old_vals.last_synch_time then
		old_vals.error_compensation_speed = 0
	end

	return old_vals.error_compensation_speed
end
PayloadExtension.set_game_object_id = function (self, game_object_id)
	local game = self._game
	local spline_index = GameSession.game_object_field(game, game_object_id, "spline_index")
	local subdivision_index = GameSession.game_object_field(game, game_object_id, "subdivision_index")
	local spline_t = GameSession.game_object_field(game, game_object_id, "spline_t")
	local speed = GameSession.game_object_field(game, game_object_id, "speed")
	local movement = self._spline_curve:movement()

	movement.set_spline_index(movement, spline_index, subdivision_index, spline_t)
	movement.set_speed(movement, speed)

	self._id = game_object_id

	return 
end
local gizmo_point_map = {}
PayloadExtension._init_movement_spline = function (self, world, unit, payload_gizmos)
	local spline_name = Unit.get_data(unit, "spline_name")
	local level = LevelHelper:current_level(world)
	local source_spline_points = Level.spline(level, spline_name)
	local spline_points = source_spline_points

	fassert(0 < #spline_points, "Could not find spline called %s for Payload unit in level, wrong name? or payload unit is used as a prop unintentionally", spline_name)

	local spline_curve = SplineCurve:new(spline_points, "Bezier", "SplineMovementHermiteInterpolatedMetered", spline_name, 10)
	local splines = spline_curve.splines(spline_curve)

	table.clear(gizmo_point_map)

	if payload_gizmos then
		for i = 1, #payload_gizmos, 1 do
			local gizmo_unit = payload_gizmos[i]
			local gizmo_position = Unit.world_position(gizmo_unit, 0)
			local smallest_distance = math.huge
			local point = nil

			for index, spline in ipairs(splines) do
				local points = spline.points
				local point_position = points[1]:unbox()
				local distance = Vector3.distance(gizmo_position, point_position)

				if distance < smallest_distance then
					smallest_distance = distance
					point = points[1]
				end

				if index == #splines then
					local point_position = points[4]:unbox()
					local distance = Vector3.distance(gizmo_position, point_position)

					if distance < smallest_distance then
						smallest_distance = distance
						point = points[4]
					end
				end
			end

			gizmo_point_map[point] = gizmo_unit
		end
	end

	local speed_setting = "flat"

	for index, spline in ipairs(splines) do
		local points = spline.points
		local point = points[1]
		local gizmo_unit = gizmo_point_map[point]
		local flow_event = nil

		if gizmo_unit then
			local unit_speed_setting = Unit.get_data(gizmo_unit, "speed_setting")
			local unit_flow_event = Unit.get_data(gizmo_unit, "flow_event")

			if unit_speed_setting ~= "" and not unit_speed_setting then
			end

			flow_event = unit_flow_event ~= "" and unit_flow_event
		end

		local speed_settings = PayloadSpeedSettings[speed_setting]
		local metadata = {
			speed_settings = speed_settings,
			flow_event_data = {
				event_thrown = false,
				flow_event = flow_event
			}
		}
		spline.metadata = metadata
	end

	return spline_curve
end
PayloadExtension._create_game_object = function (self)
	local unit = self._unit
	local movement = self._spline_curve:movement()
	local spline_index = movement.current_spline_index(movement)
	local subdivision_index = movement.current_subdivision_index(movement)
	local spline_t = movement.current_t(movement)
	local speed = movement.speed(movement)
	local game_object_data_table = {
		go_type = NetworkLookup.go_types.payload,
		level_unit_index = self._level_unit_index,
		spline_index = spline_index,
		subdivision_index = subdivision_index,
		spline_t = spline_t,
		speed = speed
	}
	local callback = callback(self, "cb_game_session_disconnect")
	local game_object_id = self._network_manager:create_game_object("payload", game_object_data_table, callback)
	self._id = game_object_id

	return 
end
PayloadExtension.cb_game_session_disconnect = function (self)
	self._game = nil

	return 
end

return 

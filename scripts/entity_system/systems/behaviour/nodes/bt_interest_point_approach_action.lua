require("scripts/entity_system/systems/behaviour/nodes/bt_node")

BTInterestPointApproachAction = class(BTInterestPointApproachAction, BTNode)
BTInterestPointApproachAction.name = "BTInterestPointApproachAction"
BTInterestPointApproachAction.init = function (self, ...)
	BTInterestPointApproachAction.super.init(self, ...)

	return 
end
BTInterestPointApproachAction.enter = function (self, unit, blackboard, t)
	local interest_point_system_api = blackboard.system_api.ai_interest_point_system
	local request = interest_point_system_api.get_claim(blackboard.ip_request_id)
	local point = request.point
	local position = Vector3Aux.unbox(point.position)
	local breed = blackboard.breed
	local allowed_layers = breed.allowed_layers
	local navigation_extension = blackboard.navigation_extension

	navigation_extension.allow_layer(navigation_extension, "doors", false)
	navigation_extension.allow_layer(navigation_extension, "planks", false)
	navigation_extension.set_layer_cost(navigation_extension, "jumps", 2 * allowed_layers.jumps)
	navigation_extension.set_layer_cost(navigation_extension, "ledges", 2 * allowed_layers.ledges)
	navigation_extension.set_layer_cost(navigation_extension, "ledges_with_fence", 2 * allowed_layers.ledges_with_fence)
	navigation_extension.move_to(navigation_extension, position)
	navigation_extension.set_max_speed(navigation_extension, breed.passive_walk_speed)

	blackboard.ip_state = "moving_to_target"
	blackboard.ip_target_position = point.position
	blackboard.ip_target_rotation = point.rotation
	local group_blackboard = blackboard.group_blackboard
	group_blackboard.rats_currently_moving_to_ip = group_blackboard.rats_currently_moving_to_ip + 1

	Managers.state.network:anim_event(unit, "move_fwd")

	blackboard.move_state = "moving"

	return 
end
BTInterestPointApproachAction.leave = function (self, unit, blackboard, t, reason, destroy)
	blackboard.ip_state = nil
	blackboard.ip_target_position = nil
	blackboard.ip_target_rotation = nil
	local breed = blackboard.breed
	local allowed_layers = breed.allowed_layers
	local default_move_speed = AiUtils.get_default_breed_move_speed(unit, blackboard)
	local navigation_extension = blackboard.navigation_extension

	navigation_extension.allow_layer(navigation_extension, "doors", true)
	navigation_extension.allow_layer(navigation_extension, "planks", true)
	navigation_extension.set_layer_cost(navigation_extension, "jumps", allowed_layers.jumps)
	navigation_extension.set_layer_cost(navigation_extension, "ledges", allowed_layers.ledges)
	navigation_extension.set_layer_cost(navigation_extension, "ledges_with_fence", allowed_layers.ledges_with_fence)
	navigation_extension.set_max_speed(navigation_extension, default_move_speed)

	if reason == "failed" then
		if AiUtils.unit_alive(unit) then
			local interest_point_system_api = blackboard.system_api.ai_interest_point_system

			interest_point_system_api.release_claim(blackboard.ip_request_id)

			blackboard.ip_request_id = nil
		end
	elseif reason == "aborted" then
	end

	local group_blackboard = blackboard.group_blackboard
	group_blackboard.rats_currently_moving_to_ip = group_blackboard.rats_currently_moving_to_ip - 1

	return 
end
BTInterestPointApproachAction.run = function (self, unit, blackboard, t, dt)
	if script_data.ai_interest_point_debug then
		Debug.text("BTInterestPointApproachAction state = %s", blackboard.ip_state)
		QuickDrawer:circle(blackboard.ip_root_pos:unbox(), 20, Vector3.up())
	end

	local navigation_extension = blackboard.navigation_extension

	if blackboard.ip_state == "moving_to_target" and navigation_extension.has_reached_destination(navigation_extension) then
		navigation_extension.set_enabled(navigation_extension, false)

		blackboard.ip_state = "adjusting_to_target"
	end

	if blackboard.ip_state == "adjusting_to_target" then
		local locomotion_extension = blackboard.locomotion_extension
		local target_rotation = blackboard.ip_target_rotation:unbox()
		local target_position = Vector3Aux.unbox(blackboard.ip_target_position)
		local unit_position = POSITION_LOOKUP[unit]

		if Vector3.distance_squared(unit_position, target_position) < 0.0625 then
			locomotion_extension.teleport_to(locomotion_extension, target_position, target_rotation)
			locomotion_extension.set_wanted_velocity(locomotion_extension, Vector3.zero())

			return "done"
		else
			local direction = Vector3.normalize(target_position - unit_position)

			locomotion_extension.set_wanted_velocity(locomotion_extension, direction * 2)
			locomotion_extension.set_wanted_rotation(locomotion_extension, target_rotation)
		end
	end

	return "running"
end

return 

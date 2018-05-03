require("scripts/entity_system/systems/behaviour/nodes/bt_node")

BTBotVentOverchargeAction = class(BTBotVentOverchargeAction, BTNode)
BTBotVentOverchargeAction.init = function (self, ...)
	BTBotVentOverchargeAction.super.init(self, ...)

	return 
end
BTBotVentOverchargeAction.name = "BTBotVentOverchargeAction"
BTBotVentOverchargeAction.enter = function (self, unit, blackboard, t)
	blackboard.venting = true

	return 
end
BTBotVentOverchargeAction.leave = function (self, unit, blackboard, t, reason, destroy)
	blackboard.venting = false

	return 
end
BTBotVentOverchargeAction.run = function (self, unit, blackboard, t, dt)
	local input_extension = blackboard.input_extension

	input_extension.weapon_reload(input_extension)

	return "running", "evaluate"
end

return 

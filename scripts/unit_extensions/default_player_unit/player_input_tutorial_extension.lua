require("scripts/unit_extensions/generic/generic_state_machine")

local is_windows_platform = PLATFORM == "win32"
PlayerInputTutorialExtension = class(PlayerInputTutorialExtension)
PlayerInputTutorialExtension.get_window_is_in_focus = function ()
	local is_in_focus = false

	if is_windows_platform then
		if Window.has_focus() then
			is_in_focus = true
		end
	else
		is_in_focus = true
	end

	return is_in_focus
end
PlayerInputTutorialExtension.init = function (self, extension_init_context, unit, extension_init_data)
	self.unit = unit
	self.player = extension_init_data.player
	self.input_service = self.player.input_source
	self.enabled = true
	self.has_released_input = false
	self.input_buffer_timer = nil
	self.buffer_key = nil
	self.input_buffer = nil
	self.name = "PlayerInputTutorialExtension"
	self.new_input_buffer_timer = 0
	self.new_input_buffer = nil
	self.new_buffer_key = nil
	self.last_added_buffer_time = 0
	self.new_buffer_key_doubleclick_window = nil
	self.input_buffer_reset = false
	self.added_stun_buffer = false
	self.wield_cooldown = false
	self.wield_cooldown_timer = 0
	self.wield_cooldown_timer_clock = 0
	self.wield_scroll_value = nil
	self.double_tap_timers = {}
	self.allowed_table = {}
	self.disallowed_table = {}
	self.minimum_dodge_input = 0.3
	self.double_tap_dodge = Application.user_setting("double_tap_dodge")
	self.toggle_crouch = Application.user_setting("toggle_crouch")
	self.toggle_alternate_attack = Application.user_setting("toggle_alternate_attack")
	self.priority_input = {
		wield_2 = true,
		wield_next = true,
		wield_5 = true,
		wield_prev = true,
		wield_scroll = true,
		wield_3 = true,
		wield_1 = true,
		wield_4 = true,
		wield_switch = true
	}

	return 
end
PlayerInputTutorialExtension.destroy = function (self)
	return 
end
PlayerInputTutorialExtension.reset = function (self)
	return 
end
PlayerInputTutorialExtension.update = function (self, unit, input, dt, context, t)
	if self.buffer_key then
	end

	if self.input_buffer_reset then
		self.last_added_buffer_time = t
		self.input_buffer_reset = false
	end

	if self.new_input_buffer then
		if self.last_added_buffer_time + (self.new_buffer_key_doubleclick_window or 0.2) < t then
			self.input_buffer_timer = self.new_input_buffer_timer
			self.input_buffer = self.new_input_buffer
			self.buffer_key = self.new_buffer_key
			self.last_added_buffer_time = t
		end

		self.new_input_buffer_timer = 0
		self.new_input_buffer = nil
		self.new_buffer_key = nil
	end

	if self.input_buffer then
		self.input_buffer_timer = self.input_buffer_timer - dt

		if self.input_buffer_timer <= 0 then
			self.input_buffer_timer = 0
			self.input_buffer = nil
			self.buffer_key = nil
		end
	end

	if self.wield_cooldown then
		if self.wield_cooldown_timer < t then
			self.wield_cooldown = false
			self.wield_cooldown_timer_clock = 0
		else
			self.wield_cooldown_timer_clock = self.wield_cooldown_timer_clock + dt
		end
	end

	return 
end
PlayerInputTutorialExtension.start_double_tap = function (self, input_key, t)
	self.double_tap_timers[input_key] = t

	return 
end
PlayerInputTutorialExtension.clear_double_tap = function (self, input_key)
	self.double_tap_timers[input_key] = nil

	return 
end
PlayerInputTutorialExtension.was_double_tap = function (self, input_key, t, max_duration)
	local last_double_tap = self.double_tap_timers[input_key]

	return last_double_tap and t < last_double_tap + max_duration
end
PlayerInputTutorialExtension.get = function (self, input_key, consume)
	local value = self.input_service:get(input_key, consume)

	if not self.enabled or not PlayerInputTutorialExtension.get_window_is_in_focus() then
		if PlayerInputTutorialExtension.get_window_is_in_focus() and self.allowed_table[input_key] then
			return value
		else
			local value_type = type(value)

			if value_type == "userdata" then
				return Vector3.zero()
			end

			return nil
		end
	elseif self.disallowed_table[input_key] then
		local value_type = type(value)

		if value_type == "userdata" then
			return Vector3.zero()
		end

		return nil
	end

	return value
end
PlayerInputTutorialExtension.set_enabled = function (self, enabled)
	self.enabled = enabled

	return 
end
PlayerInputTutorialExtension.set_allowed_inputs = function (self, allowed_table)
	self.allowed_table = allowed_table or {}

	return 
end
PlayerInputTutorialExtension.set_disallowed_inputs = function (self, disallowed_table)
	self.disallowed_table = disallowed_table or {}

	return 
end
PlayerInputTutorialExtension.allowed_input_table = function (self)
	return self.allowed_table
end
PlayerInputTutorialExtension.disallowed_input_table = function (self)
	return self.disallowed_table
end
PlayerInputTutorialExtension.get_last_scroll_value = function (self)
	return self.wield_scroll_value
end
PlayerInputTutorialExtension.set_last_scroll_value = function (self, scroll_value)
	self.wield_scroll_value = scroll_value

	return 
end
PlayerInputTutorialExtension.released_input = function (self, input)
	if self.has_released_input then
		return true
	end

	local get_input_release = self.input_service:get(input)

	if not get_input_release then
		self.has_released_input = true
	end

	return self.has_released_input
end
PlayerInputTutorialExtension.reset_release_input = function (self)
	self.has_released_input = false

	return true
end
PlayerInputTutorialExtension.get_wield_cooldown = function (self, override_cooldown_time)
	if override_cooldown_time then
		if override_cooldown_time < self.wield_cooldown_timer_clock then
			return true
		else
			self.wield_cooldown = false

			return false
		end
	elseif self.wield_cooldown then
		return true
	end

	return false
end
PlayerInputTutorialExtension.add_wield_cooldown = function (self, cooldown_time)
	self.wield_cooldown = true
	self.wield_cooldown_timer = cooldown_time

	return 
end
PlayerInputTutorialExtension.get_buffer = function (self, input_key)
	if self.input_buffer_timer and self.buffer_key == input_key then
		return self.input_buffer
	end

	return nil
end
PlayerInputTutorialExtension.add_buffer = function (self, input_key, doubleclick_window)
	if input_key == "action_one_hold" or (self.priority_input[self.buffer_key] and not self.priority_input[input_key]) then
		return 
	elseif input_key == "action_two_hold" then
		return 
	end

	local value = self.input_service:get(input_key)

	if value then
		if self.priority_input[input_key] then
			self.input_buffer_timer = 1
			self.input_buffer = value
			self.buffer_key = input_key
		else
			self.new_input_buffer_timer = 0.6
			self.new_input_buffer = value
			self.new_buffer_key = input_key
			self.new_buffer_key_doubleclick_window = doubleclick_window
		end
	end

	return 
end
PlayerInputTutorialExtension.add_stun_buffer = function (self, input_key)
	self.added_stun_buffer = true
	self.input_buffer_timer = 10
	self.input_buffer = 1
	self.buffer_key = input_key

	return 
end
PlayerInputTutorialExtension.reset_input_buffer = function (self)
	if self.buffer_key == "action_one" and not self.input_service:get("action_one_hold") then
		self.buffer_key = "action_one_release"
		self.input_buffer_timer = 0.5

		return 
	end

	if self.added_stun_buffer then
		self.added_stun_buffer = false

		if self.priority_input[self.buffer_key] then
			self.input_buffer_timer = 0
			self.input_buffer = nil
			self.buffer_key = nil
		end

		return 
	else
		self.input_buffer_timer = 0
		self.input_buffer = nil
		self.buffer_key = nil
	end

	return 
end
PlayerInputTutorialExtension.clear_input_buffer = function (self)
	self.input_buffer_reset = true
	self.input_buffer_timer = 0
	self.input_buffer = nil
	self.buffer_key = nil
	self.new_input_buffer_timer = 0
	self.new_input_buffer = nil
	self.new_buffer_key = nil

	return 
end

return 

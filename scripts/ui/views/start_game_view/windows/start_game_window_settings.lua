local definitions = local_require("scripts/ui/views/start_game_view/windows/definitions/start_game_window_settings_definitions")
local widget_definitions = definitions.widgets
local scenegraph_definition = definitions.scenegraph_definition
local animation_definitions = definitions.animation_definitions
local DO_RELOAD = false
local private_settings = {
	{
		value = false,
		display_name = Localize("start_game_window_other_options_public")
	},
	{
		value = true,
		display_name = Localize("start_game_window_other_options_private")
	}
}
StartGameWindowSettings = class(StartGameWindowSettings)
StartGameWindowSettings.NAME = "StartGameWindowSettings"

StartGameWindowSettings.on_enter = function (self, params, offset)
	print("[StartGameWindow] Enter Substate StartGameWindowSettings")

	self.parent = params.parent
	local ingame_ui_context = params.ingame_ui_context
	self.ui_renderer = ingame_ui_context.ui_renderer
	self.input_manager = ingame_ui_context.input_manager
	self.statistics_db = ingame_ui_context.statistics_db
	self.render_settings = {
		snap_pixel_positions = true
	}
	self._network_lobby = ingame_ui_context.network_lobby
	local player_manager = Managers.player
	local local_player = player_manager:local_player()
	self._stats_id = local_player:stats_id()
	self.player_manager = player_manager
	self.peer_id = ingame_ui_context.peer_id
	self._animations = {}
	self._ui_animations = {}

	self:create_ui_elements(params, offset)
	self:_update_difficulty_option()
end

StartGameWindowSettings.create_ui_elements = function (self, params, offset)
	self.ui_scenegraph = UISceneGraph.init_scenegraph(scenegraph_definition)
	local widgets = {}
	local widgets_by_name = {}

	for name, widget_definition in pairs(widget_definitions) do
		local widget = UIWidget.init(widget_definition)
		widgets[#widgets + 1] = widget
		widgets_by_name[name] = widget
	end

	self._widgets = widgets
	self._widgets_by_name = widgets_by_name

	UIRenderer.clear_scenegraph_queue(self.ui_renderer)

	self.ui_animator = UIAnimator:new(self.ui_scenegraph, animation_definitions)

	if offset then
		local window_position = self.ui_scenegraph.window.local_position
		window_position[1] = window_position[1] + offset[1]
		window_position[2] = window_position[2] + offset[2]
		window_position[3] = window_position[3] + offset[3]
	end

	widgets_by_name.play_button.content.button_hotspot.disable_button = true
	widgets_by_name.game_option_2.content.button_hotspot.disable_button = true

	self:_set_additional_options_enabled_state(false)

	local game_option_1 = widgets_by_name.game_option_1
	local anim = self:_animate_pulse(game_option_1.style.glow_frame.color, 1, 255, 100, 2)

	UIWidget.animate(game_option_1, anim)

	local game_option_2 = widgets_by_name.game_option_2
	local anim = self:_animate_pulse(game_option_2.style.glow_frame.color, 1, 255, 100, 2)

	UIWidget.animate(game_option_2, anim)
end

StartGameWindowSettings._set_additional_options_enabled_state = function (self, enabled)
	local widgets_by_name = self._widgets_by_name
	widgets_by_name.additional_option.content.button_hotspot.disable_button = not enabled
	local private_button = widgets_by_name.private_button
	private_button.content.button_hotspot.disable_button = not enabled
	local host_button = widgets_by_name.host_button
	host_button.content.button_hotspot.disable_button = not enabled
	local strict_matchmaking_button = widgets_by_name.strict_matchmaking_button
	strict_matchmaking_button.content.button_hotspot.disable_button = not enabled
	self._additional_option_enabled = enabled
end

StartGameWindowSettings.on_exit = function (self, params)
	print("[StartGameWindow] Exit Substate StartGameWindowSettings")

	self.ui_animator = nil
end

StartGameWindowSettings.update = function (self, dt, t)
	if DO_RELOAD then
		DO_RELOAD = false

		self:create_ui_elements()
	end

	self:_update_mission_selection()

	if self._additional_option_enabled then
		self:_update_additional_options()
	end

	self:_update_difficulty_option()
	self:_update_animations(dt)
	self:_handle_input(dt, t)
	self:draw(dt)
end

StartGameWindowSettings.post_update = function (self, dt, t)
	return
end

StartGameWindowSettings._update_animations = function (self, dt)
	self:_update_game_options_hover_effect()

	local ui_animations = self._ui_animations
	local animations = self._animations
	local ui_animator = self.ui_animator

	for name, animation in pairs(ui_animations) do
		UIAnimation.update(animation, dt)

		if UIAnimation.completed(animation) then
			ui_animations[name] = nil
		end
	end

	ui_animator:update(dt)

	for animation_name, animation_id in pairs(animations) do
		if ui_animator:is_animation_completed(animation_id) then
			ui_animator:stop_animation(animation_id)

			animations[animation_name] = nil
		end
	end

	local widgets_by_name = self._widgets_by_name
end

StartGameWindowSettings._is_button_pressed = function (self, widget)
	local content = widget.content
	local hotspot = content.button_hotspot

	if hotspot.on_release then
		hotspot.on_release = false

		return true
	end
end

StartGameWindowSettings._is_button_released = function (self, widget)
	local content = widget.content
	local hotspot = content.button_hotspot

	if hotspot.on_release then
		hotspot.on_release = false

		return true
	end
end

StartGameWindowSettings._is_stepper_button_pressed = function (self, widget)
	local content = widget.content
	local hotspot_left = content.button_hotspot_left
	local hotspot_right = content.button_hotspot_right

	if hotspot_left.on_release then
		hotspot_left.on_release = false

		return true, -1
	elseif hotspot_right.on_release then
		hotspot_right.on_release = false

		return true, 1
	end
end

StartGameWindowSettings._is_tab_pressed = function (self, widget)
	local widget_content = widget.content
	local amount = widget_content.amount

	for i = 1, amount, 1 do
		local name_sufix = "_" .. tostring(i)
		local hotspot_name = "hotspot" .. name_sufix
		local hotspot_content = widget_content[hotspot_name]

		if hotspot_content.on_release and not hotspot_content.is_selected then
			return i
		end
	end
end

StartGameWindowSettings._select_tab_by_index = function (self, widget, index)
	local widget_content = widget.content
	local amount = widget_content.amount

	for i = 1, amount, 1 do
		local name_sufix = "_" .. tostring(i)
		local hotspot_name = "hotspot" .. name_sufix
		local hotspot_content = widget_content[hotspot_name]
		hotspot_content.is_selected = i == index
	end
end

StartGameWindowSettings._is_button_hover_enter = function (self, widget)
	local content = widget.content
	local hotspot = content.button_hotspot

	return hotspot.on_hover_enter
end

StartGameWindowSettings._is_button_hover_exit = function (self, widget)
	local content = widget.content
	local hotspot = content.button_hotspot

	return hotspot.on_hover_exit
end

StartGameWindowSettings._is_button_selected = function (self, widget)
	local content = widget.content
	local hotspot = content.button_hotspot

	return hotspot.is_selected
end

StartGameWindowSettings._is_other_option_button_selected = function (self, widget, current_option)
	if self:_is_button_released(widget) then
		local is_selected = not current_option

		if is_selected then
			self:_play_sound("play_gui_lobby_button_03_private")
		else
			self:_play_sound("play_gui_lobby_button_03_public")
		end

		return is_selected
	end

	return nil
end

StartGameWindowSettings._handle_input = function (self, dt, t)
	local parent = self.parent
	local widgets_by_name = self._widgets_by_name
	local gamepad_active = Managers.input:is_device_active("gamepad")
	local input_service = self.parent:window_input_service()

	if self._additional_option_enabled then
		local host_button = widgets_by_name.host_button
		local private_button = widgets_by_name.private_button
		local strict_matchmaking_button = widgets_by_name.strict_matchmaking_button

		UIWidgetUtils.animate_default_checkbox_button(private_button, dt)
		UIWidgetUtils.animate_default_checkbox_button(host_button, dt)
		UIWidgetUtils.animate_default_checkbox_button(strict_matchmaking_button, dt)

		if self:_is_button_hover_enter(widgets_by_name.game_option_1) or self:_is_button_hover_enter(widgets_by_name.game_option_2) or self:_is_button_hover_enter(widgets_by_name.play_button) then
			self:_play_sound("play_gui_lobby_button_01_difficulty_confirm_hover")
		end

		if self:_is_button_hover_enter(private_button) or self:_is_button_hover_enter(host_button) or self:_is_button_hover_enter(strict_matchmaking_button) then
			self:_play_sound("play_gui_lobby_button_01_difficulty_confirm_hover")
		end

		local changed_selection = self:_is_other_option_button_selected(private_button, self._private_enabled)

		if changed_selection ~= nil then
			parent:set_private_option_enabled(changed_selection)
		end

		changed_selection = self:_is_other_option_button_selected(host_button, self._always_host_enabled)

		if changed_selection ~= nil then
			parent:set_always_host_option_enabled(changed_selection)
		end

		changed_selection = self:_is_other_option_button_selected(strict_matchmaking_button, self._strict_matchmaking_enabled)

		if changed_selection ~= nil then
			parent:set_strict_matchmaking_option_enabled(changed_selection)
		end
	end

	if self:_is_button_released(widgets_by_name.game_option_2) then
		parent:set_layout(5)
	elseif self:_is_button_released(widgets_by_name.game_option_1) then
		parent:set_layout(6)
	end

	local play_pressed = gamepad_active and self._enable_play and input_service:get("refresh_press")

	if self:_is_button_released(widgets_by_name.play_button) or play_pressed then
		parent:play(t)
	end
end

StartGameWindowSettings._play_sound = function (self, event)
	self.parent:play_sound(event)
end

StartGameWindowSettings._update_game_options_hover_effect = function (self)
	local widgets_by_name = self._widgets_by_name
	local widget_prefix = "game_option_"

	for i = 1, 2, 1 do
		local widget_name = widget_prefix .. i
		local widget = widgets_by_name[widget_name]

		if self:_is_button_hover_enter(widget) then
			self:_on_option_button_hover_enter(i)
		elseif self:_is_button_hover_exit(widget) then
			self:_on_option_button_hover_exit(i)
		end
	end
end

StartGameWindowSettings._on_option_button_hover_enter = function (self, index, instant)
	local widgets_by_name = self._widgets_by_name
	local widget_name = "game_option_" .. index
	local widget = widgets_by_name[widget_name]

	self:_create_style_animation_enter(widget, 255, "glow", index, instant)
	self:_create_style_animation_enter(widget, 255, "icon_glow", index, instant)
	self:_create_style_animation_exit(widget, 0, "button_hover_rect", index, instant)
end

StartGameWindowSettings._on_option_button_hover_exit = function (self, index, instant)
	local widgets_by_name = self._widgets_by_name
	local widget_name = "game_option_" .. index
	local widget = widgets_by_name[widget_name]

	self:_create_style_animation_exit(widget, 0, "glow", index, instant)
	self:_create_style_animation_exit(widget, 0, "icon_glow", index, instant)
	self:_create_style_animation_enter(widget, 30, "button_hover_rect", index, instant)
end

StartGameWindowSettings._update_additional_options = function (self)
	local parent = self.parent
	local private_enabled = parent:is_private_option_enabled()
	local always_host_enabled = parent:is_always_host_option_enabled()
	local strict_matchmaking_enabled = parent:is_strict_matchmaking_option_enabled()
	local twitch_active = Managers.twitch and Managers.twitch:is_connected()
	local lobby = self._network_lobby
	local num_members = #lobby:members():get_members()
	local is_alone = num_members == 1

	if is_alone ~= self._is_alone or private_enabled ~= self._private_enabled or always_host_enabled ~= self._always_host_enabled or strict_matchmaking_enabled ~= self._strict_matchmaking_enabled or twitch_active ~= self._twitch_active then
		local widgets_by_name = self._widgets_by_name
		local private_is_selected = private_enabled
		local private_is_disabled = twitch_active
		local always_host_is_selected = private_enabled or not is_alone or always_host_enabled
		local always_host_is_disabled = private_enabled or not is_alone or twitch_active
		local strict_matchmaking_is_selected = not always_host_enabled and not private_enabled and is_alone and strict_matchmaking_enabled
		local strict_matchmaking_is_disabled = private_enabled or always_host_enabled or not is_alone or twitch_active
		local private_hotspot = widgets_by_name.private_button.content.button_hotspot
		private_hotspot.disable_button = private_is_disabled
		private_hotspot.is_selected = private_is_selected
		local host_hotspot = widgets_by_name.host_button.content.button_hotspot
		host_hotspot.disable_button = always_host_is_disabled
		host_hotspot.is_selected = always_host_is_selected
		local strict_matchmaking_hotspot = widgets_by_name.strict_matchmaking_button.content.button_hotspot
		strict_matchmaking_hotspot.disable_button = strict_matchmaking_is_disabled
		strict_matchmaking_hotspot.is_selected = strict_matchmaking_is_selected
		self._private_enabled = private_enabled
		self._always_host_enabled = always_host_enabled
		self._strict_matchmaking_enabled = strict_matchmaking_enabled
		self._twitch_active = twitch_active
		self._is_alone = is_alone
	end
end

StartGameWindowSettings._update_difficulty_option = function (self)
	local parent = self.parent
	local difficulty_key = parent:get_difficulty_option()

	if difficulty_key ~= self._difficulty_key then
		self:_set_difficulty_option(difficulty_key)

		self._difficulty_key = difficulty_key

		self:_set_additional_options_enabled_state(true)

		local widgets_by_name = self._widgets_by_name
		self._enable_play = DifficultySettings[difficulty_key] ~= nil
		widgets_by_name.play_button.content.button_hotspot.disable_button = not self._enable_play

		if self._enable_play then
			self.parent.parent:set_input_description("play_available")
		else
			self.parent.parent:set_input_description(nil)
		end
	end
end

StartGameWindowSettings._set_difficulty_option = function (self, difficulty_key)
	local widgets_by_name = self._widgets_by_name
	local difficulty_settings = DifficultySettings[difficulty_key]
	local display_name = difficulty_settings and difficulty_settings.display_name
	local display_image = difficulty_settings and difficulty_settings.display_image
	local completed_frame_texture = (difficulty_settings and difficulty_settings.completed_frame_texture) or "map_frame_00"
	widgets_by_name.game_option_2.content.option_text = (display_name and Localize(display_name)) or ""
	widgets_by_name.game_option_2.content.icon = display_image or nil
	widgets_by_name.game_option_2.content.icon_frame = completed_frame_texture
end

StartGameWindowSettings._update_mission_selection = function (self)
	local parent = self.parent
	local selected_level_id = parent:get_selected_level_id()

	if selected_level_id ~= self._selected_level_id then
		self:_set_selected_level(selected_level_id)

		self._selected_level_id = selected_level_id
		local widgets_by_name = self._widgets_by_name
		widgets_by_name.game_option_2.content.button_hotspot.disable_button = selected_level_id == nil
	end
end

StartGameWindowSettings._set_selected_level = function (self, level_id)
	local widget = self._widgets_by_name.game_option_1
	local text = "n/a"

	if level_id then
		local level_settings = LevelSettings[level_id]
		local display_name = level_settings.display_name
		local level_image = level_settings.level_image
		text = Localize(display_name)
		local icon_texture_settings = UIAtlasHelper.get_atlas_settings_by_texture_name(level_image)
		local texture_size = widget.style.icon.texture_size
		texture_size[1] = icon_texture_settings.size[1]
		texture_size[2] = icon_texture_settings.size[2]
		widget.content.icon = level_image
		local completed_difficulty_index = LevelUnlockUtils.completed_level_difficulty_index(self.statistics_db, self._stats_id, level_id) or 0
		local level_frame = self:_get_selection_frame_by_difficulty_index(completed_difficulty_index)
		widget.content.icon_frame = level_frame
	end

	widget.content.option_text = text
end

StartGameWindowSettings._get_selection_frame_by_difficulty_index = function (self, difficulty_index)
	local completed_frame_texture = "map_frame_00"

	if 0 < difficulty_index then
		local difficulty_key = DefaultDifficulties[difficulty_index]
		local difficulty_manager = Managers.state.difficulty
		local settings = DifficultySettings[difficulty_key]
		completed_frame_texture = settings.completed_frame_texture
	end

	return completed_frame_texture
end

StartGameWindowSettings._exit = function (self, selected_level)
	self.exit = true
	self.exit_level_id = selected_level
end

StartGameWindowSettings.draw = function (self, dt)
	local ui_renderer = self.ui_renderer
	local ui_scenegraph = self.ui_scenegraph
	local input_service = self.parent:window_input_service()

	UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, nil, self.render_settings)

	for _, widget in ipairs(self._widgets) do
		UIRenderer.draw_widget(ui_renderer, widget)
	end

	local active_node_widgets = self._active_node_widgets

	if active_node_widgets then
		for _, widget in ipairs(active_node_widgets) do
			UIRenderer.draw_widget(ui_renderer, widget)
		end
	end

	UIRenderer.end_pass(ui_renderer)
end

StartGameWindowSettings._create_style_animation_enter = function (self, widget, target_value, style_id, widget_index, instant)
	local ui_animations = self._ui_animations
	local animation_name = "game_option_" .. style_id
	local widget_style = widget.style
	local pass_style = widget_style[style_id]

	if not pass_style then
		return
	end

	local current_color_value = pass_style.color[1]
	local target_color_value = target_value
	local total_time = 0.2
	local animation_duration = (1 - current_color_value / target_color_value) * total_time

	if 0 < animation_duration and not instant then
		ui_animations[animation_name .. "_hover_" .. widget_index] = self:_animate_element_by_time(pass_style.color, 1, current_color_value, target_color_value, animation_duration)
	else
		pass_style.color[1] = target_color_value
	end
end

StartGameWindowSettings._create_style_animation_exit = function (self, widget, target_value, style_id, widget_index, instant)
	local ui_animations = self._ui_animations
	local animation_name = "game_option_" .. style_id
	local widget_style = widget.style
	local pass_style = widget_style[style_id]

	if not pass_style then
		return
	end

	local current_color_value = pass_style.color[1]
	local target_color_value = target_value
	local total_time = 0.2
	local animation_duration = current_color_value / 255 * total_time

	if 0 < animation_duration and not instant then
		ui_animations[animation_name .. "_hover_" .. widget_index] = self:_animate_element_by_time(pass_style.color, 1, current_color_value, target_color_value, animation_duration)
	else
		pass_style.color[1] = target_color_value
	end
end

StartGameWindowSettings._animate_pulse = function (self, target, target_index, from, to, speed)
	local new_animation = UIAnimation.init(UIAnimation.pulse_animation, target, target_index, from, to, speed)

	return new_animation
end

StartGameWindowSettings._animate_element_by_time = function (self, target, target_index, from, to, time)
	local new_animation = UIAnimation.init(UIAnimation.function_by_time, target, target_index, from, to, time, math.ease_out_quad)

	return new_animation
end

StartGameWindowSettings._animate_element_by_catmullrom = function (self, target, target_index, target_value, p0, p1, p2, p3, time)
	local new_animation = UIAnimation.init(UIAnimation.catmullrom, target, target_index, target_value, p0, p1, p2, p3, time)

	return new_animation
end

return

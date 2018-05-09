require("scripts/settings/profiles/sp_profiles")

local definitions = local_require("scripts/ui/views/start_menu_view/states/definitions/start_menu_state_overview_definitions")
local widget_definitions = definitions.widgets
local generic_input_actions = definitions.generic_input_actions
local animation_definitions = definitions.animation_definitions
local scenegraph_definition = definitions.scenegraph_definition
local DO_RELOAD = false
local fake_input_service = {
	get = function ()
		return
	end,
	has = function ()
		return
	end
}
local menu_functions = {
	function (this)
		local input_manager = Managers.input

		input_manager.block_device_except_service(input_manager, "options_menu", "gamepad")
		this._activate_view(this, "options_view")
	end,
	function (this)
		Managers.state.game_mode:start_specific_level("prologue")
	end,
	function (this)
		this._activate_view(this, "credits_view")
	end
}
StartMenuStateOverview = class(StartMenuStateOverview)
StartMenuStateOverview.NAME = "StartMenuStateOverview"

StartMenuStateOverview.on_enter = function (self, params)
	self.parent:clear_wanted_state()
	print("[HeroViewState] Enter Substate StartMenuStateOverview")

	self._hero_name = params.hero_name
	local ingame_ui_context = params.ingame_ui_context
	self.ingame_ui_context = ingame_ui_context
	self.ui_renderer = ingame_ui_context.ui_renderer
	self.ui_top_renderer = ingame_ui_context.ui_top_renderer
	self.input_manager = ingame_ui_context.input_manager
	self.statistics_db = ingame_ui_context.statistics_db
	self.render_settings = {
		snap_pixel_positions = true
	}
	self.profile_synchronizer = ingame_ui_context.profile_synchronizer
	self.is_server = ingame_ui_context.is_server
	self.world_previewer = params.world_previewer
	self.wwise_world = params.wwise_world
	self.platform = PLATFORM
	local player_manager = Managers.player
	local local_player = player_manager.local_player(player_manager)
	self._stats_id = local_player.stats_id(local_player)
	self.player_manager = player_manager
	self.peer_id = ingame_ui_context.peer_id
	self.local_player_id = ingame_ui_context.local_player_id
	self.local_player = local_player
	self._animations = {}
	self._ui_animations = {}
	self._available_profiles = {}

	self._init_menu_views(self)

	local parent = self.parent
	local input_service = self.input_service(self, true)
	local gui_layer = UILayer.default + 30
	self.menu_input_description = MenuInputDescriptionUI:new(ingame_ui_context, self.ui_top_renderer, input_service, 3, gui_layer, generic_input_actions.default)

	self.menu_input_description:set_input_description(nil)
	self.create_ui_elements(self, params)
	self._start_transition_animation(self, "on_enter", "on_enter")

	self._hero_preview_skin = nil
	local profile_index = self.profile_synchronizer:profile_by_peer(self.peer_id, self.local_player_id)
	local hero_name = self._hero_name
	local hero_attributes = Managers.backend:get_interface("hero_attributes")
	local career_index = hero_attributes.get(hero_attributes, hero_name, "career") or 1

	self._populate_career_page(self, hero_name, career_index)
end

StartMenuStateOverview.create_ui_elements = function (self, params)
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

	UIRenderer.clear_scenegraph_queue(self.ui_top_renderer)

	self.ui_animator = UIAnimator:new(self.ui_scenegraph, animation_definitions)
end

StartMenuStateOverview._get_skin_item_data = function (self, index, career_index)
	local profile_settings = SPProfiles[index]
	local skin_name = profile_settings.careers[career_index].base_skin

	return Cosmetics[skin_name]
end

StartMenuStateOverview._wanted_state = function (self)
	local new_state = self.parent:wanted_state()

	return new_state
end

StartMenuStateOverview.on_exit = function (self, params)
	if self.menu_input_description then
		self.menu_input_description:destroy()

		self.menu_input_description = nil
	end

	self.ui_animator = nil

	print("[HeroViewState] Exit Substate StartMenuStateOverview")
end

StartMenuStateOverview._update_transition_timer = function (self, dt)
	if not self._transition_timer then
		return
	end

	if self._transition_timer == 0 then
		self._transition_timer = nil
	else
		self._transition_timer = math.max(self._transition_timer - dt, 0)
	end
end

StartMenuStateOverview.update = function (self, dt, t)
	if DO_RELOAD then
		DO_RELOAD = false

		self.create_ui_elements(self)
	end

	for name, animation in pairs(self._ui_animations) do
		UIAnimation.update(animation, dt)

		if UIAnimation.completed(animation) then
			self._ui_animations[name] = nil
		end
	end

	local active_view = self._active_view

	if active_view then
		self._views[active_view]:update(dt, t)
	elseif not self._prepare_exit then
		self._handle_input(self, dt, t)
	end

	local wanted_state = self._wanted_state(self)

	if not self._transition_timer and (wanted_state or self._new_state) then
		if self.world_previewer:has_units_spawned() then
			self._prepare_exit = true
		elseif not self._prepare_exit then
			return wanted_state or self._new_state
		end
	end

	self.draw(self, dt)
end

StartMenuStateOverview.post_update = function (self, dt, t)
	self.ui_animator:update(dt)
	self._update_animations(self, dt)

	local transitioning = self.parent:transitioning()

	if not transitioning and not self._transition_timer then
		if self._prepare_exit then
			self._prepare_exit = false

			self.world_previewer:prepare_exit()
		elseif self._spawn_hero then
			self._spawn_hero = nil
			local hero_name = self._selected_hero_name or self._hero_name

			self._spawn_hero_unit(self, hero_name)
		end
	end
end

StartMenuStateOverview.draw = function (self, dt)
	local ui_renderer = self.ui_renderer
	local ui_top_renderer = self.ui_top_renderer
	local ui_scenegraph = self.ui_scenegraph
	local input_manager = self.input_manager
	local parent = self.parent
	local input_service = self.input_service(self, true)
	local render_settings = self.render_settings
	local snap_pixel_positions = render_settings.snap_pixel_positions

	UIRenderer.begin_pass(ui_top_renderer, ui_scenegraph, input_service, dt, nil, render_settings)

	for _, widget in ipairs(self._widgets) do
		UIRenderer.draw_widget(ui_top_renderer, widget)
	end

	if self._player_portrait_widget then
		UIRenderer.draw_widget(ui_top_renderer, self._player_portrait_widget)
	end

	UIRenderer.end_pass(ui_top_renderer)
end

StartMenuStateOverview._update_animations = function (self, dt)
	local animations = self._animations
	local ui_animator = self.ui_animator

	for animation_name, animation_id in pairs(animations) do
		if ui_animator.is_animation_completed(ui_animator, animation_id) then
			ui_animator.stop_animation(ui_animator, animation_id)

			animations[animation_name] = nil
		end
	end
end

StartMenuStateOverview._spawn_hero_unit = function (self, hero_name)
	local world_previewer = self.world_previewer
	local career_index = self.career_index
	local callback = callback(self, "cb_hero_unit_spawned", hero_name)

	world_previewer.request_spawn_hero_unit(world_previewer, hero_name, self.career_index, true, callback)
end

StartMenuStateOverview.cb_hero_unit_spawned = function (self, hero_name)
	local world_previewer = self.world_previewer
	local career_index = self.career_index
	local profile_index = FindProfileIndex(hero_name)
	local profile = SPProfiles[profile_index]
	local careers = profile.careers
	local career_settings = careers[career_index]
	local preview_idle_animation = career_settings.preview_idle_animation
	local preview_wield_slot = career_settings.preview_wield_slot
	local preview_items = career_settings.preview_items

	if preview_items then
		for _, item_name in ipairs(preview_items) do
			local item_template = ItemMasterList[item_name]
			local slot_type = item_template.slot_type
			local slot_names = InventorySettings.slot_names_by_type[slot_type]
			local slot_name = slot_names[1]
			local slot = InventorySettings.slots_by_name[slot_name]

			world_previewer.equip_item(world_previewer, item_name, slot)
		end

		if preview_wield_slot then
			world_previewer.wield_weapon_slot(world_previewer, preview_wield_slot)
		end
	end

	if preview_idle_animation then
		self.world_previewer:play_character_animation(preview_idle_animation)
	end
end

StartMenuStateOverview._populate_career_page = function (self, hero_name, career_index)
	local profile_index = FindProfileIndex(hero_name)
	local profile_settings = SPProfiles[profile_index]
	local character_name = profile_settings.character_name
	local careers = profile_settings.careers
	local career_settings = careers[career_index]
	local name = career_settings.name
	local portrait_image = career_settings.portrait_image
	local display_name = career_settings.display_name
	local description = career_settings.description
	local icon = career_settings.icon
	local passive_ability_data = career_settings.passive_ability
	local activated_ability_data = career_settings.activated_ability
	local passive_display_name = passive_ability_data.display_name
	local passive_description = passive_ability_data.description
	local passive_icon = passive_ability_data.icon
	local activated_display_name = activated_ability_data.display_name
	local activated_description = activated_ability_data.description
	local activated_icon = activated_ability_data.icon
	local widgets_by_name = self._widgets_by_name
	widgets_by_name.info_career_name.content.text = Localize(display_name)
	self._spawn_hero = true
	self.career_index = career_index
	local hero_attributes = Managers.backend:get_interface("hero_attributes")
	local exp = hero_attributes.get(hero_attributes, hero_name, "experience") or 0
	local level = ExperienceSettings.get_level(exp)

	self._set_hero_info(self, Localize(character_name), level)
	self._create_player_portrait(self, portrait_image, level)
end

StartMenuStateOverview._set_hero_info = function (self, name, level)
	local widgets_by_name = self._widgets_by_name
	widgets_by_name.info_hero_name.content.text = name
	widgets_by_name.info_hero_level.content.text = Localize("level") .. ": " .. level
end

StartMenuStateOverview._create_player_portrait = function (self, portrait_image, level)
	local level_text = (level and tostring(level)) or "-"
	local frame_settings_name = "default"
	local definition = UIWidgets.create_portrait_frame("portrait_root", frame_settings_name, level_text, 1, nil, portrait_image)
	local widget = UIWidget.init(definition)
	self._player_portrait_widget = widget
end

StartMenuStateOverview._set_select_button_enabled = function (self, enabled)
	self._widgets_by_name.select_button.content.button_hotspot.disable_button = not enabled
end

StartMenuStateOverview._handle_input = function (self, dt, t)
	local input_service = self.input_service(self, true)
	local widgets_by_name = self._widgets_by_name
	local play_button = widgets_by_name.play_button
	local hero_button = widgets_by_name.hero_button
	local quit_button = widgets_by_name.quit_button
	local credits_button = widgets_by_name.credits_button
	local options_button = widgets_by_name.options_button
	local tutorial_button = widgets_by_name.tutorial_button

	UIWidgetUtils.animate_default_button(play_button, dt)
	UIWidgetUtils.animate_default_button(hero_button, dt)
	UIWidgetUtils.animate_default_button(quit_button, dt)
	UIWidgetUtils.animate_default_button(credits_button, dt)
	UIWidgetUtils.animate_default_button(options_button, dt)
	UIWidgetUtils.animate_default_button(tutorial_button, dt)

	if self._is_button_hover_enter(self, play_button) or self._is_button_hover_enter(self, hero_button) or self._is_button_hover_enter(self, quit_button) or self._is_button_hover_enter(self, credits_button) or self._is_button_hover_enter(self, options_button) or self._is_button_hover_enter(self, tutorial_button) then
		self._play_sound(self, "play_gui_start_menu_button_hover")
	end

	if self._is_button_pressed(self, hero_button) then
		self._play_sound(self, "play_gui_start_menu_button_click")
		self.parent:requested_screen_change_by_name("character")
	elseif self._is_button_pressed(self, play_button) then
		self._play_sound(self, "play_gui_start_menu_button_click")
		self.parent:close_menu()
	elseif self._is_button_pressed(self, options_button) then
		self._play_sound(self, "play_gui_start_menu_button_click")
		menu_functions[1](self)
		self._play_sound(self, "play_gui_start_menu_button_click")
	elseif self._is_button_pressed(self, tutorial_button) then
		menu_functions[2](self)
		self._play_sound(self, "play_gui_start_menu_button_click")
	elseif self._is_button_pressed(self, credits_button) then
		menu_functions[3](self)
	elseif self._is_button_pressed(self, quit_button) then
		self._play_sound(self, "play_gui_start_menu_button_click")

		Boot.quit_game = true
	end

	if Development.parameter("tobii_button") then
		self._handle_tobii_button(self, dt)
	end
end

StartMenuStateOverview._handle_tobii_button = function (self, dt)
	local widgets_by_name = self._widgets_by_name
	local tobii_button = widgets_by_name.tobii_button

	UIWidgetUtils.animate_default_button(tobii_button, dt)

	if self._is_button_pressed(self, tobii_button) then
		self._play_sound(self, "play_gui_start_menu_button_click")

		local tobii_contest_url = "https://vermintide2beta.com/?utm_medium=referral&utm_campaign=vermintide2beta&utm_source=ingame#challenge"

		Application.open_url_in_browser(tobii_contest_url)
	end
end

StartMenuStateOverview.game_popup_active = function (self)
	return self._show_play_popup
end

StartMenuStateOverview._is_button_pressed = function (self, widget)
	local content = widget.content
	local hotspot = content.button_hotspot

	if hotspot.on_release then
		hotspot.on_release = false

		return true
	end
end

StartMenuStateOverview._is_button_hover_enter = function (self, widget)
	local content = widget.content
	local hotspot = content.button_hotspot

	return hotspot.on_hover_enter
end

StartMenuStateOverview._is_button_hover_exit = function (self, widget)
	local content = widget.content
	local hotspot = content.button_hotspot

	return hotspot.on_hover_exit
end

StartMenuStateOverview._play_sound = function (self, event)
	self.parent:play_sound(event)
end

StartMenuStateOverview.get_camera_position = function (self)
	local world, viewport = self.parent:get_background_world()
	local camera = ScriptViewport.camera(viewport)

	return ScriptCamera.position(camera)
end

StartMenuStateOverview.get_camera_rotation = function (self)
	local world, viewport = self.parent:get_background_world()
	local camera = ScriptViewport.camera(viewport)

	return ScriptCamera.rotation(camera)
end

StartMenuStateOverview.trigger_unit_flow_event = function (self, unit, event_name)
	if unit and Unit.alive(unit) then
		Unit.flow_event(unit, event_name)
	end
end

StartMenuStateOverview._start_transition_animation = function (self, key, animation_name)
	local params = {
		wwise_world = self.wwise_world,
		render_settings = self.render_settings
	}
	local widgets = {}
	local anim_id = self.ui_animator:start_animation(animation_name, widgets, scenegraph_definition, params)
	self._animations[key] = anim_id
end

StartMenuStateOverview._on_option_button_hover = function (self, widget, style_id)
	local ui_animations = self._ui_animations
	local animation_name = "option_button_" .. style_id
	local widget_style = widget.style
	local pass_style = widget_style[style_id]
	local current_color_value = pass_style.color[2]
	local target_color_value = 255
	local total_time = UISettings.scoreboard.topic_hover_duration
	local animation_duration = (1 - current_color_value / target_color_value) * total_time

	for i = 2, 4, 1 do
		if 0 < animation_duration then
			ui_animations[animation_name .. "_hover_" .. i] = self._animate_element_by_time(self, pass_style.color, i, current_color_value, target_color_value, animation_duration)
		else
			pass_style.color[i] = target_color_value
		end
	end
end

StartMenuStateOverview._on_option_button_dehover = function (self, widget, style_id)
	local ui_animations = self._ui_animations
	local animation_name = "option_button_" .. style_id
	local widget_style = widget.style
	local pass_style = widget_style[style_id]
	local current_color_value = pass_style.color[1]
	local target_color_value = 100
	local total_time = UISettings.scoreboard.topic_hover_duration
	local animation_duration = current_color_value / 255 * total_time

	for i = 2, 4, 1 do
		if 0 < animation_duration then
			ui_animations[animation_name .. "_hover_" .. i] = self._animate_element_by_time(self, pass_style.color, i, current_color_value, target_color_value, animation_duration)
		else
			pass_style.color[1] = target_color_value
		end
	end
end

StartMenuStateOverview.play_sound = function (self, event)
	return
end

StartMenuStateOverview._animate_element_by_time = function (self, target, target_index, from, to, time)
	local new_animation = UIAnimation.init(UIAnimation.function_by_time, target, target_index, from, to, time, math.ease_out_quad)

	return new_animation
end

StartMenuStateOverview._animate_element_by_catmullrom = function (self, target, target_index, target_value, p0, p1, p2, p3, time)
	local new_animation = UIAnimation.init(UIAnimation.catmullrom, target, target_index, target_value, p0, p1, p2, p3, time)

	return new_animation
end

StartMenuStateOverview._init_menu_views = function (self)
	local ingame_ui_context = self.ingame_ui_context
	self._views = {
		credits_view = CreditsView:new(ingame_ui_context),
		options_view = OptionsView:new(ingame_ui_context)
	}

	for name, view in pairs(self._views) do
		view.exit = function ()
			self:exit_current_view()
		end
	end
end

StartMenuStateOverview._activate_view = function (self, new_view)
	self._active_view = new_view
	local views = self._views

	assert(views[new_view])

	if new_view and views[new_view] and views[new_view].on_enter then
		views[new_view]:on_enter()
	end
end

StartMenuStateOverview.exit_current_view = function (self)
	local active_view = self._active_view
	local views = self._views

	assert(active_view)

	if views[active_view] and views[active_view].on_exit then
		views[active_view]:on_exit()
	end

	self._active_view = nil
	local input_service = self.input_service(self, true)
	local input_service_name = input_service.name
	local input_manager = Managers.input

	input_manager.block_device_except_service(input_manager, input_service_name, "keyboard")
	input_manager.block_device_except_service(input_manager, input_service_name, "mouse")
	input_manager.block_device_except_service(input_manager, input_service_name, "gamepad")
end

StartMenuStateOverview.input_service = function (self, ignore_view_input)
	if not ignore_view_input then
		local active_view = self._active_view
		local views = self._views
		local view = views[active_view]

		if view then
			return view.input_service(view)
		end
	end

	return self.parent:input_service(true)
end

return

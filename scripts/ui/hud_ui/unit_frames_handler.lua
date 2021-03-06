require("scripts/settings/ui_player_portrait_frame_settings")
require("scripts/ui/hud_ui/unit_frame_ui")

local allowed_consumable_slots = {
	slot_healthkit = true,
	slot_grenade = true,
	slot_potion = true
}
local allowed_weapon_slots = {
	slot_ranged = true,
	slot_melee = true
}
local MIN_HEALTH_DIVIDERS = 0
local MAX_HEALTH_DIVIDERS = 10
local NUM_TEAM_MEMBERS = 3
UnitFramesHandler = class(UnitFramesHandler)
local DO_RELOAD = true
UnitFramesHandler.init = function (self, ingame_ui_context)
	self.ingame_ui_context = ingame_ui_context
	self.ingame_ui = ingame_ui_context.ingame_ui
	self.input_manager = ingame_ui_context.input_manager
	self.peer_id = ingame_ui_context.peer_id
	self.profile_synchronizer = ingame_ui_context.profile_synchronizer
	self.player_manager = ingame_ui_context.player_manager
	self.lobby = ingame_ui_context.network_lobby
	self.my_player = ingame_ui_context.player
	self.cleanui = ingame_ui_context.cleanui
	local network_manager = Managers.state.network
	local network_transmit = network_manager.network_transmit
	local server_peer_id = network_transmit.server_peer_id
	self.host_peer_id = server_peer_id or network_transmit.peer_id
	self.platform = PLATFORM
	self._unit_frames = {}
	self.unit_frame_index_by_ui_id = {}

	self._create_player_unit_frame(self)
	self._create_team_members_unit_frames(self)
	rawset(_G, "unit_frames_handler", self)

	self._current_frame_index = 1

	return 
end
UnitFramesHandler.get_unit_widget = function (self, index)
	return self._unit_frames[index].widget
end

local function get_portrait_name_by_profile_index(profile_index, career_index)
	local scale = RESOLUTION_LOOKUP.scale
	local profile_data = SPProfiles[profile_index]
	local careers = profile_data.careers
	local career_settings = careers[career_index]
	local portrait_image = career_settings.portrait_image
	local display_name = profile_data.display_name

	return portrait_image
end

UnitFramesHandler._create_player_unit_frame = function (self)
	local unit_frame = self._create_unit_frame_by_type(self, "player")
	local player = self.my_player
	local player_ui_id = player.ui_id(player)
	local player_data = {
		player_ui_id = player_ui_id,
		player = player,
		own_player = true,
		peer_id = player.network_id(player),
		local_player_id = player.local_player_id(player)
	}
	unit_frame.player_data = player_data
	unit_frame.sync = true
	self._unit_frames[1] = unit_frame
	self.unit_frame_index_by_ui_id[player_ui_id] = 1

	return 
end
UnitFramesHandler._create_team_members_unit_frames = function (self)
	local player_manager = self.player_manager
	local players = self.player_manager:human_and_bot_players()
	local unit_frames = self._unit_frames

	for i = 1, NUM_TEAM_MEMBERS, 1 do
		local unit_frame = self._create_unit_frame_by_type(self, "team", i)
		unit_frames[#unit_frames + 1] = unit_frame
	end

	self._align_team_member_frames(self)

	return 
end
UnitFramesHandler._create_unit_frame_by_type = function (self, frame_type, frame_index)
	local ingame_ui_context = self.ingame_ui_context
	local unit_frame = {}
	local state_data = {}
	local player_data = {}
	local definitions = nil

	if frame_type == "team" then
		definitions = local_require("scripts/ui/hud_ui/team_member_unit_frame_ui_definitions")
	elseif frame_type == "player" then
		local gamepad_active = self.input_manager:is_device_active("gamepad")
		definitions = local_require("scripts/ui/hud_ui/player_unit_frame_ui_definitions")
	else
		definitions = local_require("scripts/ui/hud_ui/team_member_unit_frame_ui_definitions")
	end

	unit_frame.data = state_data
	unit_frame.player_data = player_data
	unit_frame.definitions = definitions
	unit_frame.features_list = definitions.features_list
	unit_frame.widget_name_by_feature = definitions.widget_name_by_feature
	unit_frame.widget = UnitFrameUI:new(ingame_ui_context, definitions, state_data, frame_index, player_data)

	return unit_frame
end
UnitFramesHandler._get_unused_unit_frame = function (self)
	for index, unit_frame in ipairs(self._unit_frames) do
		local player_data = unit_frame.player_data

		if not player_data.peer_id and not player_data.connecting_peer_id then
			return unit_frame, index
		end
	end

	return 
end
UnitFramesHandler._get_unit_frame_by_connecting_peer_id = function (self, peer_id)
	for index, unit_frame in ipairs(self._unit_frames) do
		if unit_frame.player_data.connecting_peer_id == peer_id then
			return unit_frame, index
		end
	end

	return 
end
UnitFramesHandler._reset_unit_frame = function (self, unit_frame)
	local widget = unit_frame.widget

	widget.reset(widget)
	table.clear(unit_frame.player_data)
	table.clear(unit_frame.data)

	unit_frame.sync = false

	return 
end
local temp_active_ui_ids = {}
local temp_active_peer_ids = {}
local temp_connecting_peer_ids = {}
UnitFramesHandler._handle_unit_frame_assigning = function (self)
	local player_manager = self.player_manager
	local players = self.player_manager:human_and_bot_players()
	local unit_frames = self._unit_frames
	local unit_frame_index_by_ui_id = self.unit_frame_index_by_ui_id
	local unit_frames_used_by_players = 0
	local my_player = self.my_player

	table.clear(temp_active_ui_ids)
	table.clear(temp_active_peer_ids)

	local frames_changed = false

	for index, player in pairs(players) do
		local player_ui_id = player.ui_id(player)
		local player_peer_id = player.network_id(player)
		temp_active_ui_ids[player_ui_id] = true
		temp_active_peer_ids[player_peer_id] = true
		local own_player = player == my_player

		if not own_player then
			if not unit_frame_index_by_ui_id[player_ui_id] then
				local add_unit_frame = true
				local game_mode_key = Managers.state.game_mode:game_mode_key()

				if game_mode_key == "tutorial" then
					local play_go_tutorial_system = Managers.state.entity:system("play_go_tutorial_system")
					add_unit_frame = play_go_tutorial_system.bot_portrait_enabled(play_go_tutorial_system, player)
				end

				if add_unit_frame then
					local avaiable_unit_frame, unit_frame_index = self._get_unit_frame_by_connecting_peer_id(self, player_peer_id)

					if not avaiable_unit_frame then
						avaiable_unit_frame, unit_frame_index = self._get_unused_unit_frame(self)
					end

					if avaiable_unit_frame then
						unit_frame_index_by_ui_id[player_ui_id] = unit_frame_index

						table.clear(avaiable_unit_frame.data)

						local player_data = {
							player_ui_id = player_ui_id,
							player = player,
							own_player = own_player,
							peer_id = player_peer_id,
							local_player_id = player.local_player_id(player)
						}
						avaiable_unit_frame.player_data = player_data
						avaiable_unit_frame.sync = true
						frames_changed = true

						if player.is_player_controlled(player) then
							unit_frames_used_by_players = unit_frames_used_by_players + 1
						end
					end
				end
			elseif player.is_player_controlled(player) then
				unit_frames_used_by_players = unit_frames_used_by_players + 1
			end
		end
	end

	if self._handle_connecting_peers(self, temp_active_peer_ids, unit_frames_used_by_players) then
		frames_changed = true
	end

	if self._cleanup_unused_unit_frames(self, temp_active_ui_ids, temp_connecting_peer_ids) then
		frames_changed = true
	end

	if frames_changed then
		self._align_team_member_frames(self)
	end

	return 
end
UnitFramesHandler._handle_connecting_peers = function (self, active_peer_ids, num_unit_frames_used)
	local added_connection = false

	table.clear(temp_connecting_peer_ids)

	if num_unit_frames_used < 3 then
		local members = self.lobby:members()

		if members then
			local lobby_members = members.get_members(members)

			for idx, peer_id in ipairs(lobby_members) do
				if not active_peer_ids[peer_id] then
					local unit_frame = self._get_unit_frame_by_connecting_peer_id(self, peer_id)

					if not unit_frame then
						local avaiable_unit_frame, unit_frame_index = self._get_unused_unit_frame(self)

						if avaiable_unit_frame then
							self._reset_unit_frame(self, avaiable_unit_frame)

							avaiable_unit_frame.player_data = {
								connecting_peer_id = peer_id
							}
							added_connection = true
						end
					end

					temp_connecting_peer_ids[peer_id] = true
					num_unit_frames_used = num_unit_frames_used + 1

					if num_unit_frames_used == 3 then
						break
					end
				end
			end
		end
	end

	return added_connection
end
UnitFramesHandler._cleanup_unused_unit_frames = function (self, active_ui_ids, connecting_peer_ids)
	local frames_cleared = false

	for index, unit_frame in ipairs(self._unit_frames) do
		local player_data = unit_frame.player_data
		local player_ui_id = player_data.player_ui_id
		local player_peer_id = player_data.peer_id
		local connecting_peer_id = player_data.connecting_peer_id
		local clear_unit_frame = (connecting_peer_id and not connecting_peer_ids[connecting_peer_id]) or (player_ui_id and not active_ui_ids[player_ui_id])

		if clear_unit_frame then
			self._reset_unit_frame(self, unit_frame)

			frames_cleared = true

			if player_ui_id then
				self.unit_frame_index_by_ui_id[player_ui_id] = nil
			end
		end
	end

	return frames_cleared
end
UnitFramesHandler._align_team_member_frames = function (self)
	local start_offset_y = -100
	local start_offset_x = 80
	local spacing = 220
	local is_visible = self._is_visible
	local count = 0

	for index, unit_frame in ipairs(self._unit_frames) do
		if 1 < index then
			local widget = unit_frame.widget
			local player_data = unit_frame.player_data
			local peer_id = player_data.peer_id
			local connecting_peer_id = player_data.connecting_peer_id

			if (peer_id or connecting_peer_id) and is_visible then
				local position_x = start_offset_x
				local position_y = start_offset_y - count * spacing

				widget.set_position(widget, position_x, position_y)

				count = count + 1

				widget.set_visible(widget, true)
			else
				widget.set_visible(widget, false)
			end
		end
	end

	return 
end

local function get_ammunition_count(left_hand_wielded_unit, right_hand_wielded_unit, item_template)
	local ammo_extension = nil

	if not item_template.ammo_data then
		return 
	end

	local ammo_unit_hand = item_template.ammo_data.ammo_hand

	if ammo_unit_hand == "right" then
		ammo_extension = ScriptUnit.extension(right_hand_wielded_unit, "ammo_system")
	elseif ammo_unit_hand == "left" then
		ammo_extension = ScriptUnit.extension(left_hand_wielded_unit, "ammo_system")
	else
		return 
	end

	local ammo_count = ammo_extension.ammo_count(ammo_extension)
	local remaining_ammo = ammo_extension.remaining_ammo(ammo_extension)
	local single_clip = ammo_extension.using_single_clip(ammo_extension)
	local max_ammo = ammo_extension.max_ammo

	return ammo_count, remaining_ammo, max_ammo, single_clip
end

local function get_overcharge_amount(unit)
	local overcharge_extension = ScriptUnit.extension(unit, "overcharge_system")
	local overcharge_fraction = overcharge_extension.overcharge_fraction(overcharge_extension)
	local threshold_fraction = overcharge_extension.threshold_fraction(overcharge_extension)
	local anim_blend_overcharge = overcharge_extension.get_anim_blend_overcharge(overcharge_extension)

	return true, overcharge_fraction, threshold_fraction, anim_blend_overcharge
end

UnitFramesHandler._set_player_extensions = function (self, player_data, player_unit)
	local extensions = {
		career = ScriptUnit.extension(player_unit, "career_system"),
		health = ScriptUnit.extension(player_unit, "health_system"),
		status = ScriptUnit.extension(player_unit, "status_system"),
		inventory = ScriptUnit.extension(player_unit, "inventory_system"),
		dialogue = ScriptUnit.extension(player_unit, "dialogue_system"),
		buff = ScriptUnit.extension(player_unit, "buff_system")
	}
	player_data.extensions = extensions
	player_data.player_unit = player_unit

	return 
end
local empty_features_list = {}
UnitFramesHandler._sync_player_stats = function (self, unit_frame)
	if not unit_frame.sync then
		return 
	end

	local features_list = unit_frame.features_list or empty_features_list
	local gamepad_active = Managers.input:is_device_active("gamepad")
	local gamepad_was_active = self.gamepad_was_active
	local player_data = unit_frame.player_data
	local player = player_data.player

	if not player then
		return 
	end

	local peer_id = player_data.peer_id
	local local_player_id = player_data.local_player_id
	local data = unit_frame.data
	local widget = unit_frame.widget
	local profile_synchronizer = self.profile_synchronizer

	if not player_data.extensions then
		local player_unit = player.player_unit

		if player_unit then
			self._set_player_extensions(self, player_data, player_unit)
		end
	end

	local profile_index = profile_synchronizer.profile_by_peer(profile_synchronizer, peer_id, local_player_id)

	if not profile_index then
		return 
	end

	local health_percent, shield_percent, total_health_percent, active_percentage, is_dead, is_knocked_down, needs_help, is_wounded, is_ready_for_assisted_respawn = nil
	local is_talking = false
	local player_unit = player_data.player_unit

	if (not player_unit or not Unit.alive(player_unit)) and player_data.extensions then
		player_data.extensions = nil
	end

	local go_id = Managers.state.unit_storage:go_id(player_unit)
	local network_manager = Managers.state.network
	local game = network_manager.game(network_manager)
	local ability_cooldown_percentage = 0
	local extensions = player_data.extensions
	local equipment, career_index = nil

	if extensions then
		local career_extension = extensions.career
		local buff_extension = extensions.buff
		local status_extension = extensions.status
		local health_extension = extensions.health
		local inventory_extension = extensions.inventory
		local dialogue_extension = extensions.dialogue

		if status_extension.is_dead(status_extension) then
			total_health_percent = 0
		else
			total_health_percent = health_extension.current_health_percent(health_extension)
		end

		if status_extension.is_dead(status_extension) then
			health_percent = 0
		else
			health_percent = health_extension.current_permanent_health_percent(health_extension)
		end

		if status_extension.is_dead(status_extension) then
			shield_percent = 0
		else
			shield_percent = health_extension.current_temporary_health_percent(health_extension)
		end

		is_wounded = status_extension.is_wounded(status_extension)
		is_knocked_down = (status_extension.is_knocked_down(status_extension) or status_extension.get_is_ledge_hanging(status_extension)) and 0 < total_health_percent
		is_ready_for_assisted_respawn = status_extension.is_ready_for_assisted_respawn(status_extension)
		needs_help = status_extension.is_grabbed_by_pack_master(status_extension) or status_extension.is_hanging_from_hook(status_extension) or status_extension.is_pounced_down(status_extension)
		local num_grimoires = buff_extension.num_buff_perk(buff_extension, "skaven_grimoire")
		local multiplier = buff_extension.apply_buffs_to_value(buff_extension, PlayerUnitDamageSettings.GRIMOIRE_HEALTH_DEBUFF, StatBuffIndex.CURSE_PROTECTION)
		local num_twitch_grimoires = buff_extension.num_buff_perk(buff_extension, "twitch_grimoire")
		local twitch_multiplier = PlayerUnitDamageSettings.GRIMOIRE_HEALTH_DEBUFF
		active_percentage = 1 + num_grimoires * multiplier + num_twitch_grimoires * twitch_multiplier
		equipment = inventory_extension.equipment(inventory_extension)
		career_index = career_extension.career_index(career_extension)

		if game and go_id then
			ability_cooldown_percentage = GameSession.game_object_field(game, go_id, "ability_percentage") or 0
		end
	else
		shield_percent = 0
		health_percent = 0
		total_health_percent = 0
		active_percentage = 1
		is_knocked_down = false
	end

	local is_dead = total_health_percent <= 0
	local is_player_controlled = player.is_player_controlled(player)
	local display_name = UIRenderer.crop_text(player.name(player), 17)
	local level_text = (is_player_controlled and (ExperienceSettings.get_player_level(player) or "")) or "BOT"
	local portrait_texture = (career_index and get_portrait_name_by_profile_index(profile_index, career_index)) or "unit_frame_portrait_default"
	local frame_texture = Managers.state.entity:system("cosmetic_system"):get_equipped_frame(player_unit)
	local is_player_server = self.host_peer_id == peer_id
	local is_host = is_player_controlled and is_player_server
	local show_icon = false
	local connecting = false

	if is_knocked_down then
		show_icon = false
	elseif is_dead or is_ready_for_assisted_respawn or needs_help then
		show_icon = true
	end

	local dirty = false
	local update_portrait_status = false
	local update_health_bar_status = false

	if data.connecting ~= connecting then
		data.connecting = connecting

		widget.set_connecting_status(widget, connecting)
	end

	if data.is_knocked_down ~= is_knocked_down then
		data.is_knocked_down = is_knocked_down
		update_portrait_status = true
		update_health_bar_status = true
	end

	if data.is_dead ~= is_dead then
		data.is_dead = is_dead
		update_health_bar_status = true
		update_portrait_status = true
	end

	if data.is_wounded ~= is_wounded then
		data.is_wounded = is_wounded
		update_health_bar_status = true
	end

	if data.needs_help ~= needs_help then
		data.needs_help = needs_help
		update_portrait_status = true
	end

	if data.is_talking ~= is_talking then
		data.is_talking = is_talking

		widget.set_talking(widget, is_talking)

		dirty = true
	end

	if data.show_icon ~= show_icon then
		data.show_icon = show_icon

		widget.set_icon_visibility(widget, show_icon)

		dirty = true
	end

	if data.assisted_respawn ~= is_ready_for_assisted_respawn then
		data.assisted_respawn = is_ready_for_assisted_respawn
		update_portrait_status = true
		dirty = true
	end

	if data.show_health_bar ~= not is_ready_for_assisted_respawn then
		data.show_health_bar = not is_ready_for_assisted_respawn
		update_health_bar_status = true
		dirty = true
	end

	if data.portrait_texture ~= portrait_texture then
		data.portrait_texture = portrait_texture

		widget.set_portrait(widget, portrait_texture)

		dirty = true
	end

	if data.frame_texture ~= frame_texture or data.level_text ~= level_text then
		data.frame_texture = frame_texture
		data.level_text = level_text

		widget.set_portrait_frame(widget, frame_texture, level_text)

		dirty = true
	end

	if data.display_name ~= display_name then
		data.display_name = display_name

		widget.set_player_name(widget, display_name)

		dirty = true
	end

	if data.is_host ~= is_host then
		data.is_host = is_host

		widget.set_host_status(widget, is_host)

		dirty = true
	end

	if update_portrait_status then
		widget.set_portrait_status(widget, is_knocked_down, needs_help, is_dead, is_ready_for_assisted_respawn)

		dirty = true
	end

	if data.total_health_percent ~= total_health_percent or data.active_percentage ~= active_percentage then
		data.total_health_percent = total_health_percent
		local low_health = (not is_dead and total_health_percent < UISettings.unit_frames.low_health_threshold) or nil

		widget.set_total_health_percentage(widget, total_health_percent, active_percentage)

		dirty = true
	end

	if data.health_percent ~= health_percent or data.active_percentage ~= active_percentage then
		data.health_percent = health_percent
		local low_health = (not is_dead and not is_knocked_down and health_percent < UISettings.unit_frames.low_health_threshold) or nil

		widget.set_health_percentage(widget, health_percent, active_percentage)

		dirty = true
	end

	if data.active_percentage ~= active_percentage then
		data.active_percentage = active_percentage

		widget.set_active_percentage(widget, active_percentage)

		dirty = true
	end

	local update_ability = features_list.ability

	if update_ability and data.ability_cooldown_percentage ~= ability_cooldown_percentage then
		data.ability_cooldown_percentage = ability_cooldown_percentage

		widget.set_ability_percentage(widget, 1 - ability_cooldown_percentage)

		dirty = true
	end

	local update_equipment = features_list.equipment
	local update_weapons = features_list.weapons
	local update_ammo = features_list.ammo

	if equipment and (update_equipment or update_weapons or update_ammo) then
		local wielded = equipment.wielded

		if not data.inventory_slots then
			data.inventory_slots = {}
		end

		local inventory_slots = InventorySettings.slots
		local inventory_slots_data = data.inventory_slots

		for _, slot in ipairs(inventory_slots) do
			local slot_name = slot.name
			local slot_data = equipment.slots[slot_name]
			local item_data = slot_data and slot_data.item_data

			if not inventory_slots_data[slot_name] then
				inventory_slots_data[slot_name] = {}
			end

			local stored_slot_data = inventory_slots_data[slot_name]

			if update_ammo and slot_name == "slot_ranged" and item_data then
				local item_template = BackendUtils.get_item_template(item_data)

				if item_template.ammo_data then
					local ammo_fraction = 1

					if game and go_id then
						ammo_fraction = GameSession.game_object_field(game, go_id, "ammo_percentage")
					end

					if stored_slot_data.ammo_fraction ~= ammo_fraction then
						widget.set_ammo_percentage(widget, ammo_fraction)

						stored_slot_data.ammo_fraction = ammo_fraction
					end
				end
			end

			if update_equipment and allowed_consumable_slots[slot_name] then
				local slot_visible = (slot_data and true) or false
				local item_name = item_data and item_data.name
				local is_wielded = (item_name and wielded == item_data) or false
				local slot_dirty = false

				if stored_slot_data.visible ~= slot_visible or stored_slot_data.item_name ~= item_name then
					stored_slot_data.visible = slot_visible
					stored_slot_data.item_name = item_name

					widget.set_inventory_slot_data(widget, slot_name, slot_visible, item_data)

					dirty = true
					slot_dirty = true
				end
			end

			if update_weapons and allowed_weapon_slots[slot_name] and slot_data then
				local item_name = item_data.name
				local hud_icon = item_data.hud_icon
				local is_wielded = wielded == item_data

				if stored_slot_data.is_wielded ~= is_wielded or stored_slot_data.item_name ~= item_name then
					widget.set_equipped_weapon_info(widget, slot_name, is_wielded, item_name, hud_icon)

					if stored_slot_data.item_name ~= item_name then
						stored_slot_data.no_ammo = nil
					end

					stored_slot_data.is_wielded = is_wielded
					stored_slot_data.item_name = item_name
					stored_slot_data.hud_icon = hud_icon
					dirty = true
				end

				local item_template = BackendUtils.get_item_template(item_data)

				if item_template.ammo_data then
					local ammo_count, remaining_ammo, _, using_single_clip = get_ammunition_count(slot_data.left_unit_1p, slot_data.right_unit_1p, item_template)

					if stored_slot_data.ammo_count ~= ammo_count or stored_slot_data.remaining_ammo ~= remaining_ammo or stored_slot_data.no_ammo then
						stored_slot_data.ammo_count = ammo_count
						stored_slot_data.remaining_ammo = remaining_ammo
						stored_slot_data.no_ammo = nil

						widget.set_ammo_for_slot(widget, slot_name, ammo_count, remaining_ammo, using_single_clip)

						dirty = true
					end

					if slot_name == "slot_ranged" and stored_slot_data.overcharge_fraction then
						widget.set_overcharge_percentage(widget, false, nil)

						stored_slot_data.overcharge_fraction = nil
					end
				else
					if not stored_slot_data.no_ammo then
						stored_slot_data.no_ammo = true
						dirty = true

						widget.set_ammo_for_slot(widget, slot_name, nil, nil)

						stored_slot_data.overcharge_fraction = nil
						stored_slot_data.ammo_count = nil
						stored_slot_data.remaining_ammo = nil
					end

					if slot_name == "slot_ranged" then
						local has_overcharge, overcharge_fraction, threshold_fraction = get_overcharge_amount(player_unit)

						if stored_slot_data.overcharge_fraction ~= overcharge_fraction then
							widget.set_overcharge_percentage(widget, has_overcharge, overcharge_fraction)

							stored_slot_data.overcharge_fraction = overcharge_fraction
						end
					end
				end
			end
		end
	end

	if update_health_bar_status then
		local hide_health_bar = is_ready_for_assisted_respawn or is_dead

		widget.set_health_bar_status(widget, not hide_health_bar, is_knocked_down, is_wounded)

		dirty = true
	end

	if dirty then
		widget.set_dirty(widget)

		if self.cleanui then
			self.cleanui.dirty = true
		end
	end

	self.gamepad_was_active = gamepad_active

	return 
end
UnitFramesHandler.destroy = function (self)
	self.ui_animator = nil

	self.set_visible(self, false)
	rawset(_G, "unit_frames_handler", nil)

	return 
end
UnitFramesHandler.set_visible = function (self, visible, ignore_own_player)
	self._is_visible = visible

	for index, unit_frame in ipairs(self._unit_frames) do
		local player_data = unit_frame.player_data

		if player_data.peer_id then
			if ignore_own_player and index == 1 then
				unit_frame.widget:set_visible(false)
			else
				unit_frame.widget:set_visible(visible)
			end
		elseif not visible then
			unit_frame.widget:set_visible(false)
		end
	end

	return 
end
UnitFramesHandler.on_gamepad_activated = function (self)
	local my_unit_frame = self._unit_frames[1]

	if not my_unit_frame.gamepad_version then
		my_unit_frame.widget:destroy()

		local new_unit_frame = self._create_unit_frame_by_type(self, "player")
		new_unit_frame.player_data = my_unit_frame.player_data
		new_unit_frame.sync = true
		self._unit_frames[1] = new_unit_frame
	end

	return 
end
UnitFramesHandler.on_gamepad_deactivated = function (self)
	local my_unit_frame = self._unit_frames[1]

	if my_unit_frame.gamepad_version then
		my_unit_frame.widget:destroy()

		local new_unit_frame = self._create_unit_frame_by_type(self, "player")
		new_unit_frame.player_data = my_unit_frame.player_data
		new_unit_frame.sync = true
		self._unit_frames[1] = new_unit_frame
	end

	return 
end
UnitFramesHandler.update = function (self, dt, t, ignore_own_player)
	if not self._is_visible then
		return 
	end

	local gamepad_active = self.input_manager:is_device_active("gamepad")

	self._handle_unit_frame_assigning(self)
	self._sync_player_stats(self, self._unit_frames[self._current_frame_index])

	self._current_frame_index = 1 + self._current_frame_index % #self._unit_frames

	for index, unit_frame in ipairs(self._unit_frames) do
		if index ~= 1 or not ignore_own_player then
			unit_frame.widget:update(dt, t)
		end
	end

	self._handle_resolution_modified(self)
	self._draw(self, dt)

	if DO_RELOAD then
		DO_RELOAD = false

		for index, unit_frame in ipairs(self._unit_frames) do
			table.clear(unit_frame.data)
		end
	end

	return 
end
UnitFramesHandler._handle_resolution_modified = function (self)
	if not self._is_visible then
		return 
	end

	if RESOLUTION_LOOKUP.modified then
		for index, unit_frame in ipairs(self._unit_frames) do
			unit_frame.widget:on_resolution_modified()
		end
	end

	return 
end
UnitFramesHandler._draw = function (self, dt)
	if not self._is_visible then
		return 
	end

	for index, unit_frame in ipairs(self._unit_frames) do
		unit_frame.widget:draw(dt)
	end

	return 
end

return 

require("scripts/entity_system/systems/play_go_tutorial/play_go_pause_templates")

local extensions = {
	"PlayGoTutorialExtension"
}
PlayGoTutorialSystem = class(PlayGoTutorialSystem, ExtensionSystemBase)
PlayGoTutorialSystem.init = function (self, entity_system_creation_context, system_name)
	PlayGoTutorialSystem.super.init(self, entity_system_creation_context, system_name, extensions)

	self._profile_synchronizer = entity_system_creation_context.profile_synchronizer
	self._tutorial_started = false
	self._tutorial_unit = nil
	self._last_slot_name = nil
	self._last_known_attack = nil
	self._spawned_ai_units = {}
	self._animation_hooks = {}
	self._active = false
	self._bot_loot_enabled = true
	self._bot_portraits_enabled = {}

	return 
end
PlayGoTutorialSystem.destroy = function (self)
	if self._unit_animation_event then
		Unit.animation_event = self._unit_animation_event
		self._unit_animation_event = nil
	end

	return 
end
PlayGoTutorialSystem.active = function (self)
	return self._active
end
local dummy_input = {}
PlayGoTutorialSystem.on_add_extension = function (self, world, unit, extension_name, ...)
	fassert(self._tutorial_unit == nil, "Multiple tutorial units spawned on level!")

	local extension = {}
	self._tutorial_started = true
	self._tutorial_unit = unit
	self._world = world
	script_data.cap_num_bots = 1
	self._num_bots_active = 1
	script_data.ai_bots_disabled = true
	script_data.info_slates_disabled = true
	local definitions = local_require("scripts/ui/views/tutorial_tooltip_ui_definitions")
	self._active = true
	self._saved_position = definitions.scenegraph.tutorial_tooltip.position
	self._saved_definition = definitions.scenegraph.tutorial_tooltip
	self._saved_definition.position = {
		0,
		-440,
		1
	}
	self.player_ammo_refill = false
	self._profile_packages = {}
	local extension_alias = self.NAME

	ScriptUnit.set_extension(unit, extension_alias, extension, dummy_input)

	return extension
end
PlayGoTutorialSystem.trigger_pause_event = function (self, pause_event, look_position)
	self._current_pause_event = nil

	fassert(not self._current_animation_hook, "[PlayGoTutorialSystem:trigger_pause_event] Trying to trigger pause event %q while an animation hook is active", pause_event.name)
	fassert(not self._current_pause_event, "[PlayGoTutorialSystem:trigger_pause_event] Trying to trigger pause event %q while another pause event %q is active", pause_event.name, self._current_pause_event and self._current_pause_event.name)

	self._current_pause_event = pause_event
	pause_event.timer = Managers.time:time("game") + pause_event.animation_delay or 0
	pause_event.world = self._world

	self._current_pause_event.on_enter(pause_event, nil, look_position)

	return 
end
PlayGoTutorialSystem.add_animation_hook = function (self, animation_hook)
	self._animation_hooks[#self._animation_hooks + 1] = animation_hook

	self._add_next_animation_hook(self)

	return 
end
PlayGoTutorialSystem._add_next_animation_hook = function (self)
	self._unit_animation_event = self._unit_animation_event or Unit.animation_event
	local animation_hook = self._animation_hooks[1]

	if animation_hook then
		self._current_animation_hook = animation_hook
		Unit.animation_event = function (unit, animation_event)
			local breed = Unit.get_data(unit, "breed")

			if breed and breed.name == animation_hook.breed and not animation_hook.activated and table.find(animation_hook.animations, animation_event) and animation_hook.check_prerequisites() then
				animation_hook.timer = Managers.time:time("game") + animation_hook.animation_delay or 0
				animation_hook.world = self._world

				animation_hook.on_enter(animation_hook, unit)
			end

			return self._unit_animation_event(unit, animation_event)
		end
	else
		Unit.animation_event = self._unit_animation_event
		self._unit_animation_event = nil

		print("Resetting Unit.animation_event")
	end

	return 
end
PlayGoTutorialSystem.on_remove_extension = function (self, unit, extension_name)
	ScriptUnit.remove_extension(unit, self.NAME)
	self._unload_profile_packages(self)

	script_data.cap_num_bots = nil
	script_data.ai_bots_disabled = nil
	script_data.info_slates_disabled = nil
	self._saved_definition.position = self._saved_position
	self._active = false
	self._tutorial_started = false
	self._tutorial_unit = nil

	return 
end
PlayGoTutorialSystem.spawn_bot = function (self, profile_index)
	Managers.state.spawn:set_forced_bot_profile_index(profile_index)

	script_data.ai_bots_disabled = false
	script_data.cap_num_bots = self._num_bots_active
	self._num_bots_active = self._num_bots_active + 1

	return 
end
PlayGoTutorialSystem.set_bot_ready_for_assisted_respawn = function (self, unit, respawn_unit)
	local status_extension = ScriptUnit.extension(unit, "status_system")

	status_extension.set_ready_for_assisted_respawn(status_extension, true, respawn_unit)

	return 
end
PlayGoTutorialSystem.remove_player_ammo = function (self)
	local player = Managers.player:local_player()
	local inventory_extension = ScriptUnit.extension(player.player_unit, "inventory_system")
	local current, max = inventory_extension.current_ammo_status(inventory_extension, "slot_ranged")

	if current and 0 < current then
		local slot_data = inventory_extension.get_slot_data(inventory_extension, "slot_ranged")
		local left_unit_1p = slot_data.left_unit_1p
		local right_unit_1p = slot_data.right_unit_1p
		local ammo_extension = (ScriptUnit.has_extension(left_unit_1p, "ammo_system") and ScriptUnit.extension(left_unit_1p, "ammo_system")) or (ScriptUnit.has_extension(right_unit_1p, "ammo_system") and ScriptUnit.extension(right_unit_1p, "ammo_system"))

		if ammo_extension then
			ammo_extension.use_ammo(ammo_extension, 1)
			ammo_extension.add_ammo_to_reserve(ammo_extension, -(current - 1))
		end
	end

	return 
end
PlayGoTutorialSystem.check_player_ammo = function (self)
	local player = Managers.player:local_player()
	local inventory_extension = ScriptUnit.extension(player.player_unit, "inventory_system")
	local current, max = inventory_extension.current_ammo_status(inventory_extension, "slot_ranged")

	if 0 < current then
		return true
	end

	return false
end
PlayGoTutorialSystem.enable_player_ammo_refill = function (self)
	self.player_ammo_refill = true

	return 
end
local DO_RELOAD = false
PlayGoTutorialSystem.give_player_potion_from_bot = function (self, player_unit, bot_unit)
	local inventory = ScriptUnit.extension(player_unit, "inventory_system")
	local item_name = "potion_speed_boost_01"
	local item_data = ItemMasterList[item_name]

	inventory.add_equipment(inventory, "slot_potion", item_data)

	local player_manager = Managers.player
	local interactor_player = player_manager.unit_owner(player_manager, bot_unit)

	if interactor_player then
		Managers.state.event:trigger("give_item_feedback", interactor_player.stats_id(interactor_player) .. item_name, interactor_player, item_name)
	end

	return 
end
PlayGoTutorialSystem.update = function (self, context, t)
	if not self._tutorial_started then
		return 
	end

	local player = Managers.player:local_player()

	if not Unit.alive(player.player_unit) then
		return 
	end

	if DO_RELOAD then
		self._animation_hooks = {}

		Managers.time:set_global_time_scale(1)

		local player = Managers.player:local_player()
		local player_unit = player.player_unit
		local player_input = ScriptUnit.extension(player_unit, "input_system")

		player_input.set_enabled(player_input, true)

		self._current_animation_hook = nil

		if self._unit_animation_event then
			Unit.animation_event = self._unit_animation_event
			self._unit_animation_event = nil
		end

		DO_RELOAD = false
	end

	self._update_animation_hooks(self, player, t)
	self._update_pause_events(self, t)
	self._update_player_health(self, player)
	self._update_player_ammo(self, player)
	self._update_ai_units(self)
	self._capture_wield_switch(self, player)
	self._capture_attacks(self, player)

	return 
end
PlayGoTutorialSystem._update_animation_hooks = function (self, player, t)
	if self._current_animation_hook and self._current_animation_hook.activated and self._current_animation_hook.update(self._current_animation_hook, t) then
		self._current_animation_hook.on_exit(self._current_animation_hook)
		table.remove(self._animation_hooks, 1)

		self._current_animation_hook = nil

		self._add_next_animation_hook(self)
	end

	return 
end
PlayGoTutorialSystem._update_pause_events = function (self, t)
	if self._current_pause_event and self._current_pause_event.update(self._current_pause_event, t) then
		self._current_pause_event.on_exit(self._current_pause_event)

		self._current_pause_event = nil
	end

	return 
end
PlayGoTutorialSystem._update_player_health = function (self, player)
	local player_unit = player.player_unit
	local health_extension = ScriptUnit.extension(player_unit, "health_system")
	local hp_percent = health_extension.current_health_percent(health_extension)

	if hp_percent < 0.2 then
		health_extension.reset(health_extension)
	end

	return 
end
PlayGoTutorialSystem._capture_wield_switch = function (self, player)
	local player_unit = player.player_unit
	local inventory_extension = ScriptUnit.extension(player_unit, "inventory_system")

	if inventory_extension.get_wielded_slot_name(inventory_extension) ~= self._last_slot_name then
		self._last_slot_name = inventory_extension.get_wielded_slot_name(inventory_extension)

		Unit.flow_event(self._tutorial_unit, "lua_wield_switch")
	end

	return 
end
PlayGoTutorialSystem._capture_attacks = function (self, player)
	local player_unit = player.player_unit
	local inventory_extension = ScriptUnit.extension(player_unit, "inventory_system")
	local equipment = inventory_extension.equipment(inventory_extension)
	local weapon_unit = equipment.right_hand_wielded_unit or equipment.left_hand_wielded_unit

	if weapon_unit then
		local weapon_extension = ScriptUnit.extension(weapon_unit, "weapon_system")

		if weapon_extension.has_current_action(weapon_extension) then
			local action_settings = weapon_extension.get_current_action_settings(weapon_extension)

			if action_settings.charge_value ~= nil then
				self._last_known_attack = action_settings.charge_value
			end
		end
	end

	return 
end
PlayGoTutorialSystem._update_player_ammo = function (self, player)
	if not self.player_ammo_refill then
		return 
	end

	local inventory_extension = ScriptUnit.extension(player.player_unit, "inventory_system")
	local current, max = inventory_extension.current_ammo_status(inventory_extension, "slot_ranged")

	if current == 0 then
		local slot_data = inventory_extension.get_slot_data(inventory_extension, "slot_ranged")
		local left_unit_1p = slot_data.left_unit_1p
		local ammo_extension = ScriptUnit.has_extension(left_unit_1p, "ammo_system") and ScriptUnit.extension(left_unit_1p, "ammo_system")

		if ammo_extension then
			ammo_extension.add_ammo(ammo_extension, max)

			if inventory_extension.get_wielded_slot_name(inventory_extension) == "slot_ranged" and ammo_extension.can_reload(ammo_extension) then
				ammo_extension.start_reload(ammo_extension, true)
			end
		end
	end

	return 
end
PlayGoTutorialSystem._update_ai_units = function (self)
	for i, data in pairs(self._spawned_ai_units) do
		if Unit.alive(data.ai_unit) and not ScriptUnit.extension(data.ai_unit, "health_system"):is_alive() then
			if data.is_highlighted then
				local outline_extension = ScriptUnit.extension(data.ai_unit, "outline_system")

				outline_extension.set_method("never")
			end

			Unit.flow_event(data.spawner_unit, "lua_ai_death")

			self._spawned_ai_units[i] = nil

			break
		end
	end

	return 
end
PlayGoTutorialSystem._load_profile_packages = function (self)
	local profiles_to_load = {
		3,
		4
	}
	local career_index = 1
	local is_first_person = {
		4 = true,
		3 = false
	}
	local slots = InventorySettings.slots
	local num_slots = #InventorySettings.slots
	local profile_packages = self._profile_packages

	for _, profile_index in ipairs(profiles_to_load) do
		local profile = SPProfiles[profile_index]
		local career = profile.careers[career_index]
		local career_name = career.name

		for i = 1, num_slots, 1 do
			local slot = slots[i]
			local slot_name = slot.NAME
			local slot_category = slot.category
			local item = BackendUtils.get_loadout_item(career_name, slot_name)

			if not item then
			else
				local backend_id = item.backend_id
				local item_data = item.data
				local item_template = BackendUtils.get_item_template(item_data, backend_id)
				local item_units = BackendUtils.get_item_units(item_data, backend_id)

				if slot_category == "weapon" then
					local left_hand_unit_name = item_units.left_hand_unit

					if left_hand_unit_name then
						if is_first_person[profile_index] then
							profile_packages[left_hand_unit_name] = true
						end

						profile_packages[left_hand_unit_name .. "_3p"] = true
					end

					local right_hand_unit_name = item_units.right_hand_unit

					if right_hand_unit_name then
						if is_first_person[profile_index] then
							profile_packages[right_hand_unit_name] = true
						end

						profile_packages[right_hand_unit_name .. "_3p"] = true
					end

					local actions = item_template.actions

					for action_name, sub_actions in pairs(actions) do
						for sub_action_name, sub_action_data in pairs(sub_actions) do
							local projectile_info = sub_action_data.projectile_info

							if projectile_info then
								if projectile_info.projectile_unit_name then
									profile_packages[projectile_info.projectile_unit_name] = true
								end

								if projectile_info.dummy_linker_unit_name then
									profile_packages[projectile_info.dummy_linker_unit_name] = true
								end

								if projectile_info.dummy_linker_broken_units then
									for unit_name, unit in pairs(projectile_info.dummy_linker_broken_units) do
										profile_packages[unit] = true
									end
								end
							end
						end
					end

					local ammo_data = item_template.ammo_data

					if ammo_data and ammo_data.ammo_unit then
						if is_first_person[profile_index] then
							profile_packages[ammo_data.ammo_unit] = true
						end

						profile_packages[ammo_data.ammo_unit_3p] = true
					end
				elseif slot_category == "attachment" then
					profile_packages[item_units.unit] = true
				else
					error("InventoryPackageSynchronizerClient unknown slot_category: " .. slot_category)
				end
			end
		end

		local base_units = profile.base_units

		if is_first_person[profile_index] then
			profile_packages[base_units.first_person] = true
			profile_packages[base_units.first_person_bot] = true
			profile_packages[base_units.third_person] = true
			profile_packages[base_units.third_person_bot] = true
		else
			profile_packages[base_units.third_person_husk] = true
		end

		local first_person_attachment = profile.first_person_attachment

		if is_first_person[profile_index] then
			profile_packages[first_person_attachment.unit] = true
		end
	end

	for package_name, _ in pairs(profile_packages) do
		Managers.package:load(package_name, "play_go_tutorial_system", nil, true)
	end

	print("[PlayGoTutorialSystem]:_load_profile_packages()")

	return 
end
PlayGoTutorialSystem._unload_profile_packages = function (self)
	local profile_packages = self._profile_packages

	for package_name, _ in pairs(profile_packages) do
		Managers.package:unload(package_name, "play_go_tutorial_system")

		profile_packages[package_name] = nil
	end

	print("[PlayGoTutorialSystem]:_unload_profile_packages()")

	return 
end
PlayGoTutorialSystem.register_dodge = function (self, dodge_direction)
	if self._tutorial_started then
		local tutorial_unit = self._tutorial_unit
		local x_value = Vector3.x(dodge_direction)
		local y_value = Vector3.y(dodge_direction)

		if math.abs(x_value) < math.abs(y_value) then
			Unit.flow_event(tutorial_unit, "lua_dodge_backward")
		elseif 0 < x_value then
			Unit.flow_event(tutorial_unit, "lua_dodge_right")
		else
			Unit.flow_event(tutorial_unit, "lua_dodge_left")
		end
	end

	return 
end
PlayGoTutorialSystem.register_push = function (self, hit_unit)
	if self._tutorial_started and Unit.alive(hit_unit) and ScriptUnit.extension(hit_unit, "health_system"):is_alive() then
		Unit.flow_event(self._tutorial_unit, "lua_pushed_enemy")
	end

	return 
end
PlayGoTutorialSystem.register_block = function (self)
	if self._tutorial_started then
		Unit.flow_event(self._tutorial_unit, "lua_blocked_attack")
	end

	return 
end
PlayGoTutorialSystem.register_killing_blow = function (self, damage_type, attacker)
	if self._tutorial_started then
		local local_player = Managers.player:local_player()

		if attacker == local_player.player_unit then
			local tutorial_unit = self._tutorial_unit
			local last_known_attack = self._last_known_attack

			if damage_type == "grenade" or damage_type == "grenade_glance" then
				Unit.flow_event(tutorial_unit, "lua_grenade_attack")
			elseif last_known_attack == "light_attack" then
				Unit.flow_event(tutorial_unit, "lua_light_attack")
			elseif last_known_attack == "heavy_attack" then
				Unit.flow_event(tutorial_unit, "lua_heavy_attack")
			elseif last_known_attack == "arrow_hit" then
				Unit.flow_event(tutorial_unit, "lua_normal_ranged_attack")
			elseif last_known_attack == "zoomed_arrow_hit" then
				Unit.flow_event(tutorial_unit, "lua_alternative_ranged_attack")
			end
		end
	end

	return 
end
PlayGoTutorialSystem.register_unit = function (self, spawner_unit, ai_unit)
	if not self._tutorial_started then
		return 
	end

	local data = {}

	if Unit.get_data(spawner_unit, "Tutorial", "aggro_on_spawn") then
		local local_player = Managers.player:local_player()

		ScriptUnit.extension(ai_unit, "ai_system"):enemy_aggro(ai_unit, local_player.player_unit)
	end

	Unit.flow_event(spawner_unit, "lua_ai_spawned")

	if Unit.get_data(spawner_unit, "Tutorial", "highlight_on_spawn") then
		local outline_extension = ScriptUnit.extension(ai_unit, "outline_system")

		outline_extension.set_method("always")

		outline_extension.outline_color = OutlineSettings.colors.interactable

		outline_extension.reapply_outline(outline_extension)

		data.is_highlighted = true
	end

	data.spawner_unit = spawner_unit
	data.ai_unit = ai_unit

	table.insert(self._spawned_ai_units, data)

	return 
end
PlayGoTutorialSystem.teleport_unit = function (self, unit, position, rotation)
	local locomotion_extension = ScriptUnit.extension(unit, "locomotion_system")

	locomotion_extension.teleport_to(locomotion_extension, position, rotation)

	local bot = Unit.get_data(unit, "bot")

	if bot then
		local navigation_extension = ScriptUnit.extension(unit, "ai_navigation_system")

		navigation_extension.teleport(navigation_extension, position)
	end

	return 
end
PlayGoTutorialSystem.enable_bot_loot = function (self, enable)
	self._bot_loot_enabled = enable

	return 
end
PlayGoTutorialSystem.bot_loot_enabled = function (self)
	return self._bot_loot_enabled
end
PlayGoTutorialSystem.set_bot_portrait_enabled = function (self, bot_display_name)
	self._bot_portraits_enabled[bot_display_name] = true

	return 
end
PlayGoTutorialSystem.bot_portrait_enabled = function (self, player)
	local display_name = player.player_name

	return self._bot_portraits_enabled[display_name]
end

return 

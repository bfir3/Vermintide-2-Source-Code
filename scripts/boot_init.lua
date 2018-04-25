jit.off()

MODE = {}

if not LEVEL_EDITOR_TEST then
	LEVEL_EDITOR_TEST = false
end

local function import(lib)
	for k, v in pairs(lib) do
		_G[k] = v
	end

	return 
end

if s3d then
	import(s3d)
end

BUILD = Application.build()
PLATFORM = Application.platform()
LAUNCH_MODE = "game"
local args = {
	Application.argv()
}

for _, arg in pairs(args) do
	if arg == "-attract-mode" then
		LAUNCH_MODE = "attract"

		break
	end

	if arg == "-benchmark-mode" then
		LAUNCH_MODE = "attract_benchmark"

		break
	end
end

Application.build = function ()
	error("Trying to use BUILD, use global variable BUILD instead.")

	return 
end
Application.platform = function ()
	error("Trying to use Application.platform(), use global variable PLATFORM instead.")

	return 
end

if not PROFILER_SCOPES_INITED then
	local ProfilerScopes = {}
	PROFILER_SCOPES_INITED = true
end

GLOBAL_FRAME_INDEX = GLOBAL_FRAME_INDEX or 0
script_data = script_data or {}

if LEVEL_EDITOR_TEST then
	GlobalResources = GlobalResources or {
		"resource_packages/menu_assets_common",
		"resource_packages/ingame_light",
		"resource_packages/projection_decals",
		"resource_packages/inventory",
		"resource_packages/pickups",
		"resource_packages/decals",
		"resource_packages/common_level_resources",
		"resource_packages/levels/ui_loot_preview",
		"resource_packages/levels/ui_end_screen",
		"resource_packages/levels/ui_end_screen_defeat",
		"resource_packages/levels/ui_end_screen_win",
		"resource_packages/levels/ui_inventory_preview",
		"resource_packages/levels/ui_character_selection"
	}
elseif PLATFORM == "ps4" then
	GlobalResources = GlobalResources or {
		"resource_packages/common_level_resources",
		"resource_packages/menu_assets_common",
		"resource_packages/ingame_sounds_one",
		"resource_packages/ingame_sounds_two",
		"resource_packages/ingame_sounds_three",
		"resource_packages/ingame_sounds_weapon_general",
		"resource_packages/ingame_sounds_enemy_clan_rat_vce",
		"resource_packages/ingame_sounds_player_foley_common",
		"resource_packages/ingame_sounds_hud_dice_game",
		"resource_packages/ingame_sounds_general_props",
		"resource_packages/inventory",
		"resource_packages/decals",
		"resource_packages/levels/ui_loot_preview",
		"resource_packages/levels/ui_end_screen",
		"resource_packages/levels/ui_end_screen_defeat",
		"resource_packages/levels/ui_end_screen_win",
		"resource_packages/levels/ui_inventory_preview",
		"resource_packages/ingame",
		"resource_packages/pickups",
		"resource_packages/levels/ui_character_selection"
	}
elseif PLATFORM == "xb1" then
	GlobalResources = GlobalResources or {
		"resource_packages/common_level_resources",
		"resource_packages/menu_assets_common",
		"resource_packages/ingame_sounds_one",
		"resource_packages/ingame_sounds_two",
		"resource_packages/ingame_sounds_three",
		"resource_packages/ingame_sounds_weapon_general",
		"resource_packages/ingame_sounds_enemy_clan_rat_vce",
		"resource_packages/ingame_sounds_player_foley_common",
		"resource_packages/ingame_sounds_hud_dice_game",
		"resource_packages/ingame_sounds_general_props",
		"resource_packages/inventory",
		"resource_packages/decals",
		"resource_packages/levels/ui_loot_preview",
		"resource_packages/levels/ui_end_screen",
		"resource_packages/levels/ui_end_screen_defeat",
		"resource_packages/levels/ui_end_screen_win",
		"resource_packages/levels/ui_inventory_preview",
		"resource_packages/ingame",
		"resource_packages/pickups",
		"resource_packages/levels/ui_character_selection",
		"resource_packages/projection_decals",
		"resource_packages/ingame_breeds_optimized",
		"resource_packages/ingame_sounds_honduras"
	}
else
	GlobalResources = GlobalResources or {
		"resource_packages/common_level_resources",
		"resource_packages/menu_assets_common",
		"resource_packages/ingame_sounds_one",
		"resource_packages/ingame_sounds_two",
		"resource_packages/ingame_sounds_three",
		"resource_packages/ingame_sounds_weapon_general",
		"resource_packages/ingame_sounds_enemy_clan_rat_vce",
		"resource_packages/ingame_sounds_player_foley_common",
		"resource_packages/ingame_sounds_hud_dice_game",
		"resource_packages/ingame_sounds_general_props",
		"resource_packages/ingame_sounds_honduras",
		"resource_packages/inventory",
		"resource_packages/decals",
		"resource_packages/levels/ui_loot_preview",
		"resource_packages/levels/ui_end_screen",
		"resource_packages/levels/ui_end_screen_defeat",
		"resource_packages/levels/ui_end_screen_win",
		"resource_packages/levels/ui_inventory_preview",
		"resource_packages/ingame",
		"resource_packages/pickups",
		"resource_packages/projection_decals",
		"resource_packages/levels/ui_character_selection"
	}
end

return 

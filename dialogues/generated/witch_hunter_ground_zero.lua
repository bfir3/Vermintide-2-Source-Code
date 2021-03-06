return function ()
	define_rule({
		name = "pwh_level_ground_zero_canals",
		response = "pwh_level_ground_zero_canals",
		criterias = {
			{
				"query_context",
				"concept",
				OP.EQ,
				"seen_item"
			},
			{
				"query_context",
				"item_tag",
				OP.EQ,
				"ground_zero_canals"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"witch_hunter"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"witch_hunter"
			},
			{
				"faction_memory",
				"level_ground_zero_canals",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"level_ground_zero_canals",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwh_level_ground_zero_cargo_elevator",
		response = "pwh_level_ground_zero_cargo_elevator",
		criterias = {
			{
				"query_context",
				"concept",
				OP.EQ,
				"seen_item"
			},
			{
				"query_context",
				"item_tag",
				OP.EQ,
				"ground_zero_cargo_elevator"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"witch_hunter"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"witch_hunter"
			},
			{
				"faction_memory",
				"level_ground_zero_cargo_elevator",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"level_ground_zero_cargo_elevator",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwh_level_ground_zero_corruption_everywhere",
		response = "pwh_level_ground_zero_corruption_everywhere",
		criterias = {
			{
				"query_context",
				"concept",
				OP.EQ,
				"seen_item"
			},
			{
				"query_context",
				"item_tag",
				OP.EQ,
				"ground_zero_corruption_everywhere"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"witch_hunter"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"witch_hunter"
			},
			{
				"faction_memory",
				"level_ground_zero_corruption_everywhere",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"level_ground_zero_corruption_everywhere",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwh_level_ground_zero_crumbling",
		response = "pwh_level_ground_zero_crumbling",
		criterias = {
			{
				"query_context",
				"concept",
				OP.EQ,
				"seen_item"
			},
			{
				"query_context",
				"item_tag",
				OP.EQ,
				"ground_zero_crumbling"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"witch_hunter"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"witch_hunter"
			},
			{
				"faction_memory",
				"level_ground_zero_crumbling",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"level_ground_zero_crumbling",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwh_level_ground_zero_looking_for_elevator",
		response = "pwh_level_ground_zero_looking_for_elevator",
		criterias = {
			{
				"query_context",
				"concept",
				OP.EQ,
				"seen_item"
			},
			{
				"query_context",
				"item_tag",
				OP.EQ,
				"ground_zero_looking_for_elevator"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"witch_hunter"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"witch_hunter"
			},
			{
				"faction_memory",
				"level_ground_zero_looking_for_elevator",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"level_ground_zero_looking_for_elevator",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwh_level_ground_zero_smell",
		response = "pwh_level_ground_zero_smell",
		criterias = {
			{
				"query_context",
				"concept",
				OP.EQ,
				"seen_item"
			},
			{
				"query_context",
				"item_tag",
				OP.EQ,
				"ground_zero_smell"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"witch_hunter"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"witch_hunter"
			},
			{
				"faction_memory",
				"level_ground_zero_smell",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"level_ground_zero_smell",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwh_level_ground_zero_the_hole",
		response = "pwh_level_ground_zero_the_hole",
		criterias = {
			{
				"query_context",
				"concept",
				OP.EQ,
				"seen_item"
			},
			{
				"query_context",
				"item_tag",
				OP.EQ,
				"ground_zero_the_hole"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"witch_hunter"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"witch_hunter"
			},
			{
				"faction_memory",
				"level_ground_zero_the_hole",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"level_ground_zero_the_hole",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwh_level_ground_zero_welcoming_committee",
		response = "pwh_level_ground_zero_welcoming_committee",
		criterias = {
			{
				"query_context",
				"concept",
				OP.EQ,
				"seen_item"
			},
			{
				"query_context",
				"item_tag",
				OP.EQ,
				"ground_zero_welcoming_committee"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"witch_hunter"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"witch_hunter"
			},
			{
				"faction_memory",
				"level_ground_zero_welcoming_committee",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"level_ground_zero_welcoming_committee",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwh_level_ground_zero_precarious",
		response = "pwh_level_ground_zero_precarious",
		criterias = {
			{
				"query_context",
				"concept",
				OP.EQ,
				"seen_item"
			},
			{
				"query_context",
				"item_tag",
				OP.EQ,
				"ground_zero_precarious"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"witch_hunter"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"witch_hunter"
			},
			{
				"faction_memory",
				"level_ground_zero_precarious",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"level_ground_zero_precarious",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwh_level_ground_zero_draw_bridge",
		response = "pwh_level_ground_zero_draw_bridge",
		criterias = {
			{
				"query_context",
				"concept",
				OP.EQ,
				"seen_item"
			},
			{
				"query_context",
				"item_tag",
				OP.EQ,
				"ground_zero_draw_bridge"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"witch_hunter"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"witch_hunter"
			},
			{
				"faction_memory",
				"level_ground_zero_draw_bridge",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"level_ground_zero_draw_bridge",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwh_level_ground_zero_landslide",
		response = "pwh_level_ground_zero_landslide",
		criterias = {
			{
				"query_context",
				"concept",
				OP.EQ,
				"seen_item"
			},
			{
				"query_context",
				"item_tag",
				OP.EQ,
				"ground_zero_landslide"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"witch_hunter"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"witch_hunter"
			},
			{
				"faction_memory",
				"level_ground_zero_landslide",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"level_ground_zero_landslide",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwh_level_ground_zero_the_hole_second_view",
		response = "pwh_level_ground_zero_the_hole_second_view",
		criterias = {
			{
				"query_context",
				"concept",
				OP.EQ,
				"seen_item"
			},
			{
				"query_context",
				"item_tag",
				OP.EQ,
				"ground_zero_the_hole_second_view"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"witch_hunter"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"witch_hunter"
			},
			{
				"faction_memory",
				"level_ground_zero_the_hole_second_view",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"level_ground_zero_the_hole_second_view",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwh_level_ground_zero_boss_near",
		response = "pwh_level_ground_zero_boss_near",
		criterias = {
			{
				"query_context",
				"concept",
				OP.EQ,
				"seen_item"
			},
			{
				"query_context",
				"item_tag",
				OP.EQ,
				"ground_zero_boss_near"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"witch_hunter"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"witch_hunter"
			},
			{
				"faction_memory",
				"level_ground_zero_boss_near",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"level_ground_zero_boss_near",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwh_ground_zero_intro_a",
		response = "pwh_ground_zero_intro_a",
		criterias = {
			{
				"query_context",
				"concept",
				OP.EQ,
				"seen_item"
			},
			{
				"query_context",
				"item_tag",
				OP.EQ,
				"ground_zero_intro_a"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"witch_hunter"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"witch_hunter"
			},
			{
				"faction_memory",
				"ground_zero_intro_a",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"ground_zero_intro_a",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwh_ground_zero_intro_b",
		response = "pwh_ground_zero_intro_b",
		criterias = {
			{
				"query_context",
				"concept",
				OP.EQ,
				"heard_speak"
			},
			{
				"query_context",
				"dialogue_name_nopre",
				OP.EQ,
				"ground_zero_intro_a"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"witch_hunter"
			},
			{
				"faction_memory",
				"ground_zero_intro_b",
				OP.TIMEDIFF,
				OP.GT,
				1
			}
		},
		on_done = {
			{
				"faction_memory",
				"ground_zero_intro_b",
				OP.TIMESET
			}
		}
	})
	define_rule({
		name = "pwh_ground_zero_intro_c",
		response = "pwh_ground_zero_intro_c",
		criterias = {
			{
				"query_context",
				"concept",
				OP.EQ,
				"heard_speak"
			},
			{
				"query_context",
				"dialogue_name_nopre",
				OP.EQ,
				"ground_zero_intro_c"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"witch_hunter"
			},
			{
				"faction_memory",
				"ground_zero_intro_c",
				OP.TIMEDIFF,
				OP.GT,
				1
			}
		},
		on_done = {
			{
				"faction_memory",
				"ground_zero_intro_c",
				OP.TIMESET
			}
		}
	})
	define_rule({
		name = "pwh_level_ground_zero_boss_spotted",
		response = "pwh_level_ground_zero_boss_spotted",
		criterias = {
			{
				"query_context",
				"concept",
				OP.EQ,
				"heard_speak"
			},
			{
				"query_context",
				"dialogue_name",
				OP.EQ,
				"ebh_level_ground_zero_lord_intro"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"witch_hunter"
			},
			{
				"faction_memory",
				"ground_zero_boss_spotted",
				OP.TIMEDIFF,
				OP.GT,
				10
			}
		},
		on_done = {
			{
				"faction_memory",
				"ground_zero_boss_spotted",
				OP.TIMESET
			}
		}
	})
	define_rule({
		name = "pwh_level_ground_zero_boss_taunt_reply",
		response = "pwh_level_ground_zero_boss_taunt_reply",
		criterias = {
			{
				"query_context",
				"concept",
				OP.EQ,
				"heard_speak"
			},
			{
				"query_context",
				"dialogue_name",
				OP.EQ,
				"ebh_level_ground_zero_lord_banter"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"witch_hunter"
			},
			{
				"faction_memory",
				"ground_zero_boss_taunt_reply",
				OP.TIMEDIFF,
				OP.GT,
				60
			}
		},
		on_done = {
			{
				"faction_memory",
				"ground_zero_boss_taunt_reply",
				OP.TIMESET
			}
		}
	})
	define_rule({
		name = "pwh_level_ground_zero_complete",
		response = "pwh_level_ground_zero_complete",
		criterias = {
			{
				"query_context",
				"concept",
				OP.EQ,
				"enemy_kill"
			},
			{
				"query_context",
				"killed_type",
				OP.EQ,
				"chaos_exalted_champion_warcamp"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"witch_hunter"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"witch_hunter"
			},
			{
				"user_memory",
				"level_ground_zero_complete",
				OP.TIMEDIFF,
				OP.GT,
				10
			}
		},
		on_done = {
			{
				"user_memory",
				"level_ground_zero_complete",
				OP.TIMESET
			}
		}
	})
	define_rule({
		name = "pwh_level_ground_zero_canal_crossing",
		response = "pwh_level_ground_zero_canal_crossing",
		criterias = {
			{
				"query_context",
				"concept",
				OP.EQ,
				"seen_item"
			},
			{
				"query_context",
				"item_tag",
				OP.EQ,
				"ground_zero_canal_crossing"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"witch_hunter"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"witch_hunter"
			},
			{
				"faction_memory",
				"level_ground_zero_canal_crossing",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"level_ground_zero_canal_crossing",
				OP.ADD,
				1
			}
		}
	})
	add_dialogues({
		pwh_ground_zero_intro_c = {
			sound_events_n = 2,
			randomize_indexes_n = 0,
			face_animations_n = 2,
			database = "witch_hunter_ground_zero",
			category = "level_talk",
			dialogue_animations_n = 2,
			sound_events = {
				[1.0] = "pwh_ground_zero_intro_c_01",
				[2.0] = "pwh_ground_zero_intro_c_02"
			},
			dialogue_animations = {
				[1.0] = "dialogue_talk",
				[2.0] = "dialogue_talk"
			},
			face_animations = {
				[1.0] = "face_neutral",
				[2.0] = "face_neutral"
			},
			localization_strings = {
				[1.0] = "pwh_ground_zero_intro_c_01",
				[2.0] = "pwh_ground_zero_intro_c_02"
			},
			randomize_indexes = {}
		},
		pwh_level_ground_zero_landslide = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "witch_hunter_ground_zero",
			category = "story_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwh_level_ground_zero_landslide_01",
				"pwh_level_ground_zero_landslide_02",
				"pwh_level_ground_zero_landslide_03",
				"pwh_level_ground_zero_landslide_04"
			},
			dialogue_animations = {
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout"
			},
			face_animations = {
				"face_fear",
				"face_fear",
				"face_fear",
				"face_fear"
			},
			localization_strings = {
				"pwh_level_ground_zero_landslide_01",
				"pwh_level_ground_zero_landslide_02",
				"pwh_level_ground_zero_landslide_03",
				"pwh_level_ground_zero_landslide_04"
			},
			randomize_indexes = {}
		},
		pwh_level_ground_zero_cargo_elevator = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "witch_hunter_ground_zero",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwh_level_ground_zero_cargo_elevator_01",
				"pwh_level_ground_zero_cargo_elevator_02",
				"pwh_level_ground_zero_cargo_elevator_03",
				"pwh_level_ground_zero_cargo_elevator_04"
			},
			dialogue_animations = {
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout"
			},
			face_animations = {
				"face_calm",
				"face_calm",
				"face_calm",
				"face_calm"
			},
			localization_strings = {
				"pwh_level_ground_zero_cargo_elevator_01",
				"pwh_level_ground_zero_cargo_elevator_02",
				"pwh_level_ground_zero_cargo_elevator_03",
				"pwh_level_ground_zero_cargo_elevator_04"
			},
			randomize_indexes = {}
		},
		pwh_level_ground_zero_the_hole_second_view = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "witch_hunter_ground_zero",
			category = "story_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwh_level_ground_zero_the_hole_second_view_01",
				"pwh_level_ground_zero_the_hole_second_view_02",
				"pwh_level_ground_zero_the_hole_second_view_03",
				"pwh_level_ground_zero_the_hole_second_view_04"
			},
			dialogue_animations = {
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout"
			},
			face_animations = {
				"face_fear",
				"face_fear",
				"face_fear",
				"face_fear"
			},
			localization_strings = {
				"pwh_level_ground_zero_the_hole_second_view_01",
				"pwh_level_ground_zero_the_hole_second_view_02",
				"pwh_level_ground_zero_the_hole_second_view_03",
				"pwh_level_ground_zero_the_hole_second_view_04"
			},
			randomize_indexes = {}
		},
		pwh_level_ground_zero_looking_for_elevator = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "witch_hunter_ground_zero",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwh_level_ground_zero_looking_for_elevator_01",
				"pwh_level_ground_zero_looking_for_elevator_02",
				"pwh_level_ground_zero_looking_for_elevator_03",
				"pwh_level_ground_zero_looking_for_elevator_04"
			},
			dialogue_animations = {
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout"
			},
			face_animations = {
				"face_fear",
				"face_fear",
				"face_fear",
				"face_fear"
			},
			localization_strings = {
				"pwh_level_ground_zero_looking_for_elevator_01",
				"pwh_level_ground_zero_looking_for_elevator_02",
				"pwh_level_ground_zero_looking_for_elevator_03",
				"pwh_level_ground_zero_looking_for_elevator_04"
			},
			randomize_indexes = {}
		},
		pwh_ground_zero_intro_b = {
			sound_events_n = 2,
			randomize_indexes_n = 0,
			face_animations_n = 2,
			database = "witch_hunter_ground_zero",
			category = "level_talk",
			dialogue_animations_n = 2,
			sound_events = {
				[1.0] = "pwh_ground_zero_intro_b_01",
				[2.0] = "pwh_ground_zero_intro_b_02"
			},
			dialogue_animations = {
				[1.0] = "dialogue_talk",
				[2.0] = "dialogue_talk"
			},
			face_animations = {
				[1.0] = "face_neutral",
				[2.0] = "face_neutral"
			},
			localization_strings = {
				[1.0] = "pwh_ground_zero_intro_b_01",
				[2.0] = "pwh_ground_zero_intro_b_02"
			},
			randomize_indexes = {}
		},
		pwh_level_ground_zero_boss_spotted = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "witch_hunter_ground_zero",
			category = "player_alerts_boss",
			dialogue_animations_n = 4,
			sound_events = {
				"pwh_level_ground_zero_boss_spotted_01",
				"pwh_level_ground_zero_boss_spotted_02",
				"pwh_level_ground_zero_boss_spotted_03",
				"pwh_level_ground_zero_boss_spotted_04"
			},
			dialogue_animations = {
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout"
			},
			face_animations = {
				"face_neutral",
				"face_neutral",
				"face_neutral",
				"face_neutral"
			},
			localization_strings = {
				"pwh_level_ground_zero_boss_spotted_01",
				"pwh_level_ground_zero_boss_spotted_02",
				"pwh_level_ground_zero_boss_spotted_03",
				"pwh_level_ground_zero_boss_spotted_04"
			},
			randomize_indexes = {}
		},
		pwh_level_ground_zero_boss_near = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "witch_hunter_ground_zero",
			category = "story_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwh_level_ground_zero_boss_near_01",
				"pwh_level_ground_zero_boss_near_02",
				"pwh_level_ground_zero_boss_near_03",
				"pwh_level_ground_zero_boss_near_04"
			},
			dialogue_animations = {
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout"
			},
			face_animations = {
				"face_fear",
				"face_fear",
				"face_fear",
				"face_fear"
			},
			localization_strings = {
				"pwh_level_ground_zero_boss_near_01",
				"pwh_level_ground_zero_boss_near_02",
				"pwh_level_ground_zero_boss_near_03",
				"pwh_level_ground_zero_boss_near_04"
			},
			randomize_indexes = {}
		},
		pwh_level_ground_zero_welcoming_committee = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "witch_hunter_ground_zero",
			category = "story_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwh_level_ground_zero_welcoming_committee_01",
				"pwh_level_ground_zero_welcoming_committee_02",
				"pwh_level_ground_zero_welcoming_committee_03",
				"pwh_level_ground_zero_welcoming_committee_04"
			},
			dialogue_animations = {
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout"
			},
			face_animations = {
				"face_fear",
				"face_fear",
				"face_fear",
				"face_fear"
			},
			localization_strings = {
				"pwh_level_ground_zero_welcoming_committee_01",
				"pwh_level_ground_zero_welcoming_committee_02",
				"pwh_level_ground_zero_welcoming_committee_03",
				"pwh_level_ground_zero_welcoming_committee_04"
			},
			randomize_indexes = {}
		},
		pwh_level_ground_zero_canals = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "witch_hunter_ground_zero",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwh_level_ground_zero_canals_01",
				"pwh_level_ground_zero_canals_02",
				"pwh_level_ground_zero_canals_03",
				"pwh_level_ground_zero_canals_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_calm",
				"face_calm",
				"face_calm",
				"face_calm"
			},
			localization_strings = {
				"pwh_level_ground_zero_canals_01",
				"pwh_level_ground_zero_canals_02",
				"pwh_level_ground_zero_canals_03",
				"pwh_level_ground_zero_canals_04"
			},
			randomize_indexes = {}
		},
		pwh_level_ground_zero_precarious = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "witch_hunter_ground_zero",
			category = "story_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwh_level_ground_zero_precarious_01",
				"pwh_level_ground_zero_precarious_02",
				"pwh_level_ground_zero_precarious_03",
				"pwh_level_ground_zero_precarious_04"
			},
			dialogue_animations = {
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout"
			},
			face_animations = {
				"face_fear",
				"face_fear",
				"face_fear",
				"face_fear"
			},
			localization_strings = {
				"pwh_level_ground_zero_precarious_01",
				"pwh_level_ground_zero_precarious_02",
				"pwh_level_ground_zero_precarious_03",
				"pwh_level_ground_zero_precarious_04"
			},
			randomize_indexes = {}
		},
		pwh_level_ground_zero_boss_taunt_reply = {
			sound_events_n = 2,
			randomize_indexes_n = 0,
			face_animations_n = 2,
			database = "witch_hunter_ground_zero",
			category = "player_alerts_boss",
			dialogue_animations_n = 2,
			sound_events = {
				[1.0] = "pwh_level_ground_zero_boss_taunt_reply_01",
				[2.0] = "pwh_level_ground_zero_boss_taunt_reply_02"
			},
			dialogue_animations = {
				[1.0] = "dialogue_shout",
				[2.0] = "dialogue_shout"
			},
			face_animations = {
				[1.0] = "face_neutral",
				[2.0] = "face_neutral"
			},
			localization_strings = {
				[1.0] = "pwh_level_ground_zero_boss_taunt_reply_01",
				[2.0] = "pwh_level_ground_zero_boss_taunt_reply_02"
			},
			randomize_indexes = {}
		},
		pwh_level_ground_zero_canal_crossing = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "witch_hunter_ground_zero",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwh_level_ground_zero_canal_crossing_01",
				"pwh_level_ground_zero_canal_crossing_02",
				"pwh_level_ground_zero_canal_crossing_03",
				"pwh_level_ground_zero_canal_crossing_04"
			},
			dialogue_animations = {
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout"
			},
			face_animations = {
				"face_fear",
				"face_fear",
				"face_fear",
				"face_fear"
			},
			localization_strings = {
				"pwh_level_ground_zero_canal_crossing_01",
				"pwh_level_ground_zero_canal_crossing_02",
				"pwh_level_ground_zero_canal_crossing_03",
				"pwh_level_ground_zero_canal_crossing_04"
			},
			randomize_indexes = {}
		},
		pwh_level_ground_zero_the_hole = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "witch_hunter_ground_zero",
			category = "story_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwh_level_ground_zero_the_hole_01",
				"pwh_level_ground_zero_the_hole_02",
				"pwh_level_ground_zero_the_hole_03",
				"pwh_level_ground_zero_the_hole_04"
			},
			dialogue_animations = {
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout"
			},
			face_animations = {
				"face_fear",
				"face_fear",
				"face_fear",
				"face_fear"
			},
			localization_strings = {
				"pwh_level_ground_zero_the_hole_01",
				"pwh_level_ground_zero_the_hole_02",
				"pwh_level_ground_zero_the_hole_03",
				"pwh_level_ground_zero_the_hole_04"
			},
			randomize_indexes = {}
		},
		pwh_level_ground_zero_crumbling = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "witch_hunter_ground_zero",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwh_level_ground_zero_crumbling_01",
				"pwh_level_ground_zero_crumbling_02",
				"pwh_level_ground_zero_crumbling_03",
				"pwh_level_ground_zero_crumbling_04"
			},
			dialogue_animations = {
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout"
			},
			face_animations = {
				"face_fear",
				"face_fear",
				"face_fear",
				"face_fear"
			},
			localization_strings = {
				"pwh_level_ground_zero_crumbling_01",
				"pwh_level_ground_zero_crumbling_02",
				"pwh_level_ground_zero_crumbling_03",
				"pwh_level_ground_zero_crumbling_04"
			},
			randomize_indexes = {}
		},
		pwh_ground_zero_intro_a = {
			sound_events_n = 2,
			randomize_indexes_n = 0,
			face_animations_n = 2,
			database = "witch_hunter_ground_zero",
			category = "level_talk",
			dialogue_animations_n = 2,
			sound_events = {
				[1.0] = "pwh_ground_zero_intro_a_01",
				[2.0] = "pwh_ground_zero_intro_a_02"
			},
			dialogue_animations = {
				[1.0] = "dialogue_talk",
				[2.0] = "dialogue_talk"
			},
			face_animations = {
				[1.0] = "face_neutral",
				[2.0] = "face_neutral"
			},
			localization_strings = {
				[1.0] = "pwh_ground_zero_intro_a_01",
				[2.0] = "pwh_ground_zero_intro_a_02"
			},
			randomize_indexes = {}
		},
		pwh_level_ground_zero_draw_bridge = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "witch_hunter_ground_zero",
			category = "story_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwh_level_ground_zero_draw_bridge_01",
				"pwh_level_ground_zero_draw_bridge_02",
				"pwh_level_ground_zero_draw_bridge_03",
				"pwh_level_ground_zero_draw_bridge_04"
			},
			dialogue_animations = {
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout"
			},
			face_animations = {
				"face_fear",
				"face_fear",
				"face_fear",
				"face_fear"
			},
			localization_strings = {
				"pwh_level_ground_zero_draw_bridge_01",
				"pwh_level_ground_zero_draw_bridge_02",
				"pwh_level_ground_zero_draw_bridge_03",
				"pwh_level_ground_zero_draw_bridge_04"
			},
			randomize_indexes = {}
		},
		pwh_level_ground_zero_complete = {
			sound_events_n = 3,
			randomize_indexes_n = 0,
			face_animations_n = 3,
			database = "witch_hunter_ground_zero",
			category = "player_alerts_boss",
			dialogue_animations_n = 3,
			sound_events = {
				"pwh_level_ground_zero_complete_01",
				"pwh_level_ground_zero_complete_02",
				"pwh_level_ground_zero_complete_03"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_neutral",
				"face_neutral",
				"face_neutral"
			},
			localization_strings = {
				"pwh_level_ground_zero_complete_01",
				"pwh_level_ground_zero_complete_02",
				"pwh_level_ground_zero_complete_03"
			},
			randomize_indexes = {}
		},
		pwh_level_ground_zero_corruption_everywhere = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "witch_hunter_ground_zero",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwh_level_ground_zero_corruption_everywhere_01",
				"pwh_level_ground_zero_corruption_everywhere_02",
				"pwh_level_ground_zero_corruption_everywhere_03",
				"pwh_level_ground_zero_corruption_everywhere_04"
			},
			dialogue_animations = {
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout"
			},
			face_animations = {
				"face_angry",
				"face_angry",
				"face_angry",
				"face_angry"
			},
			localization_strings = {
				"pwh_level_ground_zero_corruption_everywhere_01",
				"pwh_level_ground_zero_corruption_everywhere_02",
				"pwh_level_ground_zero_corruption_everywhere_03",
				"pwh_level_ground_zero_corruption_everywhere_04"
			},
			randomize_indexes = {}
		},
		pwh_level_ground_zero_smell = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "witch_hunter_ground_zero",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwh_level_ground_zero_smell_01",
				"pwh_level_ground_zero_smell_02",
				"pwh_level_ground_zero_smell_03",
				"pwh_level_ground_zero_smell_04"
			},
			dialogue_animations = {
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout",
				"dialogue_shout"
			},
			face_animations = {
				"face_fear",
				"face_fear",
				"face_fear",
				"face_fear"
			},
			localization_strings = {
				"pwh_level_ground_zero_smell_01",
				"pwh_level_ground_zero_smell_02",
				"pwh_level_ground_zero_smell_03",
				"pwh_level_ground_zero_smell_04"
			},
			randomize_indexes = {}
		}
	})

	return 
end

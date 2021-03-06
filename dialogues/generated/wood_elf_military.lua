return function ()
	define_rule({
		name = "pwe_level_helmgart_military_empty_town",
		response = "pwe_level_helmgart_military_empty_town",
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
				"helmgart_military_empty_town"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"enemies_close",
				OP.EQ,
				0
			},
			{
				"faction_memory",
				"time_since_helmgart_military_empty_town",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"time_since_helmgart_military_empty_town",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwe_level_helmgart_military_fort_help",
		response = "pwe_level_helmgart_military_fort_help",
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
				"helmgart_military_fort_help"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"enemies_close",
				OP.EQ,
				0
			},
			{
				"faction_memory",
				"time_since_helmgart_military_fort_help",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"time_since_helmgart_military_fort_help",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwe_level_helmgart_military_fort_entrance",
		response = "pwe_level_helmgart_military_fort_entrance",
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
				"helmgart_military_fort_entrance"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"enemies_close",
				OP.EQ,
				0
			},
			{
				"faction_memory",
				"time_since_helmgart_military_fort_entrance",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"time_since_helmgart_military_fort_entrance",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwe_level_helmgart_military_fort_massacre",
		response = "pwe_level_helmgart_military_fort_massacre",
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
				"helmgart_military_fort_massacre"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"enemies_close",
				OP.EQ,
				0
			},
			{
				"faction_memory",
				"time_since_helmgart_military_fort_massacre",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"time_since_helmgart_military_fort_massacre",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwe_level_helmgart_military_fort_elevator",
		response = "pwe_level_helmgart_military_fort_elevator",
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
				"helmgart_military_fort_elevator"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"wood_elf"
			},
			{
				"faction_memory",
				"time_since_helmgart_military_fort_elevator",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"time_since_helmgart_military_fort_elevator",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwe_level_helmgart_military_armoury",
		response = "pwe_level_helmgart_military_armoury",
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
				"helmgart_military_armoury"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"enemies_close",
				OP.EQ,
				0
			},
			{
				"faction_memory",
				"time_since_helmgart_military_armoury",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"time_since_helmgart_military_armoury",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwe_level_helmgart_military_portcullis",
		response = "pwe_level_helmgart_military_portcullis",
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
				"helmgart_military_portcullis"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"wood_elf"
			},
			{
				"faction_memory",
				"time_since_helmgart_military_portcullis",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"time_since_helmgart_military_portcullis",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwe_level_helmgart_military_courtyard_event",
		response = "pwe_level_helmgart_military_courtyard_event",
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
				"helmgart_military_courtyard_event"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"wood_elf"
			},
			{
				"faction_memory",
				"time_since_helmgart_military_courtyard_event",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"time_since_helmgart_military_courtyard_event",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwe_level_helmgart_military_axebite_pass_vista",
		response = "pwe_level_helmgart_military_axebite_pass_vista",
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
				"helmgart_military_axebite_pass_vista"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"enemies_close",
				OP.EQ,
				0
			},
			{
				"faction_memory",
				"time_since_helmgart_military_axebite_pass_vista",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"time_since_helmgart_military_axebite_pass_vista",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwe_level_helmgart_military_helmgart_vista",
		response = "pwe_level_helmgart_military_helmgart_vista",
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
				"helmgart_military_helmgart_vista"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"enemies_close",
				OP.EQ,
				0
			},
			{
				"faction_memory",
				"time_since_helmgart_military_helmgart_vista",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"time_since_helmgart_military_helmgart_vista",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwe_level_helmgart_military_locked_portcullis",
		response = "pwe_level_helmgart_military_locked_portcullis",
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
				"helmgart_military_locked_portcullis"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"wood_elf"
			},
			{
				"faction_memory",
				"time_since_helmgart_military_locked_portcullis",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"time_since_helmgart_military_locked_portcullis",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwe_level_helmgart_military_turn_cannon",
		response = "pwe_level_helmgart_military_turn_cannon",
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
				"helmgart_military_turn_cannon"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"wood_elf"
			},
			{
				"faction_memory",
				"time_since_helmgart_military_turn_cannon",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"time_since_helmgart_military_turn_cannon",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwe_level_helmgart_military_fire_cannon",
		response = "pwe_level_helmgart_military_fire_cannon",
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
				"helmgart_military_fire_cannon"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"wood_elf"
			},
			{
				"faction_memory",
				"time_since_helmgart_military_fire_cannon",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"time_since_helmgart_military_fire_cannon",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwe_level_helmgart_military_oops",
		response = "pwe_level_helmgart_military_oops",
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
				"helmgart_military_oops"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"wood_elf"
			},
			{
				"faction_memory",
				"time_since_helmgart_military_oops",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"time_since_helmgart_military_oops",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwe_level_helmgart_military_temple_ahead",
		response = "pwe_level_helmgart_military_temple_ahead",
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
				"helmgart_military_temple_ahead"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"wood_elf"
			},
			{
				"faction_memory",
				"time_since_helmgart_military_temple_ahead",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"time_since_helmgart_military_temple_ahead",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwe_level_helmgart_military_pilgrim_path",
		response = "pwe_level_helmgart_military_pilgrim_path",
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
				"helmgart_military_pilgrim_path"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"enemies_close",
				OP.EQ,
				0
			},
			{
				"faction_memory",
				"time_since_helmgart_military_pilgrim_path",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"time_since_helmgart_military_pilgrim_path",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwe_level_helmgart_military_arriving_temple",
		response = "pwe_level_helmgart_military_arriving_temple",
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
				"helmgart_military_arriving_temple"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"wood_elf"
			},
			{
				"faction_memory",
				"time_since_helmgart_military_arriving_temple",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"time_since_helmgart_military_arriving_temple",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwe_level_helmgart_military_prepare",
		response = "pwe_level_helmgart_military_prepare",
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
				"helmgart_military_prepare"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"wood_elf"
			},
			{
				"faction_memory",
				"time_since_helmgart_military_prepare",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"time_since_helmgart_military_prepare",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwe_level_helmgart_military_ring_bell",
		response = "pwe_level_helmgart_military_ring_bell",
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
				"helmgart_military_ring_bell"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"wood_elf"
			},
			{
				"faction_memory",
				"time_since_helmgart_military_ring_bell",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"time_since_helmgart_military_ring_bell",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwe_level_helmgart_military_they_are_coming",
		response = "pwe_level_helmgart_military_they_are_coming",
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
				"helmgart_military_they_are_coming"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"wood_elf"
			},
			{
				"faction_memory",
				"time_since_helmgart_military_they_are_coming",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"time_since_helmgart_military_they_are_coming",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwe_level_helmgart_military_halfway_through_horde",
		response = "pwe_level_helmgart_military_halfway_through_horde",
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
				"helmgart_military_halfway_through_horde"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"wood_elf"
			},
			{
				"faction_memory",
				"time_since_helmgart_military_halfway_through_horde",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"time_since_helmgart_military_halfway_through_horde",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwe_level_helmgart_military_spooky_temple",
		response = "pwe_level_helmgart_military_spooky_temple",
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
				"helmgart_military_spooky_temple"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"wood_elf"
			},
			{
				"faction_memory",
				"time_since_helmgart_military_spooky_temple",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"time_since_helmgart_military_spooky_temple",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwe_level_helmgart_military_door_opens",
		response = "pwe_level_helmgart_military_door_opens",
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
				"helmgart_military_door_opens"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"wood_elf"
			},
			{
				"faction_memory",
				"time_since_helmgart_military_door_opens",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"time_since_helmgart_military_door_opens",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwe_level_helmgart_military_time_to_leave",
		response = "pwe_level_helmgart_military_time_to_leave",
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
				"helmgart_military_time_to_leave"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"wood_elf"
			},
			{
				"faction_memory",
				"time_since_helmgart_military_time_to_leave",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"time_since_helmgart_military_time_to_leave",
				OP.ADD,
				1
			}
		}
	})
	define_rule({
		name = "pwe_level_helmgart_military_spotting_portal",
		response = "pwe_level_helmgart_military_spotting_portal",
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
				"helmgart_military_spotting_portal"
			},
			{
				"query_context",
				"source_name",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"player_profile",
				OP.EQ,
				"wood_elf"
			},
			{
				"user_context",
				"enemies_close",
				OP.EQ,
				0
			},
			{
				"faction_memory",
				"time_since_helmgart_military_spotting_portal",
				OP.EQ,
				0
			}
		},
		on_done = {
			{
				"faction_memory",
				"time_since_helmgart_military_spotting_portal",
				OP.ADD,
				1
			}
		}
	})
	add_dialogues({
		pwe_level_helmgart_military_courtyard_event = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "wood_elf_military",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwe_level_helmgart_military_courtyard_event_01",
				"pwe_level_helmgart_military_courtyard_event_02",
				"pwe_level_helmgart_military_courtyard_event_03",
				"pwe_level_helmgart_military_courtyard_event_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_concerned",
				"face_concerned",
				"face_concerned",
				"face_concerned"
			},
			localization_strings = {
				"pwe_level_helmgart_military_courtyard_event_01",
				"pwe_level_helmgart_military_courtyard_event_02",
				"pwe_level_helmgart_military_courtyard_event_03",
				"pwe_level_helmgart_military_courtyard_event_04"
			},
			randomize_indexes = {}
		},
		pwe_level_helmgart_military_prepare = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "wood_elf_military",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwe_level_helmgart_military_prepare_01",
				"pwe_level_helmgart_military_prepare_02",
				"pwe_level_helmgart_military_prepare_03",
				"pwe_level_helmgart_military_prepare_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_concerned",
				"face_concerned",
				"face_concerned",
				"face_concerned"
			},
			localization_strings = {
				"pwe_level_helmgart_military_prepare_01",
				"pwe_level_helmgart_military_prepare_02",
				"pwe_level_helmgart_military_prepare_03",
				"pwe_level_helmgart_military_prepare_04"
			},
			randomize_indexes = {}
		},
		pwe_level_helmgart_military_axebite_pass_vista = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "wood_elf_military",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwe_level_helmgart_military_axebite_pass_vista_01",
				"pwe_level_helmgart_military_axebite_pass_vista_02",
				"pwe_level_helmgart_military_axebite_pass_vista_03",
				"pwe_level_helmgart_military_axebite_pass_vista_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_concerned",
				"face_concerned",
				"face_concerned",
				"face_concerned"
			},
			localization_strings = {
				"pwe_level_helmgart_military_axebite_pass_vista_01",
				"pwe_level_helmgart_military_axebite_pass_vista_02",
				"pwe_level_helmgart_military_axebite_pass_vista_03",
				"pwe_level_helmgart_military_axebite_pass_vista_04"
			},
			randomize_indexes = {}
		},
		pwe_level_helmgart_military_locked_portcullis = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "wood_elf_military",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwe_level_helmgart_military_locked_portcullis_01",
				"pwe_level_helmgart_military_locked_portcullis_02",
				"pwe_level_helmgart_military_locked_portcullis_03",
				"pwe_level_helmgart_military_locked_portcullis_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_concerned",
				"face_concerned",
				"face_concerned",
				"face_concerned"
			},
			localization_strings = {
				"pwe_level_helmgart_military_locked_portcullis_01",
				"pwe_level_helmgart_military_locked_portcullis_02",
				"pwe_level_helmgart_military_locked_portcullis_03",
				"pwe_level_helmgart_military_locked_portcullis_04"
			},
			randomize_indexes = {}
		},
		pwe_level_helmgart_military_arriving_temple = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "wood_elf_military",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwe_level_helmgart_military_arriving_temple_01",
				"pwe_level_helmgart_military_arriving_temple_02",
				"pwe_level_helmgart_military_arriving_temple_03",
				"pwe_level_helmgart_military_arriving_temple_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_concerned",
				"face_concerned",
				"face_concerned",
				"face_concerned"
			},
			localization_strings = {
				"pwe_level_helmgart_military_arriving_temple_01",
				"pwe_level_helmgart_military_arriving_temple_02",
				"pwe_level_helmgart_military_arriving_temple_03",
				"pwe_level_helmgart_military_arriving_temple_04"
			},
			randomize_indexes = {}
		},
		pwe_level_helmgart_military_fort_entrance = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "wood_elf_military",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwe_level_helmgart_military_fort_entrance_01",
				"pwe_level_helmgart_military_fort_entrance_02",
				"pwe_level_helmgart_military_fort_entrance_03",
				"pwe_level_helmgart_military_fort_entrance_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_concerned",
				"face_concerned",
				"face_concerned",
				"face_concerned"
			},
			localization_strings = {
				"pwe_level_helmgart_military_fort_entrance_01",
				"pwe_level_helmgart_military_fort_entrance_02",
				"pwe_level_helmgart_military_fort_entrance_03",
				"pwe_level_helmgart_military_fort_entrance_04"
			},
			randomize_indexes = {}
		},
		pwe_level_helmgart_military_fire_cannon = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "wood_elf_military",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwe_level_helmgart_military_fire_cannon_01",
				"pwe_level_helmgart_military_fire_cannon_02",
				"pwe_level_helmgart_military_fire_cannon_03",
				"pwe_level_helmgart_military_fire_cannon_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_concerned",
				"face_concerned",
				"face_concerned",
				"face_concerned"
			},
			localization_strings = {
				"pwe_level_helmgart_military_fire_cannon_01",
				"pwe_level_helmgart_military_fire_cannon_02",
				"pwe_level_helmgart_military_fire_cannon_03",
				"pwe_level_helmgart_military_fire_cannon_04"
			},
			randomize_indexes = {}
		},
		pwe_level_helmgart_military_helmgart_vista = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "wood_elf_military",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwe_level_helmgart_military_helmgart_vista_01",
				"pwe_level_helmgart_military_helmgart_vista_02",
				"pwe_level_helmgart_military_helmgart_vista_03",
				"pwe_level_helmgart_military_helmgart_vista_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_concerned",
				"face_concerned",
				"face_concerned",
				"face_concerned"
			},
			localization_strings = {
				"pwe_level_helmgart_military_helmgart_vista_01",
				"pwe_level_helmgart_military_helmgart_vista_02",
				"pwe_level_helmgart_military_helmgart_vista_03",
				"pwe_level_helmgart_military_helmgart_vista_04"
			},
			randomize_indexes = {}
		},
		pwe_level_helmgart_military_fort_elevator = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "wood_elf_military",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwe_level_helmgart_military_fort_elevator_01",
				"pwe_level_helmgart_military_fort_elevator_02",
				"pwe_level_helmgart_military_fort_elevator_03",
				"pwe_level_helmgart_military_fort_elevator_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_concerned",
				"face_concerned",
				"face_concerned",
				"face_concerned"
			},
			localization_strings = {
				"pwe_level_helmgart_military_fort_elevator_01",
				"pwe_level_helmgart_military_fort_elevator_02",
				"pwe_level_helmgart_military_fort_elevator_03",
				"pwe_level_helmgart_military_fort_elevator_04"
			},
			randomize_indexes = {}
		},
		pwe_level_helmgart_military_door_opens = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "wood_elf_military",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwe_level_helmgart_military_door_opens_01",
				"pwe_level_helmgart_military_door_opens_02",
				"pwe_level_helmgart_military_door_opens_03",
				"pwe_level_helmgart_military_door_opens_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_concerned",
				"face_concerned",
				"face_concerned",
				"face_concerned"
			},
			localization_strings = {
				"pwe_level_helmgart_military_door_opens_01",
				"pwe_level_helmgart_military_door_opens_02",
				"pwe_level_helmgart_military_door_opens_03",
				"pwe_level_helmgart_military_door_opens_04"
			},
			randomize_indexes = {}
		},
		pwe_level_helmgart_military_pilgrim_path = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "wood_elf_military",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwe_level_helmgart_military_pilgrim_path_01",
				"pwe_level_helmgart_military_pilgrim_path_02",
				"pwe_level_helmgart_military_pilgrim_path_03",
				"pwe_level_helmgart_military_pilgrim_path_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_concerned",
				"face_concerned",
				"face_concerned",
				"face_concerned"
			},
			localization_strings = {
				"pwe_level_helmgart_military_pilgrim_path_01",
				"pwe_level_helmgart_military_pilgrim_path_02",
				"pwe_level_helmgart_military_pilgrim_path_03",
				"pwe_level_helmgart_military_pilgrim_path_04"
			},
			randomize_indexes = {}
		},
		pwe_level_helmgart_military_fort_massacre = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "wood_elf_military",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwe_level_helmgart_military_fort_massacre_01",
				"pwe_level_helmgart_military_fort_massacre_02",
				"pwe_level_helmgart_military_fort_massacre_03",
				"pwe_level_helmgart_military_fort_massacre_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_concerned",
				"face_concerned",
				"face_concerned",
				"face_concerned"
			},
			localization_strings = {
				"pwe_level_helmgart_military_fort_massacre_01",
				"pwe_level_helmgart_military_fort_massacre_02",
				"pwe_level_helmgart_military_fort_massacre_03",
				"pwe_level_helmgart_military_fort_massacre_04"
			},
			randomize_indexes = {}
		},
		pwe_level_helmgart_military_time_to_leave = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "wood_elf_military",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwe_level_helmgart_military_time_to_leave_01",
				"pwe_level_helmgart_military_time_to_leave_02",
				"pwe_level_helmgart_military_time_to_leave_03",
				"pwe_level_helmgart_military_time_to_leave_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_concerned",
				"face_concerned",
				"face_concerned",
				"face_concerned"
			},
			localization_strings = {
				"pwe_level_helmgart_military_time_to_leave_01",
				"pwe_level_helmgart_military_time_to_leave_02",
				"pwe_level_helmgart_military_time_to_leave_03",
				"pwe_level_helmgart_military_time_to_leave_04"
			},
			randomize_indexes = {}
		},
		pwe_level_helmgart_military_halfway_through_horde = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "wood_elf_military",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwe_level_helmgart_military_halfway_through_horde_01",
				"pwe_level_helmgart_military_halfway_through_horde_02",
				"pwe_level_helmgart_military_halfway_through_horde_03",
				"pwe_level_helmgart_military_halfway_through_horde_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_concerned",
				"face_concerned",
				"face_concerned",
				"face_concerned"
			},
			localization_strings = {
				"pwe_level_helmgart_military_halfway_through_horde_01",
				"pwe_level_helmgart_military_halfway_through_horde_02",
				"pwe_level_helmgart_military_halfway_through_horde_03",
				"pwe_level_helmgart_military_halfway_through_horde_04"
			},
			randomize_indexes = {}
		},
		pwe_level_helmgart_military_portcullis = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "wood_elf_military",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwe_level_helmgart_military_portcullis_01",
				"pwe_level_helmgart_military_portcullis_02",
				"pwe_level_helmgart_military_portcullis_03",
				"pwe_level_helmgart_military_portcullis_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_concerned",
				"face_concerned",
				"face_concerned",
				"face_concerned"
			},
			localization_strings = {
				"pwe_level_helmgart_military_portcullis_01",
				"pwe_level_helmgart_military_portcullis_02",
				"pwe_level_helmgart_military_portcullis_03",
				"pwe_level_helmgart_military_portcullis_04"
			},
			randomize_indexes = {}
		},
		pwe_level_helmgart_military_spotting_portal = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "wood_elf_military",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwe_level_helmgart_military_spotting_portal_01",
				"pwe_level_helmgart_military_spotting_portal_02",
				"pwe_level_helmgart_military_spotting_portal_03",
				"pwe_level_helmgart_military_spotting_portal_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_concerned",
				"face_concerned",
				"face_concerned",
				"face_concerned"
			},
			localization_strings = {
				"pwe_level_helmgart_military_spotting_portal_01",
				"pwe_level_helmgart_military_spotting_portal_02",
				"pwe_level_helmgart_military_spotting_portal_03",
				"pwe_level_helmgart_military_spotting_portal_04"
			},
			randomize_indexes = {}
		},
		pwe_level_helmgart_military_temple_ahead = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "wood_elf_military",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwe_level_helmgart_military_temple_ahead_01",
				"pwe_level_helmgart_military_temple_ahead_02",
				"pwe_level_helmgart_military_temple_ahead_03",
				"pwe_level_helmgart_military_temple_ahead_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_concerned",
				"face_concerned",
				"face_concerned",
				"face_concerned"
			},
			localization_strings = {
				"pwe_level_helmgart_military_temple_ahead_01",
				"pwe_level_helmgart_military_temple_ahead_02",
				"pwe_level_helmgart_military_temple_ahead_03",
				"pwe_level_helmgart_military_temple_ahead_04"
			},
			randomize_indexes = {}
		},
		pwe_level_helmgart_military_empty_town = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "wood_elf_military",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwe_level_helmgart_military_empty_town_01",
				"pwe_level_helmgart_military_empty_town_02",
				"pwe_level_helmgart_military_empty_town_03",
				"pwe_level_helmgart_military_empty_town_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_concerned",
				"face_concerned",
				"face_concerned",
				"face_concerned"
			},
			localization_strings = {
				"pwe_level_helmgart_military_empty_town_01",
				"pwe_level_helmgart_military_empty_town_02",
				"pwe_level_helmgart_military_empty_town_03",
				"pwe_level_helmgart_military_empty_town_04"
			},
			randomize_indexes = {}
		},
		pwe_level_helmgart_military_they_are_coming = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "wood_elf_military",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwe_level_helmgart_military_they_are_coming_01",
				"pwe_level_helmgart_military_they_are_coming_02",
				"pwe_level_helmgart_military_they_are_coming_03",
				"pwe_level_helmgart_military_they_are_coming_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_concerned",
				"face_concerned",
				"face_concerned",
				"face_concerned"
			},
			localization_strings = {
				"pwe_level_helmgart_military_they_are_coming_01",
				"pwe_level_helmgart_military_they_are_coming_02",
				"pwe_level_helmgart_military_they_are_coming_03",
				"pwe_level_helmgart_military_they_are_coming_04"
			},
			randomize_indexes = {}
		},
		pwe_level_helmgart_military_oops = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "wood_elf_military",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwe_level_helmgart_military_oops_01",
				"pwe_level_helmgart_military_oops_02",
				"pwe_level_helmgart_military_oops_03",
				"pwe_level_helmgart_military_oops_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_concerned",
				"face_concerned",
				"face_concerned",
				"face_concerned"
			},
			localization_strings = {
				"pwe_level_helmgart_military_oops_01",
				"pwe_level_helmgart_military_oops_02",
				"pwe_level_helmgart_military_oops_03",
				"pwe_level_helmgart_military_oops_04"
			},
			randomize_indexes = {}
		},
		pwe_level_helmgart_military_ring_bell = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "wood_elf_military",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwe_level_helmgart_military_ring_bell_01",
				"pwe_level_helmgart_military_ring_bell_02",
				"pwe_level_helmgart_military_ring_bell_03",
				"pwe_level_helmgart_military_ring_bell_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_concerned",
				"face_concerned",
				"face_concerned",
				"face_concerned"
			},
			localization_strings = {
				"pwe_level_helmgart_military_ring_bell_01",
				"pwe_level_helmgart_military_ring_bell_02",
				"pwe_level_helmgart_military_ring_bell_03",
				"pwe_level_helmgart_military_ring_bell_04"
			},
			randomize_indexes = {}
		},
		pwe_level_helmgart_military_armoury = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "wood_elf_military",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwe_level_helmgart_military_armoury_01",
				"pwe_level_helmgart_military_armoury_02",
				"pwe_level_helmgart_military_armoury_03",
				"pwe_level_helmgart_military_armoury_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_concerned",
				"face_concerned",
				"face_concerned",
				"face_concerned"
			},
			localization_strings = {
				"pwe_level_helmgart_military_armoury_01",
				"pwe_level_helmgart_military_armoury_02",
				"pwe_level_helmgart_military_armoury_03",
				"pwe_level_helmgart_military_armoury_04"
			},
			randomize_indexes = {}
		},
		pwe_level_helmgart_military_spooky_temple = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "wood_elf_military",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwe_level_helmgart_military_spooky_temple_01",
				"pwe_level_helmgart_military_spooky_temple_02",
				"pwe_level_helmgart_military_spooky_temple_03",
				"pwe_level_helmgart_military_spooky_temple_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_concerned",
				"face_concerned",
				"face_concerned",
				"face_concerned"
			},
			localization_strings = {
				"pwe_level_helmgart_military_spooky_temple_01",
				"pwe_level_helmgart_military_spooky_temple_02",
				"pwe_level_helmgart_military_spooky_temple_03",
				"pwe_level_helmgart_military_spooky_temple_04"
			},
			randomize_indexes = {}
		},
		pwe_level_helmgart_military_fort_help = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "wood_elf_military",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwe_level_helmgart_military_fort_help_01",
				"pwe_level_helmgart_military_fort_help_02",
				"pwe_level_helmgart_military_fort_help_03",
				"pwe_level_helmgart_military_fort_help_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_concerned",
				"face_concerned",
				"face_concerned",
				"face_concerned"
			},
			localization_strings = {
				"pwe_level_helmgart_military_fort_help_01",
				"pwe_level_helmgart_military_fort_help_02",
				"pwe_level_helmgart_military_fort_help_03",
				"pwe_level_helmgart_military_fort_help_04"
			},
			randomize_indexes = {}
		},
		pwe_level_helmgart_military_turn_cannon = {
			sound_events_n = 4,
			randomize_indexes_n = 0,
			face_animations_n = 4,
			database = "wood_elf_military",
			category = "level_talk",
			dialogue_animations_n = 4,
			sound_events = {
				"pwe_level_helmgart_military_turn_cannon_01",
				"pwe_level_helmgart_military_turn_cannon_02",
				"pwe_level_helmgart_military_turn_cannon_03",
				"pwe_level_helmgart_military_turn_cannon_04"
			},
			dialogue_animations = {
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk",
				"dialogue_talk"
			},
			face_animations = {
				"face_concerned",
				"face_concerned",
				"face_concerned",
				"face_concerned"
			},
			localization_strings = {
				"pwe_level_helmgart_military_turn_cannon_01",
				"pwe_level_helmgart_military_turn_cannon_02",
				"pwe_level_helmgart_military_turn_cannon_03",
				"pwe_level_helmgart_military_turn_cannon_04"
			},
			randomize_indexes = {}
		}
	})

	return 
end

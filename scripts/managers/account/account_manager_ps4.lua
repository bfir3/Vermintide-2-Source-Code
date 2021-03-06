require("scripts/managers/account/script_web_api_psn")
require("scripts/utils/base64")
require("scripts/network/ps_restrictions")
require("scripts/network/script_tss_token")
require("scripts/managers/matchmaking/matchmaking_regions")

local PresenceSet = require("scripts/settings/presence_set")
AccountManager = class(AccountManager)
AccountManager.VERSION = "ps4"

local function dprint(...)
	print("[AccountManager] ", ...)

	return 
end

local FETCH_FRIEND_TIME = 12
local FETCH_FRIEND_NUM = 500
AccountManager.init = function (self)
	self.fetch_user_data(self)

	self._web_api = ScriptWebApiPsn:new()
	self._initial_user_id = PS4.initial_user_id()

	Trophies.create_context(self._initial_user_id)

	self._room_state = nil
	self._current_room = nil
	self._session = nil
	self._has_presence_game_data = false
	self._np_title_id = PS4.title_id()
	self._requesting_np_title_id = false
	self._ps_restrictions = PSRestrictions:new()
	self._dialog_open = false
	self._realtime_multiplay_states = {}
	self._psn_client_error = nil
	self._cached_friends = {
		start = 0,
		totalResults = 0,
		size = 0,
		friendList = {}
	}
	self._fetch_friends_data = {
		offset = 0
	}
	self._fetch_friends_timer = FETCH_FRIEND_TIME
	self._fetching_matchmaking_data = false
	self._next_matchmaking_data_fetch = 0

	return 
end
AccountManager.set_level_transition_handler = function (self, level_transition_handler)
	self._level_transition_handler = level_transition_handler

	return 
end
AccountManager.fetch_user_data = function (self)
	self._online_id = PS4.online_id()
	self._np_id = PS4.np_id()

	return 
end
AccountManager.np_title_id = function (self)
	return self._np_title_id
end
AccountManager.initial_user_id = function (self)
	return self._initial_user_id
end
AccountManager.user_id = function (self)
	return self._initial_user_id
end
AccountManager.user_detached = function (self)
	return false
end
AccountManager.active_controller = function (self, user_id)
	return Managers.input:get_most_recent_device()
end
AccountManager.np_id = function (self)
	return self._np_id
end
AccountManager.online_id = function (self)
	return self._online_id
end
AccountManager.add_restriction_user = function (self, user_id)
	self._ps_restrictions:add_user(user_id)

	return 
end
AccountManager.set_current_lobby = function (self, lobby)
	self._current_room = lobby

	return 
end
AccountManager.leaving_game = function (self)
	return 
end
AccountManager.reset = function (self)
	return 
end
AccountManager.destroy = function (self)
	self._web_api:destroy()

	self._web_api = nil

	if self._has_presence_game_data then
		self.delete_presence_game_data(self)
	end

	local session = self._session

	if session then
		if session.is_owner then
			self.delete_session(self)
		else
			self.leave_session(self)
		end
	end

	return 
end
AccountManager.update = function (self, dt)
	self._update_psn_client(self, dt)
	self._aquire_np_title_id(self, dt)
	self._update_psn(self)
	self._notify_plus(self)
	self._update_friends(self, dt)
	self._update_matchmaking_data(self, dt)
	self._web_api:update(dt)
	self._update_profile_dialog(self)

	return 
end
local PSN_CLIENT_READY_TIMEOUT = 20
AccountManager._update_psn_client = function (self, dt)
	if not LobbyInternal.psn_client then
		self._psn_client_error = nil

		return 
	end

	if self._psn_client_error then
		return 
	end

	if not LobbyInternal.client_ready() then
		if LobbyInternal.client_lost_context() then
			self._psn_client_error = "lost_context"
		else
			self._psn_client_timeout_timer = (self._psn_client_timeout_timer or 0) + dt

			if PSN_CLIENT_READY_TIMEOUT < self._psn_client_timeout_timer then
				self._psn_client_error = "ready_timeout"
				self._psn_client_timeout_timer = 0
			end
		end
	else
		self._psn_client_timeout_timer = 0
	end

	return 
end
AccountManager.psn_client_error = function (self)
	return self._psn_client_error
end
AccountManager._aquire_np_title_id = function (self, dt)
	if self._np_title_id then
		return 
	end

	if self._requesting_np_title_id then
		return 
	else
		self._request_np_title_timer = (self._request_np_title_timer and self._request_np_title_timer + dt) or 10

		if 10 <= self._request_np_title_timer then
			self.get_user_presence(self, self._np_id, callback(self, "_cb_presence_aquired"))

			self._requesting_np_title_id = true
			self._request_np_title_timer = 0
		end
	end

	return 
end
AccountManager._update_psn = function (self)
	local current_room = self._current_room
	local previous_room = self._previous_room
	local room_state_current = current_room and current_room.state(current_room)
	local room_state_previous = self._room_state
	local room_joined = false
	local room_left = false

	if current_room ~= previous_room then
		room_joined = room_state_current == PsnRoom.JOINED
		room_left = room_state_previous == PsnRoom.JOINED
	else
		room_joined = room_state_previous ~= PsnRoom.JOINED and room_state_current == PsnRoom.JOINED
		room_left = room_state_previous == PsnRoom.JOINED and room_state_current ~= PsnRoom.JOINED
	end

	self._update_psn_presence(self, room_joined, room_left)
	self._update_psn_session(self, room_joined, room_left)

	self._previous_room = current_room
	self._room_state = room_state_current

	return 
end
AccountManager._update_psn_presence = function (self, room_joined, room_left)
	if room_left then
	end

	if room_joined then
		local room = self._current_room
		local room_id = room.sce_np_room_id(room)

		self.set_presence_game_data(self, room_id)
	end

	return 
end
AccountManager._update_psn_session = function (self, room_joined, room_left)
	local session = self._session

	if room_left and session then
		if session.is_owner then
			self.delete_session(self)
		else
			self.leave_session(self)
		end
	end

	if room_joined then
		local room = self._current_room
		local room_id = room.sce_np_room_id(room)

		if room.lobby_host(room) == Network.peer_id() then
			self.create_session(self, room_id)
		else
			local session_id = room.data(room, "session_id")

			if session_id then
				self.join_session(self, session_id)
			end
		end
	end

	return 
end
AccountManager._notify_plus = function (self)
	local in_session = self._session
	local realtime_multiplay_states = self._realtime_multiplay_states
	local in_tutorial = realtime_multiplay_states.tutorial
	local in_loading_screen = realtime_multiplay_states.loading
	local in_end_screen = realtime_multiplay_states.end_screen
	local in_cinematic = realtime_multiplay_states.cinematic
	local in_pre_game = realtime_multiplay_states.pre_game
	local in_inn = realtime_multiplay_states.inn

	if not in_session then
		return 
	end

	if in_tutorial or in_loading_screen or in_end_screen or in_cinematic or in_pre_game or in_inn then
		return 
	end

	NpCheck.notify_plus(self.user_id(self), NpCheck.REALTIME_MULTIPLAY)

	return 
end
AccountManager._update_friends = function (self, dt)
	self._fetch_friends_timer = self._fetch_friends_timer + dt

	if self._fetching_friends then
		return 
	end

	if FETCH_FRIEND_TIME <= self._fetch_friends_timer then
		self._fetch_friends_timer = 0

		self._fetch_friends(self)
	end

	return 
end
AccountManager.region = function (self)
	return PS4.user_country(self._initial_user_id)
end
AccountManager._update_matchmaking_data = function (self, dt)
	local t = Managers.time:time("main")

	if not self._matchmaking_data and not self._fetching_matchmaking_data and self._next_matchmaking_data_fetch <= t then
		self._fetch_matchmaking_data(self, t)
	end

	return 
end
AccountManager._fetch_matchmaking_data = function (self, t)
	print("FETCHING MATCHMAKING DATA")

	local matchmaking_data_slot = 0
	local token = Tss.get(matchmaking_data_slot)
	local script_token = ScriptTssToken:new(token)

	Managers.token:register_token(script_token, callback(self, "cb_matchmaking_data_fetched"))

	self._fetching_matchmaking_data = true
	self._next_matchmaking_data_fetch = t + 3

	return 
end
AccountManager.cb_matchmaking_data_fetched = function (self, info)
	self._fetching_matchmaking_data = false

	if info.result then
		print("MATCHMAKING DATA FETCHED")
		MatchmakingRegionsHelper.populate_matchmaking_data(info.result)

		self._matchmaking_data = true
	else
		Application.warning(string.format("[AccountManager] Failed fetching matchmaking data"))
	end

	return 
end
AccountManager._fetch_friends = function (self)
	local fetch_friends_data = self._fetch_friends_data
	local offset = fetch_friends_data.offset
	local np_id = self._np_id
	local api_group = "userProfile"
	local path = string.format("/v1/users/%s/friendList?friendStatus=friend&presenceType=primary&presenceDetail=true&fields=onlineId,npId,personalDetail&limit=%s&offset=%s", tostring(np_id), tostring(FETCH_FRIEND_NUM), tostring(offset))
	local method = WebApi.GET
	local content = nil
	local response_callback = callback(self, "cb_fetch_friends", offset, FETCH_FRIEND_NUM)

	self._web_api:send_request(np_id, api_group, path, method, content, response_callback)

	self._fetching_friends = true

	return 
end
AccountManager.cb_fetch_friends = function (self, offset, fetch_friend_num, data)
	self._fetching_friends = false

	if data == nil then
		self._fetch_friends_data.offset = 0

		return 
	end

	local cached_friends = self._cached_friends
	local cached_friend_list = cached_friends.friendList
	local friend_list = data.friendList
	local num_friends = #friend_list

	for i = 1, num_friends, 1 do
		cached_friend_list[offset + i] = friend_list[i]
	end

	cached_friends.totalResults = data.totalResults
	cached_friends.size = #cached_friend_list

	if num_friends == fetch_friend_num then
		self._fetch_friends_data.offset = offset + num_friends
	else
		self._fetch_friends_data.offset = 0
	end

	return 
end
AccountManager.set_realtime_multiplay_state = function (self, state, set)
	self._realtime_multiplay_states[state] = set

	if script_data.debug_psn then
		local value = (set and "true") or "false"

		printf("AccountManager:set_realtime_multiplay_state state:%s set:%s", state, value)
		table.dump(self._realtime_multiplay_states, "realtime_multiplay_states")
	end

	return 
end
AccountManager._update_profile_dialog = function (self)
	if not self._dialog_open then
		return 
	end

	NpProfileDialog.update()

	local status = NpProfileDialog.status()

	if status == NpProfileDialog.FINISHED then
		NpProfileDialog.terminate()

		self._dialog_open = false
	end

	return 
end
AccountManager.current_psn_session = function (self)
	local session = self._session

	return session and session.id
end
AccountManager.all_lobbies_freed = function (self)
	return true
end
AccountManager.has_access = function (self, restriction, user_id)
	local user_id = user_id or self.user_id(self)

	return self._ps_restrictions:has_access(user_id, restriction)
end
AccountManager.has_error = function (self, restriction, user_id)
	local user_id = user_id or self.user_id(self)

	return self._ps_restrictions:has_error(user_id, restriction)
end
AccountManager.restriction_access_fetched = function (self, restriction)
	local user_id = self.user_id(self)

	return self._ps_restrictions:restriction_access_fetched(user_id, restriction)
end
AccountManager.refetch_restriction_access = function (self, user_id, restrictions)
	local user_id = user_id or self.user_id(self)

	self._ps_restrictions:refetch_restriction_access(user_id, restrictions)

	return 
end
AccountManager.show_player_profile = function (self, user_id)
	if self._dialog_open then
		return 
	end

	local own_user_id = self.user_id(self)
	user_id = user_id or self.user_id(self)

	NpProfileDialog.initialize()
	NpProfileDialog.open(own_user_id, user_id)

	self._dialog_open = true

	return 
end
AccountManager.show_player_profile_with_np_id = function (self, np_id)
	if self._dialog_open then
		return 
	end

	local own_user_id = self.user_id(self)
	np_id = np_id or self.np_id(self)

	NpProfileDialog.initialize()
	NpProfileDialog.open_with_np_id(own_user_id, np_id)

	self._dialog_open = true

	return 
end
AccountManager.get_friends = function (self, friends_listy_limit, response_callback)
	response_callback(table.clone(self._cached_friends))

	return 
end
AccountManager.get_user_presence = function (self, np_id, response_callback)
	local own_np_id = self._np_id
	local api_group = "userProfile"
	local path = string.format("/v1/users/%s/presence?type=platform&platform=PS4", tostring(np_id))
	local method = WebApi.GET
	local content = nil

	self._web_api:send_request(own_np_id, api_group, path, method, content, response_callback)

	return 
end
AccountManager.set_presence = function (self, presence, append_string)
	local np_id = self._np_id
	local api_group = "userProfile"
	local path = string.format("/v1/users/%s/presence/gameStatus", tostring(np_id))
	local method = WebApi.PUT
	local content = self._set_presence_status_content(self, presence, append_string)

	self._web_api:send_request(np_id, api_group, path, method, content)

	return 
end
AccountManager.set_presence_game_data = function (self, room_id)
	local np_id = self._np_id
	local api_group = "userProfile"
	local path = string.format("/v1/users/%s/presence/gameData", tostring(np_id))
	local method = WebApi.PUT
	local game_data = to_base64(room_id)
	local content = {
		gameData = game_data
	}

	self._web_api:send_request(np_id, api_group, path, method, content)

	self._has_presence_game_data = true

	return 
end
AccountManager.delete_presence_game_data = function (self)
	local np_id = self._np_id
	local api_group = "userProfile"
	local path = string.format("/v1/users/%s/presence/gameData", tostring(np_id))
	local method = WebApi.DELETE

	self._web_api:send_request(np_id, api_group, path, method)

	self._has_presence_game_data = false

	return 
end
AccountManager.create_session = function (self, room_id)
	assert(room_id, "[AccountManager] Tried to create psn session but parameter \"room_id\" is missing")

	local level_key = self._level_transition_handler and self._level_transition_handler:get_current_level_keys()
	local lock_flag = false

	if level_key and level_key == "tutorial" then
		lock_flag = true
	end

	local np_id = self._np_id
	local session_parameters_table = {
		max_user = 4,
		type = "owner-bind",
		privacy = "public",
		platforms = "[\"PS4\"]",
		lock_flag = lock_flag
	}
	local session_parameters = self._format_session_parameters(self, session_parameters_table)
	local session_image = "/app0/content/session_images/session_image_default.jpg"
	local session_data = room_id
	local changable_session_data = nil

	self._web_api:send_request_create_session(np_id, session_parameters, session_image, session_data, changable_session_data, callback(self, "_cb_session_created"))

	return 
end
AccountManager._cb_session_created = function (self, result)
	if result then
		local session_id = result.sessionId
		self._session = {
			is_owner = true,
			id = session_id
		}
		local room = self._current_room

		if room then
			room.set_data(room, "session_id", session_id)
		end

		local play_together_list = SessionInvitation.play_together_list()

		if play_together_list then
			self.send_session_invitation_multiple(self, play_together_list)
		end
	else
		self._session = nil
	end

	return 
end
AccountManager._cb_presence_aquired = function (self, result)
	if result then
		local presence = result.presence
		local platform_info_list = presence.platformInfoList
		local game_title_info = platform_info_list[1].gameTitleInfo

		if not game_title_info then
			table.dump(platform_info_list, "platform_info_list", 5)
		end

		self._np_title_id = game_title_info.npTitleId
	else
		self._requesting_np_title_id = false
	end

	return 
end
AccountManager.delete_session = function (self)
	local np_id = self._np_id
	local session_id = self._session.id
	local api_group = "sessionInvitation"
	local path = string.format("/v1/sessions/%s", session_id)
	local method = WebApi.DELETE

	self._web_api:send_request(np_id, api_group, path, method)

	self._session = nil

	return 
end
AccountManager.join_session = function (self, session_id)
	local np_id = self._np_id
	local api_group = "sessionInvitation"
	local path = string.format("/v1/sessions/%s/members", tostring(session_id))
	local method = WebApi.POST

	self._web_api:send_request(np_id, api_group, path, method)

	self._session = {
		is_owner = false,
		id = session_id
	}

	return 
end
AccountManager.leave_session = function (self)
	local session_id = self._session.id
	local np_id = self._np_id
	local api_group = "sessionInvitation"
	local path = string.format("/v1/sessions/%s/members/%s", tostring(session_id), tostring(np_id))
	local method = WebApi.DELETE

	self._web_api:send_request(np_id, api_group, path, method)

	self._session = nil

	return 
end
AccountManager.get_session_data = function (self, session_id, response_callback)
	local np_id = self._np_id
	local api_group = "sessionInvitation"
	local path = string.format("/v1/sessions/%s/sessionData", tostring(session_id))
	local method = WebApi.GET
	local content = nil
	local response_format = WebApi.STRING

	self._web_api:send_request(np_id, api_group, path, method, content, response_callback, response_format)

	return 
end
AccountManager.send_session_invitation = function (self, to_online_id)
	local np_id = self._np_id
	local session_id = self._session.id
	local message = Localize("ps4_session_invitation")
	local params = ""
	params = params .. "{\r\n"
	params = params .. "  \"to\":[\r\n"
	params = params .. string.format("    \"%s\"\r\n", to_online_id)
	params = params .. "  ],\r\n"
	params = params .. string.format("  \"message\":\"%s\"\r\n", message)
	params = params .. "}"

	self._web_api:send_request_session_invitation(np_id, params, session_id)

	return 
end
AccountManager.send_session_invitation_multiple = function (self, to_online_ids)
	local np_id = self._np_id
	local session_id = self._session.id
	local message = Localize("ps4_session_invitation")
	local params = ""
	params = params .. "{\r\n"
	params = params .. "  \"to\":[\r\n"

	for i = 1, #to_online_ids, 1 do
		if to_online_ids[i + 1] then
			params = params .. string.format("    \"%s\",\r\n", to_online_ids[i])
		else
			params = params .. string.format("    \"%s\"\r\n", to_online_ids[i])
		end
	end

	params = params .. "  ],\r\n"
	params = params .. string.format("  \"message\":\"%s\"\r\n", message)
	params = params .. "}"

	self._web_api:send_request_session_invitation(np_id, params, session_id)

	return 
end
AccountManager._format_session_parameters = function (self, params)
	local str = ""
	str = str .. "{\r\n"
	str = str .. string.format("  \"sessionType\":%q,\r\n", params.type)
	str = str .. string.format("  \"sessionPrivacy\":%q,\r\n", params.privacy)
	str = str .. string.format("  \"sessionMaxUser\":%s,\r\n", tostring(params.max_user))

	if params.name then
		str = str .. string.format("  \"sessionName\":%q,\r\n", params.name)
	end

	if params.status then
		str = str .. string.format("  \"sessionStatus\":%q,\r\n", params.status)
	end

	str = str .. string.format("  \"availablePlatforms\":%s,\r\n", params.platforms)
	str = str .. string.format("  \"sessionLockFlag\":%s\r\n", (params.lock_flag and "true") or "false")
	str = str .. "}"

	return str
end
AccountManager._set_presence_status_content = function (self, presence, append)
	local append = append
	local presence_data = PresenceSet[presence] or {
		"en"
	}

	if not PresenceSet[presence] then
		Application.error(string.format("[AccountManager:set_presence] \"%s\" could not be found in PresenceSet - defaulting to english", presence))
	end

	local str = ""
	str = str .. "{\r\n"
	str = str .. string.format("  \"gameStatus\":%q,\r\n", Localize(presence .. "_en") .. ((append and " " .. Localize(append)) or ""))
	str = str .. "  \"localizedGameStatus\":[\r\n"

	if presence_data then
		for idx, language in ipairs(presence_data) do
			str = str .. "    {\r\n"
			str = str .. string.format("      \"npLanguage\":%q,\r\n", language)
			str = str .. string.format("      \"gameStatus\":%q\r\n", Localize(presence .. "_" .. language) .. ((append and " " .. Localize(append)) or ""))
			str = str .. ((idx < #presence_data and "    },\r\n") or "    }\r\n")
		end
	end

	str = str .. "  ]\r\n"
	str = str .. "}"

	return str
end

return 

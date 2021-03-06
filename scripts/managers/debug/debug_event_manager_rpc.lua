DebugEventManagerRPC = class(DebugEventManagerRPC)
DebugEventManagerRPC.init = function (self, network_event_delegate)
	self._event_delegate = network_event_delegate

	self._event_delegate:register(self, "rpc_event_manager_event")

	return 
end
DebugEventManagerRPC.rpc_event_manager_event = function (self, peer_id, ...)
	local event_manager = Managers.state.event

	if event_manager then
		event_manager.trigger(event_manager, ...)
	end

	return 
end
DebugEventManagerRPC.destroy = function (self)
	self._event_delegate:unregister(self)

	return 
end

return 

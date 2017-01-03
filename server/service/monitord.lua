local skynet = require "skynet"
require "skynet.manager"
local log = require "logger"

local service_map = {}

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function() end,
	dispatch = function(_, address)
		log.i("[monitor] service exit address" .. skynet.address(address))
		local w = service_map[address]
		if w then
			for watcher in pairs(w) do
				log.i(string.format('[monitor] watcher = %s,exit=%s',
										skynet.address(watcher),
										skynet.address(address)))

				skynet.send(watcher, "lua", "close_service", address)
			end
			service_map[address] = false
		end
	end
}

local function monitor(session, watcher, command, service)
	if command == "WATCH" then
		local w = service_map[service]
		if not w then
			if w == false then
				skynet.ret(skynet.pack(false))
				return
			end
			w = {}
			service_map[service] = w
		end
		w[watcher] = true
		skynet.ret(skynet.pack(true))
		log.e(string.format('[monitor] register %s ok.',skynet.address(service)))
	else
		assert(command == 'start')
		log.i("[monitor] -----monitor start -----")
		skynet.retpack(true)
	end
end


skynet.start(function()
	skynet.register("monitor")
	skynet.dispatch("lua", monitor)
end)
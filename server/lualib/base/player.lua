local state_machine = require "state_machine"
local log = require "logger"
local skynet = "skynet"

local player = {}
function player.new(...)
	local obj = {}
	setmetatable(obj, {__index = player})
	obj:ctor(...)
	return obj
end

local function handler(self, func)
	return function (...)
		return func(self, ...)
	end
end

function player:ctor(agent, user_id, fd)
	self.agent = agent
	self.user_id = assert(user_id)
	self.fd = fd

	self.state = state_machine.new {
		init = "offline",
		events = {
			{name = 'login',  from = 'offline', to = 'active' },
			{name = 'leave',  from = 'active',  to = 'afk'},
			{name = 'resume', from = 'afk',     to = 'active' },
		},
		callbacks = {
			on_login = handler(self, self.on_login),
			on_resume = handler(self, self.on_resume),
			on_leave = handler(self, self.on_leave),
		}
	}
end

function player:is_afk()
	return self.state:is('afk')
end

function player:is_active()
	return self.state:is('active')
end

function player:login(...)
	return self.state:login(...)
end

function player:leave(...)
	return self.state:is(...)
end

function player:resume(...)
	self.state:resume()
end

local function enter_agent(self, fd, gate)
	self.fd = fd
	log.d(string.format("[player] on_resume. fd = %s,gate = %s",fd, gate))
	if fd and gate then
		log.d(string.format("[player] on_resume. REAL_USER RESUME."))
	else
		log.d(string.format('[player] on_resume OFFLINE_USER RESUME.'))
	end
	--skynet.send(self.agent, "lua", "enter", fd, gate)
end 

function player:force_resume(fd, gate)
	self.state.current = 'active'
	enter_agent(self, fd, gate)
end

function player:on_leave(stm, from, to, ...)
	lod.d('[player on_leave.]')
	skynet.send(self.agent, 'lua', 'leave')
	self.fd = nil
end

return player
local Timer = {}

local manager = require("timer_manager")
local log = require "logger"

function Timer.register(precision)
	manager.register(precision)
end

function Timer.remove_all()
	manager.remove_all()
end

function Timer:new(...)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o:ctor(...)

	return o
end

function Timer:ctor(interval, callback, loop, name)
	assert(interval and type(interval) == 'number')
	assert(callback and type(callback) == 'function')

	self.interval = interval
	self.callback = callback
	self.loop = loop

	if not name then
		print(debug.traceback())
	end
	self.name = name or 'noname_timer'
	self.valid = true

	self.now = 0

	manager.add(self)
end

local function on_timer_error(self, err)
	log.e('[Timer] ------- ERROR START ------')
	log.e(string.format('[Timer] -- Timer : %s', self))
	log.e(err)
	log.e(debug.traceback())
	log.e('[Timer] ------- ERROR END ------')
	log.e('[Timer] ------- CLOSE ------')
end

-- dt is delta time
function Timer:update(dt)
	local next_tick = self.now + dt
	if next_tick < self.interval and self.callback then
		self.now = next_tick
	else	
		xpcall(self.callback, function(err)
				on_timer_error(self, err)
			end, dt)
		if self.loop then
			self.now = 0
		else
			self:stop()
		end
	end
end

function Timer:reset()
	self.now = 0
end

function Timer:step_forward(time)
	self.now = self.now + time
end

function Timer:stop()
	self.callback = nil
	self.valid = false

	log.w(string.format('call timer.stop timer is %s', self))

	manager.remove(self)
end


function Timer:__tostring()
	return string.format('Timer %s, valid = %s, interval = %.2f, loop = %s', self.name, self.valid, self.interval, self.loop)
end

------------------------------end of class timer------------------------------

return Timer


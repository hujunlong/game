local skynet = require "skynet"

local mono_timer = {}

function mono_timer.new(...)
	local obj = {}
	setmetatable(obj, {__index = mono_timer})
	obj:ctor(...)
	return obj
end

function mono_timer:ctor(interval, callback, loop, name)
	assert(interval and type(interval) == 'number')
	assert(callback and type(callback) == 'function')
	self.interval = interval > 0 and interval or 0
	self.callback = callback
	self.loop = loop
	self.name = name or "no-name mono timer"
end

-- create a callback function to wrap the user call
local function create_timer_callback(self)
	return function()
		if not self.running then 
			return
		end

		self.callback(self)
		if self.loop then
			self:start()
		end
	end
end

function mono_timer:start()
	self.running = true
	self.start_time = skynet.time()
	self.timer_callback = create_timer_callback(self)

	skynet.timeout(self.interval, self.timer_callback)
end

-- !!! IMPORTANT !!!
-- you must call start before step.
-- the skynet cannot stop or change a timer's callback time.
-- so we have to make a new_timer to step the timer forward.
-- if the user want to step the timer for a period of time, he should conern this
function mono_timer:step(time)
	assert(self.running, 'you must step a running timer.')
	self:stop()

	local old_timer = self:serial()
	local elapsed = math.floor((skynet.time() - self.start_time)*100)
	local new_timer = mono_timer.new(old_timer.interval - elapsed - time, old_timer.callback, old_timer.loop, old_timer.name)
	new_timer:start()
	return new_timer
end

function mono_timer:stop()
	self.running = false
end

function mono_timer:serial()
	return {
		interval = self.interval,
		callback = self.callback,
		loop = self.loop,
		name = self.name
	}
end

return mono_timer
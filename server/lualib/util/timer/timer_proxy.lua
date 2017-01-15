local TimerProxy = {}

local Timer = require "timer"

local timers = {}

function TimerProxy:add_timer(id, time, repeated, func, precision)
	if not id then
		id = Tool:guid()
	end
	local name = 'TimerProxy' .. tostring(id)
	Timer.register(precision)
	local loop = false
	if repeated > 0 or repeated == true then
		loop = true
	end
	local timer = Timer:new(time * 100, func, loop, name)

	timers[id] = timer

	return timer
end

-- step time forward for time, unit of time is [10ms], skynet's minial timer.
function TimerProxy:update_timer(id, time)
	local steps = time * 100

	local timer = assert(timers[id])
	timer:step_forward(steps)
end

function TimerProxy:del_timer(id)
	local timer = timers[id]
	if timer then
		timer:stop()
	end
	timers[id] = nil
end

function TimerProxy:del_all_tiemr()
	for k,v in pairs(timers) do
		v:stop()
	end

	timers = {}
end

return TimerProxy
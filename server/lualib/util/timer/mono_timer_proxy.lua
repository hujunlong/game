local mono_timer_proxy = {}

local mono_timer = require "mono_timer"

local timers = {}

function mono_timer_proxy:add_timer(id, time, repeated, func)
	if not id then
		id = Tool:guid()
	end
	local name = 'mono_timer_proxy_' .. tostring(id)

	local loop = false
	if repeated > 0 or repeated == true then
		loop = true
	end
	local timer = mono_timer.new(time * 100, func, loop, name)

	timers[id] = timer

	timer:start()
	return timer, id
end

-- step time forward for time, unit of time is [10ms], skynet's minial timer.
function mono_timer_proxy:update_timer(id, time)
	local steps = time * 100

	local timer = assert(timers[id])
	local new_timer = timer:step(steps)
	timers[id] = new_timer
end

function mono_timer_proxy:del_timer(id)
	local timer = timers[id]
	if timer then
		timer:stop()
	end
	timers[id] = nil
end

function mono_timer_proxy:del_all_tiemr()
	for k,v in pairs(timers) do
		v:stop()
	end

	timers = {}
end

return mono_timer_proxy
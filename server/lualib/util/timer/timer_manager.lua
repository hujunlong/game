local skynet = require "skynet"
local log = require "logger"

local TimerMananger = {}
-- !!!
-- IMPORTANT: call this in your own service if you want the Timer.
-- we may not want to add every service a timer if we don't need it.
-- !!!
local timers = {}
local total = 0
local reigstered = false
local precision
local tick
local last

local function update(dt)
	for k,v in pairs(timers) do
		if v.valid then
			v:update(dt)
		end
	end
end

-- tick is local
function tick()
	if not last then 
		last = skynet.now()
	end

	local start = skynet.now()
	local dt = start - last
	update(dt)

	local diff = skynet.now() - start
	last = start
	skynet.timeout(precision - diff, tick)
end

function TimerMananger.register(p)
	if reigstered then
		return
	end

	reigstered = true
	precision = p or 100

	tick()
end

-- you must know what you are doing if you call set_recision.
function TimerMananger.set_precision(p)
	precision = p
end

-- if you call this function, the timer will be removed from the agent forever
-- and you may never use the timer again.
function TimerMananger.remove_all()
	local cnt = 0
	local to_remove = {}
	for _, t in pairs(timers) do
		to_remove[#to_remove+1] = t
		cnt = cnt + 1
	end
	log.d("total remove timers")
	log.dr(to_remove)

	for i = 1, #to_remove do
		to_remove[i]:stop()
	end

	log.w(string.format('[TimerMananger] remove %d timers', cnt))

	if next(timers) then
		assert(false, "[TimerMananger] sometimer has not been released? check code.")
	end
	assert(total == 0)
end

-- return the timer id, to s
function TimerMananger.add(t)
	assert(t)

	-- log.w(string.format('[TimerMananger] add = %s', t))
	-- use the timer object(table) as the key
	if not timers[t] then
		timers[t] = t
		total = total + 1
	else
		error(string.format("already add timer %s", t))
	end
end

function TimerMananger.remove(t)
	-- log.i(string.format("[TimerMananger] remove timer %s", t))
	if timers[t] then
		total = total - 1
		timers[t] = nil
	else
		log.w(string.format("timer not exist %s, or time invalid", t))
	end
end

return TimerMananger
local skynet = require "skynet"
require "skynet.manager"
local queue = require "skynet.queue"

local cs = queue()
local cache = {}
local visit_history = {}

local CMD = {}
local hit = 0
local miss = 0

local total_entry = 0
local pool_size

local function visit(key)
	 local h = visit_history[key]
	 if not h then
	 	h = {}
	 	visit_history[key] = h
	 end
	 h.key = key
	 h.time = skynet.time()
end  

function CMD.start(conf)
	pool_size = conf.cache_pool_size or 100
	return true
end

function CMD.load(key)
	return cs(function()
		assert(key)
		local value = cache[key]
		if value then
			visit(key)
			hit = hit + 1
			return value
		else
			miss = miss + 1
			return {}
		end
	end)
end

function CMD.save(key, value)
	cs(function()
		assert(key)
		assert(value)

		if total_entry < pool_size then
			if not cache[key] then
				total_entry = total_entry + 1
			end
			visit(key)
			cache[key] = value
		else
			local tmp = {}
			local i = 1
			for k,v in pairs(visit_history) do
				tmp[i] = v
				i = i + 1
			end
			log.dr(tmp)
			table.sort(tmp, function(a, b)
				return a.time < b.time
			end )

			local cnt = math.floor(pool_size/4)
			for i = 1,cnt do
				local release_key = tmp[i].key
				cache[release_key] = nil
				visit_history[release_key] = nil
			end
			visit(key)
			cache[key] = value
			total_entry = total_entry - cnt
		end
	end)
end

function CMD.debug_info(query)
	if query.option == 'simple' then
		local rate = string.format("hit : %d, miss %d, rate = %.2f\n", hit, miss, (hit+miss) == 0 and 0 or hit/(hit+miss))
		local total_entries = 0
		local keys = {}
		for k,v in pairs(cache) do
			total_entries = total_entries + 1
			if not keys[k] then
				keys[k] = 1
			else
				keys[k] = keys[k] + 1
			end
		end

		return {
			rate = rate,
			total_entries = total_entries,
			keys = keys,
		}
	elseif query.option == 'full' then
		for k, v in pairs(cache) do
			log.d(k)
			log.dir(v)
		end
		if query.id then
			return cache[query.id] or {}
		end
		return {}
	else
		return {}
	end
end

function CMD.close()
	log.w("[data_cache], data_cache has been closed.")
	return true
end

function CMD.exit()
	log.e('[data_cache], exit data_cache.')
	skynet.exit()
end

local function ret(ok, ...)
	assert(ok)
	local n = select("#", ...)
	if ok and n > 0 then
		skynet.retpack(...)
	end
end 

local function error_handler(err)
	 log.e(err)
	 log.e(debug.traceback())
end

skynet.start(function()
	skynet.register("data_cache")
	skynet.dispatch("lua", function(_, _, cmd, ...)
		local f = assert(CMD[cmd])
		ret(xpcall(f, error_handler, ...))
	end)
end)
local skynet = require "skynet"
require "skynet.manager"
local log = require "logger"
local croupier = require "croupier"

local CMD = {}

local croupiers = {}

function CMD.start()
	log.w("[randd] start randd.")
	return true
end

function CMD.close()
	log.w("[randd] close randd.")

	for k,v in pairs(croupiers) do
		skynet.send("database", "lua", "rand", "update", v:tablize())
	end

	return true
end

function CMD.exit()
	skynet.exit()
end

function CMD.rand(id, weight_array)
	local cr = croupiers[id]
	local ret
	if cr then
		ret = cr:deal()
		print('rand, id, ret = ', id, ret)
	else
		local exist, croupier_data = skynet.call('database', "lua", "rand", "find_with_id", id)
		local cr
		if exist then
			cr = croupier.new(croupier_data)
		else
			cr = croupier.new{_id = id, weight_array = weight_array}
		end
		croupiers[id] = cr
		ret = cr:deal()
	end
	return ret
end

skynet.start(function()
	skynet.register("rand")
	skynet.dispatch("lua", function(_, _, cmd, ...)
		local f = assert(CMD[cmd])

		local function ret(ok, ...)
			if ok then
				skynet.retpack(...)
			end
		end 

		local function error_handler(err)
			 log.w(err)
			 log.w(debug.traceback())
		end

		ret(xpcall(f, error_handler, ...))
	end)
end)
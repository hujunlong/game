local skynet = require "skynet"
require "skynet.manager"

local Tool = require "tool"
local httpc = require "http.httpc"
local ip_config = require "ip_config"
local log = require "logger"
local host = ip_config.host
local cjson = require "cjson"

local CMD = {}
local NO_RET = {}

function CMD:send(entry)
	assert(entry and type(entry) == 'table')

	local data = {}
	data.log_id = Tool:objectid_s()
	data.log_data = os.time()
	data.user_id = entry.user_id or "no-user-id"
	data.server_id = "server_id-not-set"
	data.content = entry.content or {}

	local code = httpc.request("POST", ip_config.log_server_host, ip_config.log_server_url, {},
								{["Content-Type"] = "application/json; charset=utf-8"}, json.encode(data))

	if code ~= 200 then
		skynet.error(string.format("error sending log, log_id = %s, log_content = %s",data.log_id, cjson.encode(data)))
	end
	return NO_RET
end

function CMD:send_to_datacenter(data)
	local code = httpc.request("POST", ip_config.log_server_host, ip_config.log_server_url,{},
								{["Content-Type"] = "application/json; charset=utf-8"}, json.encode(data))
	if code ~= 200 then
		skynet.error(string.format("error sending log, log_id = %s, log_content = %s",data.log_id, cjson.encode(data)))
	end
	return NO_RET
end

function CMD:start( ... )
	return true
end

skynet.start(function()
	skynet.register("logclient")
	skynet.dispatch("lua", function(_, _, cmd, ...)
		local f = assert(CMD[cmd])
		log.i('[logclient] dispatch, cmd = '  .. cmd)
		local ok, ret = xpcall(f, function(err)
			skynet.error(err)
		end, ...)

		if ret ~= NO_RET then
			skynet.retpack(ret)
		end
	end)
end)
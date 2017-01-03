local skynet = require "skynet"
local Tool = Tool or require "tool"
local ip_config = require "ip_config"
local config = require "system_config"

local log = {
	prefix = {
		"D",
		"I",
		"W",
		"E",
	}
}

local level 
local extra_info
local user_id

function log.config(conf)
	level = conf.log_level
end

function log.set_extra(extra)
	extra_info = extra
end

function log.set_user_id(id)
	user_id = id
end

function log.get_extra()
	return extra_info or "-"
end

local function write(priority, ...)
	if priority >= level then
		skynet.error(string.format("[%s]", log.get_extra()), ...)
	end
end

function log.d(...)
	write(1, ...)
end

function log.trace(entry)
	entry.user_id = user_id
	skynet.send("logclient","lua","send", entry)
end

function log.send_datacenter(type, data)
	if ip_config.is_debug then return end
	Tool:merge({data, log.server_info(),{time = os.time()}})
	local content = {content = {type = type, data = data}}
	skynet.send("logclient", "lua", "send_to_datacenter", content)
end

function log.record_new_user(data)
	log.send_datacenter("user_regis", data)
end

local SERVER
function log.server_info( )
	if SERVER then return SERVER end
	SERVER = game_cmd:exc_server_cmd("server_info_mgr", "get_info")
	return SERVER
end

function log.dr(root)
	if not root then
		log.w("[log]: attempt to print a empty table.")
		return
	end
	if type(root) ~= "table" then
		log.w(string.format("[log]: attempt to print a table, but it is: %s.",type(root)))
		log.d(root)
	end

	local cache = {[root] = "."}
	local function _dump(t, space, name)
		local temp = {}
		for k, v in pairs(t) do
			local key =  tostring(k)
			if cache[v] then
				table.insert(temp, "+" .. key .. " {" .. cache[v] .. "}")
			elseif type(v) == "table" then
				local new_key = name .. "." .. key
				cache[v] = new_key
				table.insert(temp,"+" .. key .. _dump(v,space .. (next(t,k) and "|" or " " ).. string.rep(" ",#key),new_key))
			else
				table.insert(temp, "+" .. key .. " [" .. tostring(v) .. "]")
			end
		end
		return table.concat(temp, "\n" .. space)
	end
	
	local info =  "\n------------------------------------------------------------------------\n"
	  				.. _dump(root, "","")
	  				.. "\n------------------------------------------------------------------------"
	write(1, info)
end

function log.i(...)
	write(2, ...)
end

function log.w(...)
	write(3, ...)
end

function log.e(...)
	write(4, ...)
end

log.config(config)
return log
local skynet = require "skynet"
local socket = require "socket"
local httpd  = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local  table = table
local string = string
local json = require "cjson"
local log = require "logger"
local http_safty = require "http_safty"

local function response(id, ...)
	local ok, err = httpd.write_response(sockethelper.writefunc(id), ...)
	if not ok then
		skynet.error(string.format("fd = %d, %s"), id, err)
	end
end

local function parse_path(path, id, code)
	-- parse the module
	local matched = string.match(path, "/[%w_]+/[%w_]+")
	if not matched then
		return response(id, code, "ERROR: invalid path")
	end

	local s, e = string.find(path, "/[%w_]+/")
	local module_name = string.sub(path, s+1, e-1)
	if (not module_name) or (string.len(module_name) == 0) then
		return response(id, code, "ERROR: Empty module name")
	end

	if not http_safty.is_valid(module_name) then
		return response(id, code, "ERROR: Invalid module name")
	end

	-- parse the method
	local tmp = string.sub(path, e+1, #path)
	local method = string.sub(tmp, string.find(tmp, "[%w_]+"))

	if (not method) or (string.len(method) == 0) then
		return response(id, code, "ERROR: Empety method")
	end

	local f = require(module_name)[method]

	if not f then
		return response(id, code, "ERROR: Unkwon method " .. method)
	end

	return f
end

skynet.start(function()
	skynet.dispatch("lua", function (_,_,id)
		socket.start(id)
		-- limit request body size to 8192 (you can pass nil to unlimit)
		local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(id), 8192)
		log.i('url = ', url)
		if code then
			if code ~= 200 then
				response(id, code)
			else
				local path, query = urllib.parse(url, id)

				local f = parse_path(path, id, code)
				if f then
					log.i(string.format("[webcatslave] http request:"))
					local request = {}
					request.header = header
					request.body = body
					request.path = path
					request._query = query
					request._body = body
					if query then
						request.query = urllib.parse_query(query)
						local body_query = urllib.parse_query(body)
						if body_query then 
							for k,v in pairs(body_query) do
								request.query[k] = v
							end
						end
					end

					local function resp(t)
						if type(t) == 'string' then
							response(id, code, t)
						elseif type(t) == 'table' then
							response(id, code, json.encode(t))
						else
							log.e(false, "invalid")
							assert(false)
						end
					end

					log.dr(request)
					f(request, resp)
				end
			end
		else
			if url == sockethelper.socket_error then
				skynet.error("socket closed")
			else
				skynet.error(url)
			end
		end
		socket.close(id)
	end)
end)
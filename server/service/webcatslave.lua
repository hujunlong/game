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
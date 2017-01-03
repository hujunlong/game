local skynet = require "skynet"
local socket = require "socket"
local ip_config = require "ip_config"
local web_slave = {}

local log  = require "logger"
skynet.start(function()
	local web_slave = {}
	for i=1, 20 do
		web_slave[i] = skynet.newservice('webcatslave')
	end
	local balance = 1
	local id = socket.listen("0.0.0.0", ip_config.webcat_port)
	log.i("[webcat] Listen web port 8001")

	socket.start(id, function(id, addr)
		log.i(string.format("[webcat] %s connected, pass it to agent :%08x", addr, web_slave[balance]))
		skynet.send(web_slave[balance], "lua", id)
		balance = balance + 1
		if balance >= #web_slave then
			balance = 1
		end
	end)

end)
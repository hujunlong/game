local skynet = require "skynet"
local protoloader = require "protoloader"
local log = require "logger"

skynet.start(function()
	log.i('[protoloader] start the protoloader')
	protoloader.init()
	-- don't call skynet.exit() ,because sproto.core may unload and the global slot become invalid
end)
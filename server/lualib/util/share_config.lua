local sharedata = require "sharedata"
local log = require "logger"

local share_config = {}

function share_config.load(name, data)
	log.i(string.format('[share_config] loading config name = %s.', name))
	sharedata.new(name, data)
end

function share_config.get(config_file_name)
	assert(config_file_name)
	log.i(string.format('[share_config] get [%s].', config_file_name))
	return sharedata.query(config_file_name)
end

function share_config.hot_fix(config_file_name)
	-- body
end

return share_config
local skynet = require "skynet"
require "skynet.manager"
local sprotoloader = require "sprotoloader"
local tool = require "tool"
local ip_config = require "ip_config"
local system_config = require "system_config"
local max_client = 10000

local share_config = require "share_config"
local function load_config()
	require "config_building_details"
	require "config_monsters"
	require "config_quests"
	require "config_researches"

    share_config.load("config_building_details", config_building_details)
	share_config.load("config_monsters", config_monsters)
	share_config.load("config_quests", config_quests)
	share_config.load("config_researches", config_researches)
end

skynet.start(function()
	skynet.uniqueservice("protod")
	load_config()

	skynet.uniqueservice("logclient")
	skynet.call("logclient", "lua", "start")

	skynet.uniqueservice("database")
	skynet.call("database", "lua", "cmd", "start")

	skynet.monitor("monitord")
	skynet.call("monitor", "lua", "start")

	skynet.uniqueservice("randd")
	skynet.call("rand", "lua", "start")

	skynet.uniqueservice("data_cache")
	skynet.call('data_cache', 'lua', 'start', {cache_pool_size = system_config.cache_pool_size})

	skynet.uniqueservice("webcat")
end)

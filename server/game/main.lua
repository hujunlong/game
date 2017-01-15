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

	--local watchdog = skynet.newservice("watchdog")

	local server_info_mgrd = skynet.uniqueservice("server_info_mgrd")
    skynet.call(server_info_mgrd, "lua", 'serverd', 'start')

    local uniond = skynet.uniqueservice("uniond")
    skynet.call(uniond, 'lua', 'uniond', "start")

	--[[ 
    local maild = skynet.uniqueservice("maild")
    skynet.call(maild, 'lua', 'maild', "start")

    local rankd = skynet.uniqueservice("rank")
    skynet.call(rankd, "lua", 'start')

    local wildd = skynet.uniqueservice("wildd")
    skynet.call(wildd, 'lua', 'wildd', "start")

    local chat = skynet.uniqueservice("chat")
    skynet.call(chat, 'lua', 'start')

    local eventd = skynet.uniqueservice("eventd")
    skynet.call(eventd, 'lua', 'eventd', "start")

    local console = skynet.newservice("console")
    skynet.newservice("debug_console",ip_config.debugconsole_port)
--]]
skynet.call("watchdog", "lua", "start_gate", {
        port = ip_config.game_port,
        max_client = max_client,
        nodelay = true,
    })

skynet.send(uniond, "lua", "union", "on_server_start")
skynet.call(wildd, "lua", "map", "on_server_start")

log.w('[main] server has been started. exit the main.lua.')
skynet.exit()


end)

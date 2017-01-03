local skynet = require "skynet"
require "skynet.manager"
require "tool"

local log = require "logger"
local system_config = require "system_config"

local db_config = require "db_config"
local db_account = require "db_account"
local db_user = require "db_user"
local db_mail = require "db_mail"
local db_map = require "db_map"
local db_event = require "db_event"
local db_server = require "db_server_info_mgr"
local db_union = require "db_union"
local db_order = require "db_order"
local db_rand = require "db_rand"
local db_replay = require "db_replay"
local db_gateway = require "db_gateway"

local mongo = require "mongo"
local total_client = system_config.max_db_client
local mongo_client_pool = {}

local config = {
	host = "127.0.0.1",
	port = 27017,
	username = nil,
	passworld = nil,
}

--init some connection when start the server database.
local function init_db_pool( ... )
	for i = 1, total_client do
		local mong_client = mongo.client(config)
		mongo_client_pool[#mongo_client_pool + 1] = mong_client
	end
end

local function close_db_pool()
	for _, client in ipairs(mongo_client_pool) do
		client:disconnect()
	end
	log.w('[database] disconnect all clients.')
end

--a simple connect balance algorithm
--get the first byte of the key, use that as the hash number.
local function get_db(key)
	local hash_num = string.byte(key, 1) + string.byte(key, #key)
	return assert(mongo_client_pool[hash_num % total_client + 1])
end

local function get_collection(collection_name, key)
	assert(string.len(key) > 0, 'invalid collection hash key ' .. key)
	assert(collection_name and type(collection_name) == 'string','invalid collection_name' .. collection_name)

	local db = get_db(key)
	return db[db_config.db_name]:getCollection(collection_name)
end

local Modules = {}
local CMD = {}

function CMD.start()
	return true
end

function CMD.close()
	close_db_pool()
	return true
end

function CMD.exit()
	log.e('[database] exit database.')
	skynet.exit()
end

Modules['cmd'] = CMD

local function register_module(name, dao)
	Modules[name] = dao
	dao.init(get_collection, get_db)
end

skynet.start(function()
	init_db_pool()
	skynet.register('database')

	register_module('account', db_account)
	register_module('user', db_user)
	register_module('mail', db_mail)
	register_module('map', db_map)
	register_module('event', db_event)
	register_module('server', db_server)
	register_module('union', db_union)
	register_module('order', db_order)
	register_module('replay', db_replay)
	register_module('rand', db_rand)
	register_module('gateway', db_gateway)

	db_user.load_user_name()
    db_union.load_name()

	skynet.dispatch("lua", function(_, _, modue_name, command, ...)
		local mod = Modules[modue_name]
		assert(mod, string.format('no database module found for name [%s].',modue_name))

		local cmd = mod[command]
		assert(cmd, type(cmd) == 'function',string.format('no command [%s] found, for module [%s].', command, module))
	
		local function ret(ok, ...)
			local n = select('#', ...)
			if ok and n > 0 then
				skynet.retpack(...)
			end
		end

		-- here we use pcall to raise errors, it's common that make mistakes of access database when develop.
		ret (xpcall(cmd, function(err)
			print(err)
			print(debug.traceback())
		end, ...))
	end)
end)
require "agent_startup"
local skynet = require "skynet"
require "skynet.manager"

local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local protoloader = require "protoloader"
local queue = require "skynet.queue"
local timer = require "timer"
local profile = require "profile"
local log = require "logger"
local system_config = require "system_config"
local replay = require "replay"
local queue = require "skynet.queue"

local watchdog
local host
local send_request

local agent_state = 'close'
local CMD = {}
local REQUEST = {}
local client_fd
local user_id
local gate

local route_handler

local user_replay

-- heartbeat timer for both online and offline user, if the user get no
-- msg from 'client' or 'lua', we will close the agent.
local timer_heartbeat 				
local KEEPALIVE_TIME = 100 * 60 * 2 

local DB_WRITE_INTERVAL = 100 * 60 -- save every 60 seconds.


local cs = queue()

local function heartbeat_reset()
	if agent_state == 'open' then
		timer_heartbeat:reset()
	end
end

local function save(land)
	local user = route_handler:current_user()
	if user then
		log.d('[Agent] save user to database ' .. user.user_name )
		user:save(land)
	else
		log.i('[Agent] user already exit.')
	end
end

local function close_agent(err)
	if agent_state == 'close' then
		log.d('[Agent] agent already closed.')
		return
	end

	agent_state = 'close'

	client_fd = nil
	
	timer.remove_all()
	save(true)

	local user = route_handler:current_user()
	if user then

		local user_handler = route_handler:get_user_handler()
		user_handler:on_agent_close()
		-- save the replay to db
		if user_replay then
			log.d('[agent] save replay for user, user_id = ' .. user_id)
			skynet.send('database', 'lua', 'replay', 'update', user_replay:serialize())
		end
	end
	
	log.i(string.format('[Agent] EXIT Agent [%s]', skynet.address(skynet.self()) ))
	log.i('[agent] CMD.close OUT ' .. user_id)
	if not err then
		skynet.exit()
	else
		skynet.kill(skynet.self())
	end
end

local function timer_agent_timeout()
	if client_fd then
		log.i('[Agent] close the online.. client is timeout. fd = ' .. client_fd)
		skynet.call("watchdog", 'lua', 'close_fd', client_fd)
	else
		log.i(string.format('[Agent] offline agent timeout. auto close it. addr = %d (%s)', skynet.self(), skynet.address(skynet.self())))
		skynet.call("watchdog", 'lua', 'close_service', skynet.self())
	end
end

local function on_agent_error(err)
	log.i('[Agent] ------- ERROR START ------')
	log.i(err)
	log.i(debug.traceback())
	log.i('[Agent] ------- ERROR END ------')
	close_agent(err)
end

local function timer_auto_save()
	save(true)
end

local function request(name, args, response)
	log.w(string.format('[Agent] CLIENT-MSG request = %s', name))
	log.dr(args)

	if user_replay then
		if name ~= 'heartbeat' then
			user_replay:add_action { time = skynet.time(),
									 route = name,
									 option = args, 
									 source = 'client', }
		end
	end

	local f = assert(route_handler[name])
	args = route_handler:refresh_args_from_client(args)
	local r = f(route_handler, args) or {}

	heartbeat_reset()
	if response then
		log.w(string.format("[Agent] CLIENT-MSG response = %s", name))
		return response(r)
	else
		log.w(string.format("[Agent] CLIENT-MSG ERROR, NO RESPONSE = %s", name))
	end
end

local function send_package_fd(fd, pack)
	local package = string.pack(">s2", pack)
	socket.write(fd, package)
end

local function send_package(pack)
	send_package_fd(client_fd, pack)
end

-- push a message to client(fd)
local session = 0
local function push_client_fd(fd, name, args)
	session = session + 1
	local package = send_request(name, args, session)
	send_package_fd(fd, package)
end

local function init_proto()
	host = sprotoloader.load(protoloader.GAME_C2S):host "package"
	send_request = host:attach(sprotoloader.load(protoloader.GAME_S2C))
end

skynet.register_protocol {
		name = "client",
		id = skynet.PTYPE_CLIENT,
		unpack = function (msg, sz)
			return host:dispatch(msg, sz)
		end,
		dispatch = function (_, _, type, ...)
			if type == "REQUEST" then
				local ok, result  = xpcall(request, on_agent_error, ...)
				if ok then
					if result then
						send_package(result)
					end
				else
					skynet.error(result)
				end
			else
				assert(type == "RESPONSE")
				assert(false, "implement this if need.")
			end
		end
	}

local function create_user(user_id, passport)
    local user_handler = route_handler:get_user_handler()
	user_handler:create_user(user_id, passport)
	user_handler:current_user():set_client_info(client_fd, push_client_fd)
	user_handler:on_agent_open()
	log.set_extra(string.format("user_id : %s, user_name %s", user_id, route_handler:current_user().user_name))
	log.set_user_id(user_id)
end

function CMD.start(conf)
	log.d('----agent start----')
	-- loading the building detail
	ConfigBuildingDetail:load()
	ConfigMonster:load()
	ConfigQuest:load()
	ConfigResearch:load()

	client_fd = conf.fd
	user_id = conf.user_id
	watchdog = conf.watchdog
	passport = conf.passport

	agent_state = 'open'
	log.i('[Agent] CMD.start IN ' .. user_id)

	if system_config.enable_replay then
		log.d('[agent] create replay for user, user_id = ' .. user_id)
		user_replay = replay.new(user_id, client_fd ~= nil, skynet.address(skynet.self()))
	end

	route_handler = require("route_handler").new()
	log.d(string.format('[agent] create user user_id = %s, passport = %s', conf.user_id, conf.passport))
	create_user(conf.user_id, conf.passport)

	timer.register()
    timer:new(DB_WRITE_INTERVAL, timer_auto_save, true, 'DB_WRITE_TIMER')
   	timer_heartbeat = timer:new(KEEPALIVE_TIME, timer_agent_timeout, true, 'HEARTBEAT_CHECK_TIMER')
	
	init_proto()
	if conf.gate and client_fd then
		skynet.call(conf.gate, "lua", "forward", client_fd)
		gate = conf.gate
	end

	log.i('[Agent] CMD.start OUT ' .. user_id)

	return true
end

function CMD.enter(fd, new_gate)
	log.i(string.format('[Agent] enter fd = %s, gate = %s', fd, gate))
	if new_gate and new_gate ~= gate then
		gate = new_gate
		log.i(string.format('[Agent] enter reset the gate. gate = %s', gate ))
	end

	if fd then
		client_fd = fd
		skynet.call(gate, "lua", "forward", client_fd)
		local user_handler = route_handler:get_user_handler()
		user_handler:current_user():set_client_info(client_fd, push_client_fd)
	end	
end

function CMD.leave()
	local user_handler = route_handler:get_user_handler()
	client_fd = nil
	local user = user_handler:current_user()
	assert(user)
	user.__can_push = false
	user:set_client_info(nil, push_client_fd)
	log.i(string.format("[Agent] leave user_id = %s, fd = %s", user_id, client_fd))

	save(true)
end

function CMD.exit()
	log.i('[Agent] exit agent ', skynet.address(skynet.self()))
	skynet.exit()
end

function CMD.get_current_user()
	return route_handler:current_user()
end

local function do_cmd(subcmd, ...)
	assert(subcmd)
	local user = route_handler:current_user()
	assert(user)
	log.d(string.format('[Agent] execute user_cmd, cmd = [%s]', subcmd))
	local cmd = user[subcmd]
	assert(cmd)
	return cmd(user, ...)
end

function CMD.user_cmd(subcmd, ...)
	return Tool:clone(do_cmd(subcmd, ...))
end

function CMD.send_user_cmd(subcmd, ...)
	do_cmd(subcmd, ...)
end

function CMD.get_user_info()
	return route_handler:current_user():attributes()
end

-- destroy everything the user registered here.
function CMD.close()
	log.i('[agent] CMD.close IN ' .. user_id)
	close_agent()
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		
		if user_replay then
			user_replay:add_action {
								time = skynet.time(),
								route = command,
								option = table.pack(...), 
								source = 'lua',
			}
		end

		heartbeat_reset()
		local function ret (ok, ...)
			
  			if ok then
  				local n = select("#", ...)
  				if n > 0  then
      				skynet.retpack (...)
      			end
      		else
      			log.w("[Agent Call ERROR:]"..command)
      			skynet.retpack ({})
  			end
		end

		ret (xpcall (f, on_agent_error, ...))
	end)
end)
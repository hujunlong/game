local skynet = require "skynet"
require "skynet.manager"
require "tool"
local log = require "logger"
local queue = require "skynet.queue"
local Token = require "token"
local system_config = require "system_config"
local cjson = require "cjson"
local player_state = require "player"

local CMD = {}
local SOCKET = {}
local gate

local agents = {}
local fd_map = {}
local addr_map = {}
local user_cs = {}

local total_online = 0
local total_offline = 0

local function leave_user(user_id)
	local player = agents[user_id]
	log.d("player and player:can(leave) = " .. tostring(player and player:can("leave")))
	if player and player:can("leave") then
		local fd = player:get_fd()
		if fd then
			log.d(string.format("[watchdog] leave_user clean the fd map, fd = %s", fd))
			fd_map[fd] = nil
		end
		player:leave()
	else
		log.d('[watchdog] user_already leave. user_id = ' .. user_id)
	end
end

local function close_user(user_id)
	local u = agents[user_id]
	if u then
		assert(u.agent)
		agents[user_id] = nil
		addr_map[u.agent] = nil
		user_cs[user_id] = nil

		if u.id then
			fd_map[u.fd] = nil
			log.d(string.format('[watchdog] kick user fd = [%s]',u.fd, user_id))
			skynet.call(gate, "lua", "kick", u.fd)
			total_online = total_online - 1
		else
			total_offline = to - 1
		end

		skynet.send(u.agent, "lua", "close")
	
		log.d('[watchdog] ---- CLOSE_USER LOG START------')
		log.d(string.format('[watchdog] close_user TOTAL QUEUE = %d', Tool:tnums(user_cs)))
		log.d(string.format('[watchdog] user close succeed. user_id = [%s]', user_id))
		log.d('[watchdog]----after close_user --------')
		log.d('[watchdog]---- addr_map -----')
		log.dr(addr_map)
		log.d('[watchdog]---- fd_map -----')
		log.dr(fd_map)
		log.d('[watchdog] ---- CLOSE_USER LOG END------')
	else
		log.d(string.format('[watchdog] user already closed id = %s', user_id))
	end
end 

local function close_user_lock(user_id)
	local cs = user_cs[user_id]
	if cs then
		log.i(string.format('[watchdog] close_user_lock user_id = %s', user_id))
		return cs(close_user, user_id)
	else
		log.i(string.format('[watchdog] close_user_lock user already closed id = %s', user_id))
	end
end

local function get_user(conf, cmd, ...)
	local function proc_get_user(conf)
		local user_id = conf.user_id
		local fd = conf.fd		

		local player = agents[user_id]
		if player then
			if fd then -- the REAL_USER try to login.
				if player:is_active() then
					if player:get_fd() == nil then
						log.d(string.format('[watchdog] REAL_USER transform offline user to online user. user_id = %s, new_fd = %d', user_id, fd))
						player:force_resume(fd, gate)
						return player.agent
					else
						log.d(string.format('[watchdog] REAL_USER user is online. we dont allow multilogin. close the new fd = %d', fd))
						skynet.call(gate, 'lua', 'kick', fd)
						return false
					end
				elseif player:is_afk() then
					player:resume(fd, gate)
					return player.agent
				else
					assert(false, string.format('invalid player state'))
				end
			else  -- the event or wild try to call the user.
				if player:is_active() then
					log.d(string.format('[watchdog] OFFLINE_USER player is already active, just return it. user_id = %s', user_id))
					return player.agent
				elseif player:is_afk() then
					log.d(string.format('[watchdog] OFFLINE_USER player is afk. resume it. user_id = %s', user_id))
					player:set_fd(nil)
					player:resume()
					return player.agent
				else
					assert(false, string.format('invalid player state'))
					return false
				end
			end
		end

		local agent = skynet.newservice("agent")
		skynet.call("monitor", "lua", "WATCH", agent)
		skynet.call(agent, "lua", "start", conf)

		player = player_state.new(agent, user_id, fd)
		addr_map[agent] = user_id
		agents[user_id] = player
		player:login(fd, gate)

		if fd then
			fd_map[fd] = user_id
			total_online = total_online + 1
			log.d('[watchdog] create a online user, total_online + 1')
		else
			log.d('[watchdog] create a offline user, total_offline + 1')
			total_offline = total_offline + 1
		end

		return player.agent
	end

	log.d(string.format('[watchdog] get_user TOTAL QUEUE = %d, user_id = %s', Tool:tnums(user_cs), conf.user_id))
	if not cs then
		cs = queue()
		user_cs[conf.user_id] = cs
	end
	return cs(proc_get_user, conf)
end


















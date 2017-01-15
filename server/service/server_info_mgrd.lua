require "agent_startup"
local skynet = require "skynet"
require "skynet.manager" -- skynet.register is in skynet.manager module
local weather = require "weather"
local server_info_mgr --= require "server_config"

local serverd = {}
local CMD_HANDER = {
	["serverd"] = serverd, 
    ["server_info_mgr"] = server_info_mgr,
    ["weather"] = weather,
}

function serverd:start()
    log.i('[serverd] start server_info_mgr.')
    local ret = skynet.call('database', 'lua', 'server', 'load')
    server_info_mgr = require("server_info_mgr"):cache_from_db(ret)
    CMD_HANDER["server_info_mgr"] = server_info_mgr
    weather:setserverInfo(server_info_mgr)
    weather:refresh()
    weather:set_timer()
end

function serverd:close()
    -- TODO save data to database
    log.d('[serverd] TODO: save data to database before close serverd.')
end

function serverd:exit()
    skynet.exit()
end

skynet.start(function()
	skynet.register("server_info_mgr")
	skynet.dispatch("lua", function(_, _, handler_name, command, ...)
        log.d("[server_info_mgrd] recive command = " .. command)
        local handler = CMD_HANDER[handler_name]
        assert(handler, string.format("not found handler for name = [%s]", handler_name))
        local f = handler[command]
        assert(f, string.format("not found command = [%s] for handler[%s]", command, handler_name))
        
        local function error_handler(err)
            print(err)
            print(debug.traceback())
        end

        local function ret(ok, ...)
            local n = select('#', ...)
            if ok and n > 0 then
                skynet.retpack (...)
            else
                skynet.retpack {}
            end
        end

        -- here we use pcall to raise errors, it's common that make mistakes of access database when develop.
        ret (xpcall (f, error_handler, handler,...))

    end)
end)
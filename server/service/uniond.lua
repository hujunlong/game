require "agent_startup"
local skynet = require "skynet"
require "skynet.manager"
require "tool"
require "union"
local union_handler
local uniond = {}

local traceback = debug.traceback
local CMD_HANDER = {
    ["uniond"] = uniond,
    ["union"] = Union,
    ["unions_handler"] = union_handler,
}
function uniond:start()
    log.i('[Union] start uniond service')
    union_handler = require("unions_handler")
    CMD_HANDER['unions_handler'] = union_handler
    local ret = skynet.call('database', 'lua', 'union', 'load')
    Union:init_by_db(ret)
    return true
end

function uniond:close()
    log.w('[Union] TODO close union data.')
    return true
end

function uniond:exit()
    skynet.exit()
end

skynet.start(function()
    skynet.register("union")
    skynet.dispatch("lua", function(_, _, handler_name, command, args, ...)
        log.d("[uniond] recive command: " .. command)
        local handler = CMD_HANDER[handler_name]
        assert(handler, string.format("not found handler for name = [%s]", handler_name))
        local f = handler[command]
        assert(f, string.format("not found command = [%s] for handler[%s]", command, handler_name))
        
        local function error_handler(err)
            log.e('[Union] ------- ERROR START ------')
            log.e(err)
            log.e(debug.traceback())
            log.e('[Union] ------- ERROR END ------')
        end

        local function ret(ok, ...)
            if ok then
                local n = select("#", ...)
                if n > 0 then
                    skynet.retpack (...)
                end
            else
                skynet.retpack {}
            end
        end
        -- here we use pcall to raise errors, it's common that make mistakes of access database when develop.
        ret (xpcall (f, error_handler, handler,args,...))

    end)
end)


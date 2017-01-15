require "agent_startup"
local skynet = require "skynet"
require "skynet.manager"
require "tool"
require "mail"
local mail_handler
local maild = {}

local traceback = debug.traceback
local CMD_HANDER = {
    ["maild"] = maild,
    ["mail"] = mail,
    ["mail_handler"] = mail_handler,
}

function maild:start()
    log.d('[maild] start mail service')
    mail_handler = require("mail_handler").new()
    CMD_HANDER["mail_handler"] = mail_handler
    return true
end

function maild:close()
    log.d('[maild] close. donothing.')
    return true
end

function maild:exit()
    log.e('[maild] : exit maild.')
    skynet.exit()
end

skynet.start(function()
    skynet.register("mail")
    skynet.dispatch("lua", function(_, _, handler_name, command, args, ...)
        log.d("[maild] recive command ".. command .. "," .. handler_name)
        local handler = CMD_HANDER[handler_name]
        assert(handler, string.format("not found handler for name = [%s]", handler_name))
        local f = handler[command]
        assert(f, string.format("not found command = [%s] for handler[%s]", command, handler_name))
        
        if handler_name == "mail_handler" then
            mail_handler:cache_user_data(args)
            log.d("[mail_handler] now agent user id is:"..args.current_user_id)
        end
        local function error_handler(err)
            log.e('[maild] ------- ERROR START ------')
            log.e(err)
            log.e(debug.traceback())
            log.e('[maild] ------- ERROR END ------')
        end

        local function ret(ok, ...)
            if ok then
                skynet.retpack (...)
            else
                skynet.retpack {}
            end
            if handler_name == "mail_handler" then
                mail_handler:clear_cache(args)
            end
        end
        -- here we use pcall to raise errors, it's common that make mistakes of access database when develop.
        ret (xpcall (f, error_handler, handler,args,...))

    end)
end)


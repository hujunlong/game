local DB_event = {
    
}

local col_get_func 
local db_get_func

function DB_event.init(get_func, get_db)
    assert(get_func and type(get_func) == 'function')
    col_get_func = get_func
end


function DB_event.load()
    log.i('[DB_event] load')
    local collection = col_get_func('events', 'foobar')
    local cursor = collection:find({finished = false}):sort({finish_time = 1})
    local r = {}
    local num = 0
    while cursor:hasNext() do
        local event = cursor:next()
        table.insert(r, event)
        num = num + 1
    end
    log.w('[DB_event] load ' .. num .. ' events.')
    return r
end

function DB_event.update(event)
    log.i('[DB_event] update event_id = '.. event._id)

    assert(event._id)

    local collection = col_get_func('events', "foobar")
    collection:update({_id = event._id}, event, true)
end

function DB_event.find_with_id(event_id)
    local collection = col_get_func('events', event_id)
    local ret = collection:findOne({_id = event_id})

    return ret
end

return DB_event
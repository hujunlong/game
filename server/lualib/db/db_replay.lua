local DB_replay = {
    
}

local col_get_func 
local db_get_func

local collection_name = 'replays'
function DB_replay.init(get_func, get_db)
    assert(get_func and type(get_func) == 'function')
    col_get_func = get_func
end


function DB_replay.update(replay)
    log.i('[DB_replay] update replay_id = '.. replay._id)

    assert(replay._id)

    local collection = col_get_func(collection_name, replay._id)

    collection:update({_id = replay._id}, replay, true)
end

function DB_replay.find_with_user_id(user_id)
    local collection = col_get_func(collection_name, user_id)
    local ret = collection:find({user_id = user_id})

    return ret
end

return DB_replay
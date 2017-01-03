local DB_server_info = {
    
}

local col_get_func 
local db_get_func

function DB_server_info.init(get_func, get_db)
    assert(get_func and type(get_func) == 'function')
    col_get_func = get_func
end


function DB_server_info.load()
    local collection = col_get_func('servers', 'foobar')
    local cursor = collection:find()
    local r = nil
    while cursor:hasNext() do
        r = cursor:next()
    end
    return r
end

function DB_server_info.update(config)
    assert(config._id)

    local collection = col_get_func('servers', "foobar")
    collection:update({_id = config._id}, config, true)
end

function DB_server_info.find_with_id(config_id)
    local collection = col_get_func('servers', config_id)
    return collection:findOne({_id = config_id})
end

return DB_server_info
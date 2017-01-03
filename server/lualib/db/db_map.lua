local DB_map = {
    
}

local col_get_func 
local db_get_func

function DB_map.init(get_func, get_db)
    assert(get_func and type(get_func) == 'function')
    col_get_func = get_func
end


function DB_map.load()
    log.i('[DB_map] load')
    local collection = col_get_func('maps', 'foobar')
    local cursor = collection:find()
    local r = {}
    local num = 0
    while cursor:hasNext() do
        local tile = cursor:next()
        -- r[tile._id] = tile
        r[tile.x] = r[tile.x] or {}
        r[tile.x][tile.y] = tile
        num = num + 1
    end
    log.w('[DB_map] Total load ' .. num .. ' tiles for map.')

    -- ten senconds later to clean, should be enough, this setting depend on how
    -- much time is used for setting up the server.
    if require("system_config").db_gc then
        require('skynet').timeout(100 * 30, function() 
            log.w('[DB_map] collect garbage for load.')
            collectgarbage()
        end)
    end
    
    return r
end

function DB_map.update_with_id(tile_id, tile)
    assert(tile and type(tile) == 'table')
    assert(tile._id > 0)

    local collection = col_get_func('maps', 'foobar')
    collection:update({_id = tile_id}, tile, true)
end

function DB_map.update_with_ids(tiles)
    assert(type(tiles) == 'table' and next(tiles))
    local collection = col_get_func('maps', 'foobar')

    for tile_id, tile in pairs(tiles) do
        collection:update({_id = tile_id}, tile, true)
    end
end

function DB_map.find_with_id(tile_id)
    -- user_id is using the hex-format of objectid string.
    assert(tile_id and type(tile_id) == 'string' and string.len(tile_id) == 24)

    local collection = col_get_func('maps', 'foobar')
    local ret = collection:findOne({_id = tile_id})
    return ret
end


return DB_map
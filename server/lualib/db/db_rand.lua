local DB_Rand = {
    
}

local col_get_func 
local db_get_func

function DB_Rand.init(get_func, get_db)
    assert(get_func and type(get_func) == 'function')
    col_get_func = get_func
end

function DB_Rand.update(croupier)
    log.i('[DB_Rand] update croupier id = '.. croupier._id)

    assert(croupier._id)

    local collection = col_get_func('rands', croupier._id)
    collection:update({_id = croupier._id}, croupier, true)
end

function DB_Rand.find_with_id(croupier_id)
    local collection = col_get_func('rands', croupier_id)
    local ret = collection:findOne({_id = croupier_id})

    if ret then 
        return true, ret
    else
        return false
    end
end

return DB_Rand
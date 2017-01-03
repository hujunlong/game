local DB_Mail = {
    
}

local col_get_func 

function DB_Mail.init(get_func)
    assert(get_func and type(get_func) == 'function')
    col_get_func = get_func
end


function DB_Mail.update(mail, user_id)
    log.d('call DB_Mail.update'.. user_id)

    assert(user_id)

    local collection = col_get_func('mails', user_id)
    log.d('mails collection = ', collection)
    collection:update({_id = user_id}, mail, true)
end

function DB_Mail.find_with_id(user_id)
    -- user_id is using the hex-format of objectid string.
    log.d('call DB_Mail.find_with_id'..user_id)
    assert(user_id)
    local collection = col_get_func('mails', user_id)
    local ret = collection:findOne({_id = user_id})

    return ret
end

return DB_Mail
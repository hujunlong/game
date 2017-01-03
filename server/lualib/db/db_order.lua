local DB_Order = {
    
}

local col_get_func 

function DB_Order.init(get_func, get_db)
    assert(get_func and type(get_func) == 'function')
    col_get_func = get_func
end

function DB_Order.update(select, cmd)
    local collection = col_get_func('orders', "update")
    collection:update(select, cmd, true)
    return true
end

function DB_Order.save(doc)
    local collection = col_get_func('orders', "save")
    collection:update({_id = doc._id}, doc, true)
    return true
end

function DB_Order.find(select, attrs)
    local collection = col_get_func('orders', 'find')
    local cursor = collection:find(select, attrs)
    local r = {}
    local num = 0
    while cursor:hasNext() do
        local record = cursor:next()
        num = num + 1
        table.insert(r, record)
    end
    return r
end

return DB_Order
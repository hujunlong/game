local bson = require "bson"
local DB_Gateway = {
  
}

local col_get_func

function DB_Gateway.init(get_func)
  col_get_func = get_func
end

function DB_Gateway.load()
  local collection = col_get_func('gateway', 'gateway')
  local cursor = collection:find({})
  local r = {}
  local num = 0
  while cursor:hasNext() do
    local r = cursor:next()
    num = num + 1
    table.insert(r, r)
  end
  return r
end

return DB_Gateway
local DB_union = {
    
}

local col_get_func 
local db_get_func

local NAMES = {}

function DB_union.init(get_func, get_db)
    assert(get_func and type(get_func) == 'function')
    col_get_func = get_func
end


function DB_union.load()
    log.i('[DB_union] load')
    local collection = col_get_func('unions', 'foobar')
    local cursor = collection:find()
    local list = {}
    local num = 0
    while cursor:hasNext() do
        local union = cursor:next()
        list[union._id] = union
        num = num + 1
    end
    log.w('[DB_union] Total load ' .. num .. ' unions.')
    return list
end

function DB_union.load_name()
  local collection = col_get_func('unions', 'name')
  local cursor = collection:find({}, {name = true})
  while cursor:hasNext() do
    local r = cursor:next()
    NAMES[r.name] = true
  end
  return true
end

function DB_union.update_name(name)
  if NAMES[name] then return false end
  NAMES[name] = true
  return true
end

function DB_union.load_info_for_map()
    local collection = col_get_func('unions', 'foobar')
    local cursor = collection:find({}, {_id = 1, name = 1, language = 1, short_name = 1, logo = 1, banner = 1})
    local list = {}
    local num = 0
    while cursor:hasNext() do
        local union = cursor:next()
        list[union._id] = union
        num = num + 1
    end
    log.w('[DB_union] load_info_for_map Total load ' .. num .. ' unions.')
    return list
end

function DB_union.update_with_id(union_id, union)
    assert(union and type(union) == 'table')

    local collection = col_get_func('unions', 'foobar')
    collection:update({_id = union_id}, union, true)
end

function DB_union.delete_with_id(union_id, single)
    local collection = col_get_func('unions', 'foobar')
    collection:delete({_id = union_id}, single)
end

function DB_union.find_with_id(union_id)
    assert(union_id and type(union_id) == 'string' and string.len(union_id) == 24)

    local collection = col_get_func('unions', 'foobar')
    local ret = collection:findOne({_id = union_id})
    return ret
end

function DB_union.find_by_ids( ids, attrs )
  local collection = col_get_func('unions', 'union_ids')
  local cursor = collection:find({_id = {["$in"] = ids}}, attrs)
  local r = {}
  local num = 0
  while cursor:hasNext() do
      local score = cursor:next()
      num = num + 1
      table.insert(r, score)
  end
  log.w('Total load ' .. num .. ' union.')
  return r
end

function DB_union.load_score(  )
    log.i('[DB_union] load score')
    local collection = col_get_func('unions', 'load_score')
    local cursor = collection:find({}, {might = true, bp = true})
    local list = {}
    local num = 0
    while cursor:hasNext() do
        local union = cursor:next()
        table.insert(list, union)
        num = num + 1
    end
    log.w('[DB_union] Total load score' .. num .. ' unions.')
    return list
end

function DB_union.find_match_name( name, attrs )
    local collection = col_get_func('unions', 'match_union_name')
    local cursor = collection:find({name = {["$regex"] = name }}, attrs):limit(20)
    local r = {}
    local num = 0
    while cursor:hasNext() do
        local record = cursor:next()
        num = num + 1
        table.insert(r, record)
    end
    log.w('Total load ' .. num .. ' union.')
    return r
end




return DB_union
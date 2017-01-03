local bson = require "bson"
local DB_User = {
}

local USER_NAMES = {}
local col_get_func

function DB_User.init(get_func)
	col_get_func = get_func
end

function DB_User.load_score()
	local collection = col_get_func('users', "user_might")
	local cursor = collection:find({},{_id = true, might = true, bp = true, cb_score = true, hero_score = true})
	local r = {}
	local num = 0
	while cursor:hasNext() do
		local score = cursor:next()
		num = num + 1
		table.insert(r, score)
	end
	log.w("Total load" .. num .. ' score.')
	return r
end

function DB_User.load_user_name()
	local collection = col_get_func('users', 'user_name')
	local cursor = collection:find({}, {user_name = true})
	while cursor:hasNext() do 
		local r = cursor:next()
		USER_NAMES[r.user_name] = true
	end
end

function DB_User.update_user_name(user_name)
	if USER_NAMES[user_name] then return false end
	USER_NAMES[user_name] = true
	return true
end

function DB_User.load_ids()
	local collection = col_get_func('users', 'ids')
	local cursor = collection:find({}, {_id = true})
	local r = {}
	while cursor:hasNext() do
		local user = cursor:next()
		table.insert(r, user._id)
	end
	return r
end

function DB_User.load_common_info()
  local collection = col_get_func('users', 'union_info')
  local cursor = collection:find({}, {_id = 1, union_id = 1, user_name = 1, x = 1, y = 1, level = 1})
  local users = {}
  while cursor:hasNext() do
    local user = cursor:next()
    users[user._id] = {
      union_id = user.union_id,
      name = user.user_name,
      x = user.x,
      y = user.y,
      level = user.level,
    }
  end
  return users
end

function DB_User.find_with_passport(passport)
	local collection = col_get_func('users', passport or 'passport')
	local ret = collection:findOne({passport = passport})
	return ret ~= nil, ret
end

function DB_User.find_with_id(user_id)
	local collection = col_get_func('users', user_id)
	local ret = collection:findOne({_id = user_id})

	return ret ~= nil, ret
end

function DB_User.update(user)
	log.i(string.format('[DB_User.update] user_id = %s, user_name = %s, passport = %s', 
			user._id, user.user_name, user.passport))
	assert(user._id and user.user_name)

	local collection = col_get_func('users', user.user_name or 'user_name')

	collection:update({_id = user._id}, user, true)
end

function DB_User.find_by_ids( ids, attrs )
  local collection = col_get_func('users', 'user_ids')
  local cursor = collection:find({_id = {["$in"] = ids}}, attrs)
  local r = {}
  local num = 0
  while cursor:hasNext() do
      local score = cursor:next()
      num = num + 1
      table.insert(r, score)
  end
  log.w('Total load ' .. num .. ' user.')
  return r
end

function DB_User.find_by_user_name(user_name, attrs)
  local collection = col_get_func('users', user_name)
  local ret = collection:findOne({user_name = user_name}, attrs)
  return ret ~= nil, ret
end

function DB_User.find_by_fb_id(fb_id, attrs)
  local collection = col_get_func('users', fb_id)
  local ret = collection:findOne({fb_id = fb_id}, attrs)
  return ret ~= nil, ret
end

function DB_User.find_by_gc_id(gc_id, attrs)
  local collection = col_get_func('users', gc_id)
  local ret = collection:findOne({gc_id = gc_id}, attrs)
  return ret ~= nil, ret
end

function DB_User.find_match_name( name, attrs )
    local collection = col_get_func('users', 'math_user_name')
    local cursor = collection:find({user_name = {["$regex"] = name }}, attrs):limit(20)
    local r = {}
    local num = 0
    while cursor:hasNext() do
        local record = cursor:next()
        num = num + 1
        table.insert(r, record)
    end
    log.w('Total load ' .. num .. ' user.')
    return r
end

function DB_User.find_no_union(attrs, offset, limit, language, login_time)
    local collection = col_get_func('users', 'no_union')
    local query = {union_id = ""}

    if language then
        query.language = language
    elseif not_language then
        query.language = {["$ne"] = not_language}
    end

    if login_time then
        query.last_login_time = {["$gt"] = login_time}
    end

    local cursor = collection:find(query, attrs):skip(offset):limit(limit)
    local r = {}
    local num = 0
    while cursor:hasNext() do
        local record = cursor:next()
        num = num + 1
        table.insert(r, record)
    end
    log.w('no_union total load ' .. num .. ' user no union.')
    return r
end

function DB_User.find_no_union_by_name(name, attrs, offset, limit, exclude)
    local collection = col_get_func('users', 'no_union_by_name')
    local query = {union_id = ""}
    if name ~= "" then
        query.user_name = {["$regex"] = name }
    end
    if type(exclude) == "table" and next(exclude) then
        query._id = {["$nin"] = exclude}
    end
    attrs.might = 1
    local cursor = collection:find(query, attrs):sort({might = -1}):skip(offset):limit(limit)
    local r = {}
    local num = 0
    while cursor:hasNext() do
        local record = cursor:next()
        num = num + 1
        table.insert(r, record)
    end
    log.w('no_union_by_name total load ' .. num .. ' user no union.')
    return r
end

function DB_User.find_users_to_invite(limit)
    local collection = col_get_func('users', 'users_to_invite')
    local attrs = {_id = 1, might = 1, last_login_time = 1}
    local time = os.time() - 3600 * 24 * 3      --三天内登陆
    local query = {
        union_id = "",
        last_login_time = {
            ["$gt"] = time,
        },
    }
    local cursor = collection:find(query, attrs):sort({might = -1}):limit(limit)
    local ret = {}
    local num = 0
    while cursor:hasNext() do
        local record = cursor:next()
        num = num + 1
        table.insert(ret, record)
    end
    log.w('users_to_invite total load ' .. num .. ' user no union.')
    return ret
end

-- find user who doesn't login for {time} with max {limit} and {min_level}
function DB_User.find_zombie_user(time, min_level, limit)
    assert(time)
    assert(limit)
    local collection = col_get_func('users', 'find_zombie_user')
    local last_login_time = os.time() - time  
    local query = {
        last_login_time = {
          ["$lt"] = last_login_time
        },
        level = {
          ["$gt"] = 2
        }
    }

    local cursor = collection:find(query):limit(limit)
    local ret, num = Tool:pack_cursor(cursor)

    log.w('find_zombie_user total load ' .. num .. ' zombie users.')
    return ret
end

return DB_User
local M = {}

Tool = M
log = log or require "logger"
local skynet = require "skynet"

local pack = pack or table.pack 
local unpack = unpack or table.unpack
function Tool:merge( tables )
  local first = tables[1]
  if not first then return {} end
  for key, table in ipairs(tables) do
    if key ~= 1 then
      for k, v in pairs(table) do
        first[k] = v
      end 
    end   
  end
  return first
end

function Tool:tnums(t)
  local total = 0
  for k, v in pairs(t) do
    total = total + 1
  end
  return total
end

function Tool:CopyTable(st)  
    local tab = {}  
    for k, v in pairs(st or {}) do  
        if type(v) ~= "table" then  
            tab[k] = v  
        else  
            tab[k] = self:CopyTable(v)  
        end  
    end  
    return tab  
end 

function Tool:add_merge( tables )
  local first = tables[1]
  if not first then return {} end
  for key, table in ipairs(tables) do
    if key ~= 1 then
      for k, v in pairs(table) do
        if first[k] == nil then
          first[k] = Tool:clone(v)
        end
      end 
    end   
  end
  return first
end

function Tool:inspect(t, depth)
  local depth = depth or 1
  io.write('{\n')
  for k, v in pairs(t) do
    Tool:PrintTab(depth)
    io.write('[')
    Tool:PrintTableValue(k, depth + 1)
    io.write('] = ')
    Tool:PrintTableValue(v, depth + 1)
    io.write(',\n')
  end
  Tool:PrintTab(depth-1)
  io.write('}')
end

function Tool:ensure_range(value, min, max)
  if value < min then 
    value = min 
  elseif value  > max then
    value = max
  else
    -- pass
  end
  return value
end

function Tool.print_r(root, info)
  local cache = {  [root] = "." }
  local function _dump(t,space,name)
      local temp = {}
      for k,v in pairs(t) do
          local key = tostring(k)
          if cache[v] then
              table.insert(temp,"+" .. key .. " {" .. cache[v].."}")
          elseif type(v) == "table" then
              local new_key = name .. "." .. key
              cache[v] = new_key
              table.insert(temp,"+" .. key .. _dump(v,space .. (next(t,k) and "|" or " " ).. string.rep(" ",#key),new_key))
          else
              table.insert(temp,"+" .. key .. " [" .. tostring(v).."]")
          end
      end
      return table.concat(temp,"\n"..space)
  end
  local extraInfo = info or ""
  print("\n------------------------------------------------------------------------\n" 
      .. extraInfo .. "\n"
      .. _dump(root, "","")
      .. "\n------------------------------------------------------------------------")
end
print_r = Tool.print_r

function Tool:PrintTableValue(v, depth)
  if type(v) == 'string' then
    io.write(string.format('%q', v))
  elseif type(v) == 'number' then
    io.write(v)
  elseif type(v) == 'boolean' then
    io.write((v and 'true') or 'false')
  elseif type(v) == 'table' then
    Tool:inspect(v, depth)
  elseif type(v) == 'function' then
    io.write('function')
  else  
    error('Wrong value type for data table! '..type(v))
  end
end

function Tool:PrintTab(n)
  for i = 1, n do
    io.write('\t')
  end
end

function Tool:map(array, func)
  local new_array = {}
  for i,v in pairs(array) do
    new_array[i] = func(v, i)
  end
  return new_array
end

function Tool:imap(array, func)
  local new_array = {}
  for i,v in ipairs(array) do
    new_array[i] = func(v, i)
  end
  return new_array
end

function Tool:find( t, func )
  for k, v in pairs(t) do
    if func(v) then 
      return v 
    end
  end
  return nil
end

function Tool:max( t )
  table.sort(t)
  return t[#t]
end

function Tool:min( t )
  table.sort(t)
  return t[1]
end

function Tool:min_by( t, func )
  table.sort(t, function ( a, b )
    return func(a) < func(b)
  end)
  return t[1]
end

function Tool:max_by( t, func )
  table.sort(t, function ( a, b )
    return func(a) > func(b)
  end)
  return t[1]
end

function Tool:slice( t, start, end_point )
  if end_point == -1 then
    end_point = #t - start
  end
  return _.slice(t, start, end_point)
end

function Tool:include( t, elem )
  for i,v in ipairs(t) do
    if v == elem then return true end
  end
  return false
end

function Tool:sum(t, func )
  local total = 0
  for k,v in pairs(t) do
    total = total + func(v)
  end
  return total
end

function Tool:remove(list, item, removeAll)
    local rmCount = 0
    for i = 1, #list do
        if list[i - rmCount] == item then
            table.remove(list, i - rmCount)
            if removeAll then
                rmCount = rmCount + 1
            else
                break
            end
        end
    end
end

function Tool:delete( list, func, removeAll )
  local rmCount = 0
  for i = 1, #list do
      if func(list[i - rmCount]) then
          table.remove(list, i - rmCount)
          if removeAll then
            rmCount = rmCount + 1
          else
            break
          end
      end
  end
end

function Tool:select( t, func )
  return _.select(t, func)
end

function Tool:split(str, sep)
    -- print(debug.traceback("Stack trace"))
    str = tostring(str)
    assert(str and sep and #sep > 0)
    if #str == 0 then return {} end
    local reg = string.format('[%s]', sep)
    local r = {}
    local _begin = 1
    while _begin <= #str do
        local _end = string.find(str, reg, _begin) or #str + 1
        table.insert(r, string.sub(str, _begin, _end - 1))
        _begin = _end + 1
    end
    if string.match(string.sub(str, #str, #str), reg) then table.insert(r, '') end
    return r
end

function Tool:index( t, value )
  for i,v in ipairs(t) do
    if v == value then return i end
  end
  return nil
end

function Tool:indext( t, func )
  for i,v in ipairs(t) do
    if func(v) then return i else return nil end
  end
end

function Tool:CompressTable(t)
  local r = {}
  for k,v  in pairs(t) do
    if v and next(v) then
      r[k] = v
    end
  end
  return r
end
function Tool:is_blank( t )
  for k,v in pairs(t) do
    return false
  end
  return true
end

function Tool:rand( t )
  if t and next(t) then
    return t[math.random( #t )]
  else
    return nil
  end
end

local bson = require "bson"
function Tool:guid()
  return Tool:objectid_s()
    -- local seed = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'}
    -- local tb = {}
    -- for i =1,32 do
    --     table.insert(tb,seed[math.random(1,16)])
    -- end
    
    -- local sid = table.concat(tb)
    -- return string.format('%s%s%s%s%s',
    -- string.sub(sid,1,8),
    -- string.sub(sid,9,12),
    -- string.sub(sid,13,16),
    -- string.sub(sid,17,20),
    -- string.sub(sid,21,32))
end

--function Tool:guid()
--local template ="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
--  d = io.open("/dev/urandom", "r"):read(4)
--  math.randomseed(os.time() + d:byte(1) + (d:byte(2) * 256) + (d:byte(3) * 65536) + (d:byte(4) * 4294967296))
--  return string.gsub(template, "x", function (c)
 --       local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
 --       return string.format("%x", v)
 --       end)
--end

local tinsert = table.insert
local sformat = string.format
local sbyte = string.byte

function Tool:objectid2str(object_id)
  assert(type(object_id) == 'string' and string.len(object_id) == 14)
  local t = {}
  -- byte(1,2) represents the type is object_id binary type, we don't need it.
  for i = 3, 14 do
    local byte = sbyte(object_id, i)
    local high = (byte >> 4) & 0x0f
    local low = byte & 0x0f
    s = sformat('%x%x',high,low)
    tinsert(t, s)
  end
  return table.concat(t)
end

function Tool:objectid_s()
  return Tool:objectid2str(bson.objectid())
end

function Tool:deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function Tool:clone(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
          if not string.find(orig_key, "__") and type(orig_value) ~= "function" then
            copy[Tool:clone(orig_key)] = Tool:clone(orig_value)
          end
        end
        setmetatable(copy, Tool:clone(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function Tool:rand_range(from, to)
  from = tonumber(from)
  to = tonumber(to)
  return math.floor(math.random() * (to - from + 1)) + from
end

function Tool:get_t_by_id(t,id,num)
    for k,v in pairs(t) do
        if v._id == id then
            return v.load * num
        end
    end
end

function Tool:get_t_by_level(t,level)
        for k,v in pairs(t) do
        if v.level == level then
            return v
        end
    end
end

function Tool:concat( ts )
  local result = {}
  for i,t in pairs(ts) do
    for i,v in pairs(t) do
      table.insert(result, v)
    end
  end
  return result
end

function Tool:add( t1, t2 )
  local result = {}
  for k,v in pairs(t1) do
    result[k] = v
    if t2[k] then
      result[k] = result[k] + t2[k]
    end  
  end
  for k,v in pairs(t2) do
    if not t1[k] then
      result[k] = v
    end  
  end
  return result
end

function Tool:adds( ... )
  local result = {}
  for i,v in ipairs({...}) do
    result = Tool:add(result, v)
  end
  return result
end

-- 最小为0
function Tool:decr_res( t1, t2 )
  local result = {}
  for k,v in pairs(t1) do
    result[k] = v
    if t2[k] then
      result[k] = result[k] - t2[k]
      if result[k] < 0 then
        result[k] = 0
      end
    end
  end
  return result
end

function Tool:last( t )
  return t[#t]
end

function Tool:init_seed()
    math.randomseed(tostring(os.time()):reverse():sub(1,6))
end

function Tool:getTableMaxKey(t)
  local maxK = 1
  for k, v in pairs (t) do
    if maxK < k then
      maxK = k
    end
  end
  return maxK
end

function Tool:getTableMinKey(t)
  local mink = 1
  for k, v in pairs (t) do
    if mink > k then
      mink = k
    end
  end
  return mink
end

function Tool:multi( t, num )
  local result = {}
  for i,v in pairs(t) do
    result[i] = math.ceil(v * num)
  end
  return result
end

function Tool:random_event_100( rate, custom_id )
  if not custom_id then
      return self:rand_range(1, 100) <= tonumber(rate)
  else
    if rate == 100 then
        return true
    elseif rate == 0 then
        return false
    else
        return skynet.call('rand', 'lua', 'rand', custom_id, {rate, 100 - rate}) == 1
    end
  end
end

function Tool:random_event_1000( rate )
  return self:rand_range(1, 1000) <= tonumber(rate)
  -- if rate == 1000 then
  --     return true
  -- elseif rate == 0 then
  --     return false
  -- else
  --     return skynet.call('rand', 'lua', 'rand', custom_id, {rate, 1000 - rate}) == 1
  -- end
end

function Tool:gamble( items, id )
  local total = 0
  local total2 = 0
  local convert = {}
  local one = nil
  for k,v in pairs(items) do
    total = total + v          
  end
  for k,v in pairs(items) do
    local new_rate = math.floor(v/total*100) 
    total2 = total2 + new_rate
    convert[k] = new_rate
    one = k
  end
  local need = 100 - total2
  convert[one] = convert[one] + need
  return Tool:lottery(convert, id)
end

function Tool:lottery( items, id )
  -- random normally
  if not id then
    local total = 100
    local ks = {}
    local vs = {}
    local large = {}
    local small = {}
    local combo = {}
    for k,v in pairs(items) do
      table.insert(ks, k)
      table.insert(vs, v)
    end

    if #ks == 0 then return end
    for index,v in ipairs(vs) do
      vs[index] = v * #vs
    end

    for index,v in ipairs(vs) do
      if v > total then
        table.insert(large, {index = index, v = v})
      else
        table.insert(small, {index = index, v = v})
      end      
    end
    while #large ~= 0 and #small ~= 0 do
      local si = small[1]
      table.remove(small, 1)
      local si_side = total - si.v
      local li = large[1]
      li.v = li.v - si_side
      if li.v <= total then
        table.insert(small, large[1])
        table.remove(large, 1)
      end  
      combo[si.index] = {si, {index = li.index, v = si_side}}
    end

    for i,si in ipairs(small) do
      combo[si.index] = {si}
    end

    local c = Tool:rand(combo)
    local r = math.random(total - 1)
    local be_in_ori = r < c[1].v
    local i = nil
    if be_in_ori then 
      i = c[1].index
    else 
      i = c[2].index 
    end
    return ks[i]
  else
    -- random with randd, considering the rand history
    local ks = {}
    local vs = {}

    for k,v in pairs(items) do
      table.insert(ks, k)
      table.insert(vs, v)
    end

    assert(id and type(id) == 'string')
    local index = skynet.call('rand', 'lua', 'rand', id, vs)
    assert(index >= 1 and index <= #ks)
    return ks[index]
  end
end

function Tool:Math_toDecimal1(number)
    return tonumber(string.format("%.1f", number))
end


function Tool:cal_armies_count( armies )
  local count = 0
  for k,v in pairs( armies ) do
    count = count + v.amount
  end
  return count  
end

function Tool:res2gems(resourceType, resourceAmount)
  local rate
  local max_rate
  if resourceType == 'food' then
    rate = (600+0.0003*resourceAmount)
    max_rate = 858
  elseif resourceType == 'wood' then
    rate = (600+0.0003*resourceAmount)
    max_rate = 858
  elseif resourceType == 'gold' then  
    rate = (300+0.0003*resourceAmount)
    max_rate = 429
  elseif resourceType == 'stone' then
    rate = (100+0.0003*resourceAmount)
    max_rate = 143
  elseif resourceType == 'ore' then  
    rate = (12.5+0.0002*resourceAmount)
    max_rate = 18
  end
  if rate > max_rate then
    rate = max_rate
  end
  return math.ceil(resourceAmount/rate)
end

function Tool:ress2gems( res_t )
  local gems = 0
  for k,v in pairs(res_t) do
    gems = gems + Tool:res2gems(k, v)
  end
  return gems
end

function Tool:next_mid(  )
  return Tool:midnight() + BasicConst.DAY_SECS
end

function Tool:midnight(  )
  return math.floor(os.time() / BasicConst.DAY_SECS) * BasicConst.DAY_SECS
end

function Tool:next_day(  )
  return os.time() + BasicConst.DAY_SECS
end

function Tool:pre_day(  )
  return os.time() - BasicConst.DAY_SECS
end

function Tool:add_days( day_count )
  return os.time() + day_count * BasicConst.DAY_SECS
end

function Tool:decr_days( day_count )
  return os.time() - day_count * BasicConst.DAY_SECS
end

function Tool:shuffle_t( t )
  local indexes = Tool:shuffle(#t)
  local result = {}
  for i,v in ipairs(indexes) do
    result[i] = t[v]
  end
  return result
end

function Tool:shuffle(total )
  assert(total)
  local base = {}
  local results = {}
  for i=1, total do
      base[i] = i
  end
  for i=1, total do
      local k = math.random(i, total)
      base[i], base[k] =  base[k],  base[i]
  end
  for i=1, total do
      results[i] = base[i]
  end
  return results  
end

function Tool:rand_n(t, count )
  return {select(-count, unpack(Tool:shuffle_t(t)))}
end
function Tool:order_pairs(t)
    local tinsert = table.insert

    local ot = {}
    -- sort the keys
    for k, _ in pairs(t) do
        tinsert(ot, k)
    end

    table.sort(ot, function(a, b)
            return tostring(a) < tostring(b)
        end)

    local index = 0
    local function iter()
        index = index + 1
        if t[ot[index]] then
            return index, t[ot[index]]
        end
    end

    return iter, t, nil
end

Tool:order_pairs({})

function Tool:shuffle_pairs(t)
    local tinsert = table.insert
    local index = 0
    local ot = {}
    -- sort the keys
    for k, _ in pairs(t) do
        tinsert(ot, k)
    end
    local shuffle_t = Tool:shuffle(#ot)
    local index = 0
    local function iter()
        index = index + 1
        if t[shuffle_t[index]] then
            return index, t[shuffle_t[index]]
        end
    end
    return iter, t, nil
end

function Tool:tail( str )
  return string.sub(str, select(2, string.find(str, " *"))+1, #str)
end

function Tool:print_string_bytes(data)
    if not data then return end
    local s = ""
    for i = 1, string.len(data) do
        s = s .. string.byte(data, i) .. " "
    end
    print(s)
end

function Tool:count_array(array)
  local cnt = {}
  for i = 1, #array do
    local data = array[i]
    cnt[tostring(data)] = cnt[tostring(data)] and cnt[tostring(data)]+1 or 1
  end
  return cnt
end

Tool.init_seed()

-- export the colors from colorful module
color = color or {}
local colorful = require "colorful"
color.red = colorful.red
color.green = colorful.green
color.yellow = colorful.yellow
color.magenta = colorful.magenta
color.cyan = colorful.cyan
color.white = colorful.white
color.reset = colorful.reset


------------------------------------------------------
-- skynet helper functions
------------------------------------------------------

function Tool:skynet_ret(ok, ...)
  local args = {...}
  if ok and next(args) then
      skynet.retpack (...)
  end
end

skynet_ret = Tool.skynet_ret

------------------------------------------------------
function Tool:write_file(filename, t, table_name)
    local file = io.open(filename, 'w+')
    if type(t) == 'string' or type(t) == 'number' or type(t) == 'boolean' then
      file:write(t)
    else
      file:write(table_name)
      file:write(" = ")
      Tool:WriteTable(t, file)
    end
    file:close()
end

-------------------------------- table operation -------------------------------------
function Tool:WriteTableValue(v, file, depth)
    if type(v) == 'string' then
        file:write(string.format('%q', v))
    elseif type(v) == 'number' then
        file:write(v)
    elseif type(v) == 'boolean' then
        file:write((v and 'true') or 'false')
    elseif type(v) == 'table' then
        Tool:WriteTable(v, file, depth)
    else
        error('Wrong value type for data table!')
    end 
end

function Tool:WriteTable(t, file, depth)
    local depth = depth or 1
    file:write('{\n')
  
    local keys = {}
    for k, v in pairs(t) do
        table.insert(keys, k)
    end
    table.sort(keys)
  
    for i, k in ipairs(keys) do
        file:write(Tool:InsertTab(depth))
        file:write('[') 
        Tool:WriteTableValue(k, file, depth + 1) 
        file:write('] = ')
        Tool:WriteTableValue(t[k], file, depth + 1)
        if type(t[k]) == 'table' then
            file:write(Tool:InsertTab(depth))
        end
        file:write(',\n')
    end
    file:write(Tool:InsertTab(depth - 1))
    file:write('}\n')
end

function Tool:InsertTab(n)
  return string.rep('\t', n)
end

function Tool:http_query( params )
  local t = {}
  for k,v in pairs(params) do
    table.insert(t, k.."="..Tool:url_encode(v))
  end
  return table.concat(t, '&')
end

function math.pow(x, y)
  return x^y
end

function Tool:url_encode(str)
    if (str) then
        str = string.gsub (str, "\n", "\r\n")
        str = string.gsub (str, "([^%w %-%_%.%~])",
            function (c) return string.format ("%%%02X", string.byte(c)) end)
        str = string.gsub (str, " ", "+")
    end
    return str
end

function Tool:format_sec( sec )
  local day = math.floor(sec / (3600 * 24)) 
  local hour = math.floor((sec - day * (3600 * 24)) / 3600)
  local minu = math.floor((sec - day * (3600 * 24) - hour * 3600)/60)
  local s = math.floor((sec - day * (3600 * 24) - hour * 3600) - minu * 60)
  local str = ''
  str = s..'s'
  if minu > 0 then
    str = minu..'m'..str
  end
  if hour > 0 then
    str = hour..'h'..str
  end
  if day > 0 then
    str = day..'d'..str
  end
  return str
end

function Tool:GetBp(grade, is_camp, is_rally, is_allie, is_fly, is_win, battle_type, defaultbp)
  local default = defaultbp
  local gradePer = {
      ['S'] = 5,
      ['A'] = 3,
      ['B'] = 2,
      ['C'] = 1,
      ['D'] = 0,
      ['E'] = 0,
      ['F'] = 0,
  }
  local per = 0
  if is_win then
      per = gradePer[grade]
  else
      if battle_type == battle_const.BATTLE_WILD_PVP then
          default = default - 2
      else
          default = default - 6
      end
  end
  
  if not per then
    per = 0
  end
  if is_camp then
    per = per + 10
  end 

  if is_rally then
    per = per + 5
  end

  if is_allie then
    per = per + 15
  end

  if is_fly then
    per = per + 50
  end
  default = math.floor(default * (100 + per)/100)
  return default
end

function Tool:is_tower_army(army_id)
  army_id = tonumber(army_id)
  if army_id >= 53125 and army_id <= 53136 then
    return true
  end
  return false
end
-------------------------------- DataBase operation -------------------------------------

function Tool:pack_cursor(cursor)
  local ret = {}
  local num = 0
  while cursor:hasNext() do
      local record = cursor:next()
      num = num + 1
      table.insert(ret, record)
  end
  return ret, num
end

return M



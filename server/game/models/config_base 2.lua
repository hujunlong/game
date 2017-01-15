local M = {}

ConfigBase = M

function M:new( o )
  o = o or {}
  o.__records = {}  -- 保存所有的记录, {_id = ConfigXXX}
  o.__srecords = {}  -- 保存所有的记录, {ConfigXXX}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:all()
  return self.__records
end

function M:sall(  )
  return self.__srecords
end

function M:set_origin( config )
  self.__config = config
end

function M:get_origin(  )
  return self.__config
end

function M:load(  )
  self.__records = {}
  for k, v in ipairs(self:get_origin()) do
    self.__records[v._id] = self:new(v)
    table.insert(self.__srecords, self.__records[v._id])
  end
end

function M:find_by_id( id )
  return self.__records[id]
end

function M:index_find( store, cols, values )
end

function M:convert_items_col( cache_name, col )
  if self[cache_name] then return self[cache_name] end
  self[cache_name] = {}
  if tostring(self[col]) == '0' then return self[cache_name] end
  for i,str in ipairs(Tool:split(self[col], ',')) do
    local t = Tool:split(str, ':')
    table.insert(self[cache_name], {item_id = tonumber(t[1]), amount = tonumber(t[2])})
  end
  return self[cache_name]
end

function M:convert_effects_col( cache_name, col )
  if self[cache_name] then return self[cache_name] end
  self[cache_name] = {}
  if tostring(self[col]) == '0' then return self[cache_name] end
  for i,str in ipairs(Tool:split(self[col], ',')) do
    local t = Tool:split(str, ':')
    table.insert(self[cache_name], {effect_id = tonumber(t[1]), num = tonumber(t[2])})
  end
  return self[cache_name]
end

function M:convert_effects( cache_name, col )
  if self[cache_name] then return self[cache_name] end
  self[cache_name] = {}
  if self[col] == 0 then return self[cache_name] end
  Tool:map(Tool:split(self[col], ','), function ( str )
    local t = Tool:split(str, ':')
    self[cache_name][tonumber(t[1])] = tonumber(t[2])
  end)
  return self[cache_name]
end

return M


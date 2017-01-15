local M = ConfigBase:new()

ConfigMonsterType = M

M:set_origin(config_monster_types)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:load(  )
  self.__records = {}
  for k, v in ipairs(self:get_origin()) do
    local config = self:new(v)
    config:init_parts()
    self.__records[v._id] = config
    table.insert(self.__srecords, self.__records[v._id])
  end
end

function M:init_parts()
  self.__parts = {}
  for i,str in ipairs(Tool:split(self.part, ',')) do
    local t = Tool:split(str, ':')
    local part = tonumber(t[1])
    local rate = tonumber(t[2])
    self.__parts[part] = rate
  end
end

function M:drop_equipment_part(user_id)
  local rate_array = {}
  local rate_index_part_map = {}
  local i = 0
  for k, v in pairs(self.__parts) do
    i = i + 1
    rate_array[i] = v
    rate_index_part_map[i] = k
  end
  -- local skynet = require "skynet"
  local index = math.random(1,i)--skynet.call('rand', 'lua', 'rand', user_id .. "drop-part", rate_array)
  -- assert(index)
  return rate_index_part_map[index]
end

function M:get_equipment_parts()
  return self.__parts
end

M:load()

return M

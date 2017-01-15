local ConfigBase = require 'config_base'
require 'config_stats'
local M = ConfigBase:new()

ConfigStat = M

M:set_origin(config_stats)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:init_name_key_table()
  local name_key_table = {}
  for k, v in pairs(self:all()) do
    name_key_table[v.name] = v
  end

  self.__name_key_table = name_key_table
end

function M:get_by_name(name)
  return self.__name_key_table[name]
end

function M:get_name_by_id(id)
  for k, v in pairs(self:all()) do
    if v._id == id then
      return v.name
    end
  end
  return nil
end

M:load()
M:init_name_key_table()

return M

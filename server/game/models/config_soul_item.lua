local M = ConfigBase:new()

ConfigSoulItem = M

M:set_origin(config_soul_items)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

M:load()

return M

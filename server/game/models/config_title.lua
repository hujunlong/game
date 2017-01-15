local M = ConfigBase:new()

ConfigTitle = M

M:set_origin(config_titles)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

M:load()

return M

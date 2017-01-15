local M = ConfigBase:new()

ConfigTimeWorth = M

M:set_origin(config_time_worths)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

M:load()

return M

local M = ConfigBase:new()

ConfigDiscountPackage = M

M:set_origin(config_discount_packages)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

M:load()

return M

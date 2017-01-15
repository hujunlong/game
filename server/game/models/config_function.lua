local M = ConfigBase:new()

ConfigFunction = M

M:set_origin(config_funtions)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:get_info( user )
  return {funcs = Tool:map(self:sall(), function ( t )
    return {
      uid = t._id,
      lock = not user:has_func(t._id)
    }
  end)}
end

M:load()

return M

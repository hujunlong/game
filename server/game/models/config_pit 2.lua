local M = ConfigBase:new()

ConfigPit = M

M:set_origin(config_pits)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:get_buildings(  )
  if self.__buildings then return self.__buildings end
  self.__buildings = Tool:map(Tool:split(tostring(self.building), ','), function ( i )
    return tonumber(i)
  end)
  return self.__buildings
end

M:load()

return M


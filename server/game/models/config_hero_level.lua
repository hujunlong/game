local M = ConfigBase:new()

ConfigHeroLevel = M

M:set_origin(config_hero_levels)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:find_by_level( level )
  return Tool:find(self:all(), function ( r )
    return r.level == level
  end)  
end

M:load()

return M

